//
//  PCWhenViewController.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-09.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCWhenViewController.h"
#import "PCWhenView.h"
#import "PCThenViewController.h"
#import "PCWhen.h"
#import "PCThen.h"
#import "Constants.h"
#import "PCAddThenButton.h"
#import <INPopoverController/INPopoverController.h>
#import "PCStatementSelectionViewController.h"
#import "PCExpressionViewController.h"
#import "PCExpressionInspector.h"
#import "PCStatement.h"
#import "PCExpression.h"
#import "PCThenInfo.h"
#import "PCStatementRegistry.h"
#import "PCToken.h"
#import "PCInspectableView.h"
#import "NSUndoManager+ConditionalActionName.h"
#import "NSAttributedString+MutationHelpers.h"

const NSInteger PCThenHorizontalPadding = 6;
const NSInteger PCThenVerticlePadding = -12;

@interface PCWhenViewController () <NSTextViewDelegate, INPopoverControllerDelegate, NSPopoverDelegate, PCWhenDelegate>

@property (weak, nonatomic) IBOutlet PCWhenView *whenView;
@property (weak, nonatomic) IBOutlet NSView *thenContainerView;
@property (unsafe_unretained) IBOutlet NSTextView *whenLabelTextView;
@property (weak, nonatomic) IBOutlet NSButton *addFirstThenButton;

@property (strong, nonatomic) NSMutableArray *thenInfos;
@property (strong, nonatomic) NSArray *bottomConstraints;
@property (strong, nonatomic) NSLayoutConstraint *hideThenButtonConstraint;
@property (strong, nonatomic) PCExpressionViewController *expressionViewController;
@property (strong, nonatomic) NSPopover *expressionPopover;
@property (strong, nonatomic) INPopoverController *thenSelectionPopover;
@property (assign, nonatomic) BOOL shouldSaveExpressionOnDismiss; // We save if you click away to dismiss the popover but don't want to save if you click cancel. This state is needed to know the difference.

@end

@implementation PCWhenViewController

@synthesize selected = _selected;

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:PCTokenHighlightSourceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
            NSUUID *sourceUUID = notification.userInfo[PCTokenHighlightSourceUUIDKey];
            if (![weakSelf.when.statement.UUID isEqual:sourceUUID]) return;

            BOOL state = [notification.userInfo[PCTokenHighlightSourceStateKey] boolValue];
            weakSelf.whenView.sourceHighlighted = state;
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.whenLabelTextView.editable = NO;
    self.whenLabelTextView.selectable = NO;
    self.whenLabelTextView.drawsBackground = NO;
    self.whenLabelTextView.delegate = self;
    self.whenLabelTextView.allowsUndo = NO;
    [self updateUI];

    self.thenInfos = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [(PCWhenView *)self.view setDeleteHandler:^{
        if (weakSelf.deleteHandler) weakSelf.deleteHandler();
    }];

    [self updateAddThenUI];
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    if (self.expressionPopover.shown) {
        [self.expressionPopover close];
    }
    if (self.thenSelectionPopover.popoverIsVisible) {
        [self.thenSelectionPopover forceClosePopover:nil];
    }
}

#pragma mark - Mouse

- (void)mouseDown:(NSEvent *)theEvent {
    [self.view.window makeFirstResponder:self];
}

- (BOOL)becomeFirstResponder {
    self.selected = YES;
    return YES;
}

- (BOOL)resignFirstResponder {
    self.selected = NO;
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    [self interpretKeyEvents:@[ theEvent ]];
}

- (void)deleteBackward:(id)sender {
    if (self.expressionPopover.shown) {
        [self.expressionPopover close];
    }
    if (self.thenSelectionPopover.popoverIsVisible) {
        [self.thenSelectionPopover closePopover:nil];
    }
    for (PCThenInfo *thenInfo in self.thenInfos) {
        [thenInfo.viewController closePopover];
    }
    if (self.deleteHandler) self.deleteHandler();
}

- (void)moveDown:(id)sender {
    PCThenInfo *selectedInfo = [self selectedThenInfo];
    if (selectedInfo) {
        [self selectThenInfo:[self nextThenInfoForInfo:selectedInfo]];
    }
    else {
        [self.nextResponder doCommandBySelector:_cmd];
    }
}

- (void)moveUp:(id)sender {
    PCThenInfo *selectedInfo = [self selectedThenInfo];
    if (selectedInfo) {
        [self selectThenInfo:[self previousThenInfoForInfo:selectedInfo]];
    }
    else {
        [self.nextResponder doCommandBySelector:_cmd];
    }
}

#pragma mark - Actions

- (IBAction)showAddThenSelection:(NSView *)sender {
    [self showThenSelectionFromView:sender insertionIndex:0];
}

#pragma mark - Private

- (void)showThenSelectionFromView:(NSView *)view insertionIndex:(NSInteger)index {
    if (self.thenSelectionPopover) return;

    PCStatementSelectionViewController *viewController = [[PCStatementSelectionViewController alloc] init];
    viewController.style = PCStatementSelectStyleThen;
    viewController.statements = [[PCStatementRegistry sharedInstance] instancesOfAllThenStatements];
    self.thenSelectionPopover = [[INPopoverController alloc] initWithContentViewController:viewController];
    self.thenSelectionPopover.delegate = self;
    self.thenSelectionPopover.animates = NO;
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.thenSelectionPopover) weakPopover = self.thenSelectionPopover;
    [viewController setSelectionHandler:^(PCStatement *statement) {
        [weakPopover closePopover:weakSelf];
        weakSelf.thenSelectionPopover = nil;
        if (!statement) return;

        PCThen *then = [[PCThen alloc] init];
        then.statement = statement;
        [weakSelf.when insertThen:then atIndex:index];
    }];
    [self.thenSelectionPopover presentPopoverFromRect:view.frame inView:view.superview preferredArrowDirection:INPopoverArrowDirectionRight anchorsToPositionView:YES];
}

- (void)insertThen:(PCThen *)then atIndex:(NSInteger)index {
    // clamp index
    if (index < 0) index = 0;
    if (index > self.when.thens.count) index = self.when.thens.count;

    PCThenViewController *thenViewController = [self createThenViewControllerForThen:then];

    PCThenInfo *info = [[PCThenInfo alloc] init];
    info.then = then;
    info.viewController = thenViewController;
    [self.thenInfos insertObject:info atIndex:index];

    [self invalidateConstraintsForThenInfo:[self previousThenInfoForInfo:info]];
    [self invalidateConstraintsForThenInfo:[self nextThenInfoForInfo:info]];

    [self insertThenViewForThen:then];
    [self addChildViewController:thenViewController];

    NSArray *constraints = [self initialConstraintsForThen:then];
    [self.thenContainerView addConstraints:constraints];

    info.constraints = constraints;
    info.needsUpdateConstraints = YES;

    // These seems gross but the first layout pass calculates the correct height
    // and the second pass gives us our correct final layout
    [self.view layoutSubtreeIfNeeded];
    [self.view setNeedsLayout:YES];
    [self.view layoutSubtreeIfNeeded];

    [self updateAddThenUI];
    [self.view invalidateIntrinsicContentSize];
    [self.view setNeedsUpdateConstraints:YES];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = PCBehaviourListAnimationInterval;
        context.allowsImplicitAnimation = YES;
        [self.view.superview layoutSubtreeIfNeeded];
    } completionHandler:^{
        [thenViewController.view.window makeFirstResponder:thenViewController];
    }];
}

- (void)updateAddThenUI {
    BOOL hide = self.when.thens.count > 0;
    if (hide && !self.hideThenButtonConstraint) {
        self.hideThenButtonConstraint = [NSLayoutConstraint constraintWithItem:self.addFirstThenButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.addFirstThenButton.superview attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self.addFirstThenButton.superview addConstraint:self.hideThenButtonConstraint];
    }
    else if (!hide && self.hideThenButtonConstraint) {
        [self.addFirstThenButton.superview removeConstraint:self.hideThenButtonConstraint];
        self.hideThenButtonConstraint = nil;
    }
}

- (void)insertThenViewForThen:(PCThen *)then {
    PCThenInfo *info = [self thenInfoForThen:then];

    __weak typeof(then) weakThen = then;
    __weak typeof(self) weakSelf = self;
    __weak typeof(info) weakInfo = info;

    info.addThenAboveButton = [[PCAddThenButton alloc] init];
    info.addThenAboveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [info.addThenAboveButton setClickHandler:^{
        NSInteger index = [weakSelf.when.thens indexOfObject:weakThen];
        [weakSelf showThenSelectionFromView:weakInfo.addThenAboveButton insertionIndex:index];
    }];

    info.addThenBelowButton = [[PCAddThenButton alloc] init];
    info.addThenBelowButton.translatesAutoresizingMaskIntoConstraints = NO;
    [info.addThenBelowButton setClickHandler:^{
        NSInteger index = [weakSelf.when.thens indexOfObject:weakThen];
        [weakSelf showThenSelectionFromView:weakInfo.addThenBelowButton insertionIndex:index + 1];
    }];

    self.thenContainerView.subviews = [self orderedThenViews];
}

- (NSArray *)orderedThenViews {
    NSMutableArray *subviews = [NSMutableArray array];
    [self.when.thens enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PCThen *then, NSUInteger idx, BOOL *stop) {
        PCThenInfo *info = [self thenInfoForThen:then];
        if (info) {
            [subviews addObject:info.viewController.view];
            [subviews addObject:info.addThenAboveButton];
            [subviews addObject:info.addThenBelowButton];
        }
    }];
    return subviews;
}

- (PCThenViewController *)createThenViewControllerForThen:(PCThen *)then {
    PCThenViewController *thenViewController = [[PCThenViewController alloc] init];
    thenViewController.then = then;
    __weak typeof(self) weakSelf = self;
    __weak typeof(thenViewController) weakViewController = thenViewController;
    [thenViewController setConnectWithNextThenHandler:^{
        PCThen *then = weakViewController.then;
        PCThen *nextThen = [then.when nextThenForThen:then];
        nextThen.runWithPrevious = !nextThen.runWithPrevious;
    }];
    [thenViewController setDeleteHandler:^{
        [weakSelf.when removeThen:then];
    }];
    [thenViewController setSelectionChangeHandler:^{
        PCThen *then = weakViewController.then;
        PCThen *previousThen = [then.when previousThenForThen:then];
        PCThenInfo *previousInfo = [weakSelf thenInfoForThen:previousThen];
        previousInfo.viewController.nextThenSelected = weakViewController.selected;
    }];
    return thenViewController;
}

- (void)updateUI {
    if (![self.whenLabelTextView.textStorage isEqual:[self.when.statement attributedString]]) {
        [self.whenLabelTextView.textStorage setAttributedString:[self.when.statement attributedString]];
        [self.whenLabelTextView.layoutManager ensureLayoutForTextContainer:self.whenLabelTextView.textContainer];
        [self.whenLabelTextView invalidateIntrinsicContentSize];
    }
    [self.view setNeedsUpdateConstraints:YES];
}

- (void)updateSelectedUI {
    self.whenView.selected = self.selected;
}

- (void)deleteThen:(PCThen *)then {
    PCThenInfo *info = [self thenInfoForThen:then];
    if (!info) return;

    PCThenInfo *nextInfo = [self previousThenInfoForInfo:info];
    PCThenInfo *previousInfo = [self nextThenInfoForInfo:info];

    [self invalidateConstraintsForThenInfo:nextInfo];
    [self invalidateConstraintsForThenInfo:previousInfo];

    PCThenViewController *viewController = info.viewController;

    if ([viewController.view.window firstResponder] == viewController) {
        if (nextInfo) {
            [self selectThenInfo:nextInfo];
        }
        else if (previousInfo) {
            [self selectThenInfo:previousInfo];
        }
        else {
            [self.view.window makeFirstResponder:self];
        }
    }

    [self.thenContainerView removeConstraints:info.constraints];
    NSArray *constraints = [self finalConstraintsForThen:then];
    [self.thenContainerView addConstraints:constraints];

    [self.thenInfos removeObject:info];

    [self.view invalidateIntrinsicContentSize];
    [self.view setNeedsUpdateConstraints:YES];
    [self updateAddThenUI];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = PCBehaviourListAnimationInterval;
        context.allowsImplicitAnimation = YES;
        [self.view.superview layoutSubtreeIfNeeded];
        viewController.view.alphaValue = 0;
    } completionHandler:^{
        [self.thenContainerView removeConstraints:constraints];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        [info.addThenAboveButton removeFromSuperview];
        [info.addThenBelowButton removeFromSuperview];
    }];
}

- (void)invalidateConstraintsForThenInfo:(PCThenInfo *)info {
    if (!info) return;
    info.needsUpdateConstraints = YES;
}

- (void)selectThenInfo:(PCThenInfo *)thenInfo {
    if (!thenInfo) return;

    [thenInfo.viewController.view.window makeFirstResponder:thenInfo.viewController];

    CGRect thenRect = thenInfo.viewController.view.frame;
    thenRect.size.height += 12;
    if (self.didFocusRectHandler) self.didFocusRectHandler(thenRect);
}

- (PCThenInfo *)selectedThenInfo {
    for (PCThenInfo *thenInfo in self.thenInfos) {
        if (thenInfo.viewController.selected) {
            return thenInfo;
        }
    }
    return nil;
}

- (PCThenInfo *)thenInfoForThen:(PCThen *)then {
    for (PCThenInfo *info in self.thenInfos) {
        if (info.then == then) {
            return info;
        }
    }
    return nil;
}

- (PCThenInfo *)previousThenInfoForInfo:(PCThenInfo *)info {
    NSInteger index = [self.thenInfos indexOfObject:info];
    if (index < 0 || index >= self.thenInfos.count) return nil;
    index -= 1;
    if (index < 0) return nil;
    return self.thenInfos[index];
}

- (PCThenInfo *)nextThenInfoForInfo:(PCThenInfo *)info {
    NSInteger index = [self.thenInfos indexOfObject:info];
    if (index < 0 || index >= self.thenInfos.count) return nil;
    index += 1;
    if (index >= self.thenInfos.count) return nil;
    return self.thenInfos[index];
}

- (BOOL)hasThenSelected {
    return [self selectedThenInfo] != nil;
}

- (NSInteger)selectedThenIndex {
    for (NSInteger index = 0; index < self.thenInfos.count; index++) {
        PCThenInfo *thenInfo = self.thenInfos[index];
        if (thenInfo.viewController.selected) {
            return index;
        }
    }
    return NSNotFound;
}

#pragma mark - Layout

- (void)updateViewConstraints {
    [super updateViewConstraints];

    for (id then in self.when.thens) {
        PCThenInfo *info = [self thenInfoForThen:then];
        if (info) {
            if (!info.needsUpdateConstraints) {
                continue;
            }
            [info.viewController updateUI];
            [self.thenContainerView removeConstraints:info.constraints];
        }
        else {
            PCThenViewController *thenViewController = [self createThenViewControllerForThen:then];

            info = [[PCThenInfo alloc] init];
            info.then = then;
            info.viewController = thenViewController;
            [self.thenInfos addObject:info];

            [self insertThenViewForThen:then];
            [self addChildViewController:thenViewController];
        }

        NSArray *constraints = [self constraintsForThen:then];
        [self.thenContainerView addConstraints:constraints];
        info.constraints = constraints;
    }
    if (self.bottomConstraints) {
        [self.thenContainerView removeConstraints:self.bottomConstraints];
    }
    PCThenInfo *info = [self thenInfoForThen:self.when.thens.lastObject];
    if (info) {
        NSView *view = info.viewController.view;
        self.bottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastView]-(0)-|" options:0 metrics:nil views:@{ @"lastView": view }];
        [self.thenContainerView addConstraints:self.bottomConstraints];
    }
}

- (NSArray *)constraintsForThen:(PCThen *)then {
    PCThen *previousThen = [then.when previousThenForThen:then];
    PCThenInfo *previousInfo = [self thenInfoForThen:previousThen];
    NSView *previousView = previousInfo.viewController.view;

    PCThenInfo *info = [self thenInfoForThen:then];
    NSView *view = info.viewController.view;

    NSView *container = view.superview;
    NSMutableArray *constraints = [NSMutableArray array];

    // Equal width to container with minus padding
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeWidth multiplier:1 constant:-PCThenHorizontalPadding * 2]];

    // Center horizontally in container
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    // Vertical position
    if (!previousView) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[view]" options:0 metrics:nil views:@{ @"view": view }]];
    }
    else {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-(padding)-[view]" options:0 metrics:@{ @"padding": @(PCThenVerticlePadding) } views:@{ @"view": view, @"previousView": previousView }]];
    }

    [constraints addObjectsFromArray:[self addButtonConstraintsForThen:then]];

    return constraints;
}

- (NSArray *)initialConstraintsForThen:(PCThen *)then {
    PCThen *previousThen = [then.when previousThenForThen:then];
    PCThenInfo *previousInfo = [self thenInfoForThen:previousThen];
    NSView *previousView = previousInfo.viewController.view;
    
    PCThenInfo *info = [self thenInfoForThen:then];
    NSView *view = info.viewController.view;

    NSView *container = view.superview;
    NSMutableArray *constraints = [NSMutableArray array];

    // Equal width to container minus padding
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeWidth multiplier:1 constant:-PCThenHorizontalPadding * 2]];

    // Hide off to the left
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];

    // Vertical position
    if (!previousView) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[view]" options:0 metrics:nil views:@{ @"view": view }]];
    }
    else {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-(padding)-[view]" options:0 metrics:@{ @"padding": @(PCThenVerticlePadding) } views:@{ @"view": view, @"previousView": previousView }]];
    }

    [constraints addObjectsFromArray:[self addButtonConstraintsForThen:then]];

    return constraints;
}

- (NSArray *)finalConstraintsForThen:(PCThen *)then {
    return [self initialConstraintsForThen:then];
}

- (NSArray *)addButtonConstraintsForThen:(PCThen *)then {
    PCThenInfo *info = [self thenInfoForThen:then];
    NSView *view = info.viewController.view;
    NSMutableArray *constraints = [NSMutableArray array];

    info.addThenAboveButton.hidden = !![then.when previousThenForThen:then];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:info.addThenAboveButton attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:info.addThenAboveButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-22]];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:info.addThenBelowButton attribute:NSLayoutAttributeTop multiplier:1 constant:17]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:info.addThenBelowButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-22]];

    return constraints;
}

#pragma mark Properties

- (void)setWhen:(PCWhen *)when {
    if (_when) _when.delegate = nil;
    _when = when;
    _when.delegate = self;
}

#pragma mark - PCBehaviourController

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateSelectedUI];
}

#pragma mark - Copy/Paste

- (void)copy:(id)sender {
    [self.when copyToPasteboard];
}

- (void)cut:(id)sender {
    [self.when copyToPasteboard];
    [self deleteBackward:nil];
}


#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    if (self.expressionPopover) return YES;

    PCExpression *expression = [self.when.statement expressionForLink:link];
    BOOL allowAdvanced = [self.when.statement allowAdvancedEntryForExpression:expression];
    NSViewController<PCExpressionInspector> *simpleInspector = [self.when.statement inspectorForExpression:expression];
    NSArray *suggestedTokens = [self.when.statement availableTokensForExpression:expression];

    self.expressionViewController = [[PCExpressionViewController alloc] initWithExpression:expression inspector:simpleInspector advancedAllowed:allowAdvanced suggestedTokens:suggestedTokens];

    self.expressionPopover = [[NSPopover alloc] init];
    self.expressionPopover.contentViewController = self.expressionViewController;
    self.expressionPopover.delegate = self;

    __weak typeof(self) weakSelf = self;
    __weak typeof(self.expressionPopover) weakPopover = self.expressionPopover;
    __weak typeof(self.expressionViewController) weakExpressionViewController = self.expressionViewController;
    self.shouldSaveExpressionOnDismiss = YES;
    [self.expressionViewController setFinishedHandler:^(BOOL save, PCExpression *expression, BOOL simpleMode, NSArray *chunks) {
        weakSelf.shouldSaveExpressionOnDismiss = NO;
        [weakPopover close];
        weakSelf.expressionPopover = nil;
        if (save) {
            [weakSelf.when.statement updateExpression:expression withAdvancedChunks:chunks isSimpleMode:simpleMode];
            weakExpressionViewController.simpleInspector.saveHandler(expression, weakExpressionViewController.simpleInspector);
            NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
            [undoManager setActionNameUndoGroupCreated:@"Change When"];
        }
        [weakSelf.view.window makeFirstResponder:weakSelf];
    }];
    [self.expressionViewController setDidLayouthandler:^{
        weakPopover.contentSize = weakExpressionViewController.view.bounds.size;
    }];

    NSRange range = [self.when.statement rangeOfLink:link];
    CGRect rect = [textView.layoutManager boundingRectForGlyphRange:range inTextContainer:textView.textContainer];
    self.expressionPopover.animates = NO;
    self.expressionPopover.behavior = NSPopoverBehaviorSemitransient;
    [self.expressionPopover showRelativeToRect:rect ofView:textView preferredEdge:NSMaxYEdge];
    return YES;
}

#pragma mark - INPopoverControllerDelegate / NSPopoverDelegate

//INPopoverControllerDelegate / NSPopoverDelegate use same method with different parameters
- (BOOL)popoverShouldClose:(id)sender {
    if (sender == self.thenSelectionPopover) {
        self.thenSelectionPopover = nil;
        return YES;
    }
    if (sender == self.expressionPopover) {
        return YES;
    }
    return NO;
}

- (void)popoverDidClose:(NSNotification *)notification {
    if (self.expressionViewController) {
        if (self.shouldSaveExpressionOnDismiss) {
            [self.expressionViewController save];
        }
        self.expressionViewController = nil;
        self.expressionPopover = nil;
    }
}

#pragma mark - PCWhenDelegate

- (void)whenNeedsDisplay:(PCWhen *)when {
    [self updateUI];
}

- (void)didAddThen:(PCThen *)then atIndex:(NSInteger)index {
    [self insertThen:then atIndex:index];
}

- (void)didRemoveThen:(PCThen *)then {
    [self deleteThen:then];
}

@end

