//
//  PCBehaviourListViewController.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-09.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCBehaviourListViewController.h"
#import "PCWhenViewController.h"
#import "PCWhen.h"
#import "Constants.h"
#import "PCBehaviourController.h"
#import "PCStatementSelectionViewController.h"
#import <INPopoverController/INPopoverController.h>
#import "PCWhenInfo.h"
#import "PCStatementRegistry.h"
#import "PCBehaviourList.h"
#import "PCSlide.h"
#import "PCBehaviourListView.h"
#import "PCWhenView.h"
#import "PCThen.h"
#import <Underscore.m/Underscore.h>
#import "PCStatement.h"

const NSInteger PCWhenHorizontalPadding = 6;
const NSInteger PCWhenVerticalPadding = 12;

@interface PCBehaviourListViewController () <INPopoverControllerDelegate, PCBehaviourListDelegate>

@property (weak, nonatomic) IBOutlet NSScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSView *scrollContent;
@property (weak, nonatomic) IBOutlet NSSearchField *searchField;
@property (weak, nonatomic) IBOutlet NSView *emptyInstructionsView;
@property (weak, nonatomic) IBOutlet NSView *noResultsView;

@property (strong, nonatomic) PCBehaviourList *behaviourList;
@property (strong, nonatomic) NSMutableArray *whenInfos;
@property (strong, nonatomic) NSMutableArray *filteredWhens;
@property (strong, nonatomic) NSArray *bottomConstraints;
@property (strong, nonatomic) id<PCBehaviourController> selectedViewController;
@property (strong, nonatomic) INPopoverController *statementSelectionPopover;

@end

@implementation PCBehaviourListViewController

#pragma mark - Super

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollContent.wantsLayer = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveWhensToNewIndex:) name:PCBehaviourWhenMovedNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PCBehaviourWhenMovedNotification object:nil];
}

- (void)setBehaviourList:(PCBehaviourList *)behaviourList {
    _behaviourList.delegate = nil;
    _behaviourList = behaviourList;
    _behaviourList.delegate = self;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self updateInstructionUI];

    NSView *previousView;
    NSView *previousMatchingView;
    for (id when in self.behaviourList.whens) {
        BOOL matchesFilter = !self.filteredWhens || [self.filteredWhens containsObject:when];

        PCWhenInfo *info = [self whenInfoForWhen:when];
        if (!info) {
            info = [[PCWhenInfo alloc] init];
            info.when = when;
            [self.whenInfos addObject:info];

            info.viewController = [self createWhenViewControllerForWhen:when];
            [info.viewController.view setFrame:NSMakeRect(0, 0, self.scrollContent.bounds.size.width, 0)];
            [self.scrollContent addSubview:info.viewController.view];
            [self addChildViewController:info.viewController];
        }
        else {
            if (!info.needsUpdateConstraints) {
                previousView = info.viewController.view;
                if (matchesFilter) {
                    previousMatchingView = info.viewController.view;
                }
                continue;
            };

            [self.scrollContent removeConstraints:info.constraints];
        }

        info.constraints = [self constraintsForWhenView:info.viewController.view withPreviousView:previousView previousMatchingView:previousMatchingView matchesFilter:matchesFilter];
        [self.scrollContent addConstraints:info.constraints];
        previousView = info.viewController.view;
        if (matchesFilter) {
            previousMatchingView = info.viewController.view;
        }
    }
    if (self.bottomConstraints) {
        [self.scrollContent removeConstraints:self.bottomConstraints];
    }
    if (previousMatchingView) {
        self.bottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastView]-(10)-|" options:0 metrics:nil views:@{ @"lastView": previousMatchingView }];
        [self.scrollContent addConstraints:self.bottomConstraints];
    }
}

#pragma mark - Actions

- (IBAction)search:(NSSearchField *)sender {
    
    for (id when in self.behaviourList.whens) {
        PCWhenInfo *info = [self whenInfoForWhen:when];
        PCWhenView *view = (PCWhenView *)info.viewController.view;
        view.hidden = NO;
        view.allowDrag = YES; // re-enable dragging if needed
    }
    
    self.filteredWhens = [[self filteredWhens:sender.stringValue] mutableCopy];
    [self invalidateAllWhenConstraints];
    [self updateConstraintsWithAnimation:^{} completion:^{
        if (self.filteredWhens) {
            for (id when in self.behaviourList.whens) {
                if (![self.filteredWhens containsObject:when]) {
                    PCWhenInfo *info = [self whenInfoForWhen:when];
                    NSView *view = info.viewController.view;
                    view.hidden = YES;
                }
            }
            
            // make sure to disable dragging when we have filter on
            for (id when in self.behaviourList.whens) {
                PCWhenInfo *info = [self whenInfoForWhen:when];
                PCWhenView *view = (PCWhenView *)info.viewController.view;
                view.allowDrag = NO;
            }
        }
    }];
}

#pragma mark - Events

- (void)moveDown:(id)sender {
    [self selectWhenInfo:[self nextWhenInfoForInfo:[self selectedWhenInfo]]];
}

- (void)moveUp:(id)sender {
    [self selectWhenInfo:[self previousWhenInfoForInfo:[self selectedWhenInfo]]];
}

#pragma mark - Public

- (void)loadCard:(PCSlide *)card {
    [self clearSearchField];
    [self loadBehaviourList:card.behaviourList];
}

- (void)validate {
    [self.behaviourList validate];
}

- (void)pasteWhen:(PCWhen *)when {
    NSInteger whenIndex = [self selectedWhenIndex];
    if (whenIndex == NSNotFound) whenIndex = [self indexOfWhenInfoIdenticalToWhen:when];
    whenIndex = (whenIndex == NSNotFound ? self.behaviourList.whens.count : whenIndex + 1);
    [when regenerateUUIDs];
    [self.behaviourList insertWhen:when atIndex:whenIndex];
    [self.behaviourList validate];
}

- (void)pasteThen:(PCThen *)then {
    NSInteger whenIndex = [self selectedWhenIndex];
    if (whenIndex == NSNotFound) whenIndex = [self whenIndexContainingMatchingThen:then];
    if (whenIndex == NSNotFound) return;
    [then regenerateUUIDs];
    PCWhenInfo *whenInfo = self.whenInfos[whenIndex];
    NSInteger selectedThenIndex = [whenInfo.viewController selectedThenIndex];
    NSInteger newThenIndex = (selectedThenIndex == NSNotFound ? whenInfo.when.thens.count : selectedThenIndex + 1);
    [whenInfo.when insertThen:then atIndex:newThenIndex];
    [self.behaviourList validate];
}

#pragma mark - Private

- (void)updateInstructionUI {
    self.emptyInstructionsView.hidden = [self.behaviourList.whens count] > 0;
    self.noResultsView.hidden = (!self.emptyInstructionsView.hidden
                                 || !self.filteredWhens
                                 || [self.filteredWhens count] > 0);
}

- (NSArray *)filteredWhens:(NSString *)filter {
    NSArray *filters = [filter componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    filters = [filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    if (filters.count == 0) return nil;

    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    for (NSString *filter in filters) {
        NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(PCWhen *when, NSDictionary *bindings) {
            return [when matchesSearch:filter];
        }];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ predicate, filterPredicate ]];
    }

    return [self.behaviourList.whens filteredArrayUsingPredicate:predicate];
}

- (void)loadBehaviourList:(PCBehaviourList *)list {
    if (self.behaviourList) {
        for (PCWhenInfo *info in self.whenInfos) {
            [self.scrollContent removeConstraints:info.constraints];
            [info.viewController.view removeFromSuperview];
            [info.viewController removeFromParentViewController];
        }
    }

    self.behaviourList = list;
    if (!self.behaviourList) {
        self.behaviourList = [[PCBehaviourList alloc] init];
    }
    [self.behaviourList invalidate];
    self.whenInfos = [NSMutableArray array];
    [self.view setNeedsUpdateConstraints:YES];

    [self validate];
}

- (void)saveBehaviourListToURL:(NSURL *)URL {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.behaviourList];
    [data writeToURL:URL atomically:YES];
}

- (IBAction)showAddWhenSelection:(NSView *)sender {
    if (self.statementSelectionPopover) {
        return;
    }

    PCStatementSelectionViewController *viewController = [[PCStatementSelectionViewController alloc] init];
    viewController.style = PCStatementSelectStyleWhen;
    viewController.statements = [[PCStatementRegistry sharedInstance] instancesOfAllWhenStatements];
    self.statementSelectionPopover = [[INPopoverController alloc] initWithContentViewController:viewController];
    self.statementSelectionPopover.animates = NO;
    self.statementSelectionPopover.delegate = self;
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.statementSelectionPopover) weakPopover = self.statementSelectionPopover;
    [viewController setSelectionHandler:^(PCStatement *statement) {
        [weakPopover closePopover:weakSelf];
        weakSelf.statementSelectionPopover = nil;

        if (!statement) return;
        PCWhen *when = [[PCWhen alloc] init];
        when.statement = statement;
        [weakSelf.behaviourList insertWhen:when atIndex:0];
    }];
    [self.statementSelectionPopover presentPopoverFromRect:sender.frame inView:sender.superview preferredArrowDirection:INPopoverArrowDirectionUp anchorsToPositionView:YES];
}

- (void)insertWhen:(PCWhen *)when atIndex:(NSInteger)index {
    // clamp index
    if (index < 0) index = 0;
    if (index > self.whenInfos.count) index = self.whenInfos.count;

    if (self.view.window.firstResponder == self.searchField) {
        [self.view.window makeFirstResponder:self];
    }

    PCWhenViewController *whenViewController = [self createWhenViewControllerForWhen:when];

    PCWhenInfo *info = [[PCWhenInfo alloc] init];
    info.when = when;
    info.viewController = whenViewController;
    [self.whenInfos insertObject:info atIndex:index];

    [self invalidateConstraintsForWhenInfo:[self previousWhenInfoForInfo:info]];
    [self invalidateConstraintsForWhenInfo:[self nextWhenInfoForInfo:info]];

    [self.scrollContent addSubview:whenViewController.view];
    [self addChildViewController:whenViewController];

    NSArray *constraints = [self initialConstraintsForWhen:when];
    [self.scrollContent addConstraints:constraints];

    info.constraints = constraints;
    info.needsUpdateConstraints = YES;

    [self clearSearchField];

    // These seems gross but the first layout pass calculates the correct height
    // and the second pass gives us our correct final layout
    [self.view layoutSubtreeIfNeeded];
    [self.view setNeedsLayout:YES];
    [self.view layoutSubtreeIfNeeded];

    [self updateConstraintsWithAnimation:^{} completion:^{
        [self selectWhenInfo:info];
    }];
}

- (void)invalidateAllWhenConstraints {
    for (PCWhenInfo *info in self.whenInfos) {
        info.needsUpdateConstraints = YES;
    }
}

- (void)invalidateConstraintsForWhenInfo:(PCWhenInfo *)info {
    if (!info) return;
    info.needsUpdateConstraints = YES;
}

- (void)updateConstraintsWithAnimation:(dispatch_block_t)animation completion:(dispatch_block_t)completion {
    [self.view setNeedsUpdateConstraints:YES];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = PCBehaviourListAnimationInterval;
        context.allowsImplicitAnimation = YES;
        [self.view layoutSubtreeIfNeeded];
        if (animation) animation();
    } completionHandler:completion];
}

- (PCWhenViewController *)createWhenViewControllerForWhen:(id)when {
    PCWhenViewController *whenViewController = [[PCWhenViewController alloc] init];
    whenViewController.when = when;
    __weak typeof(self) weakSelf = self;
    __weak typeof(whenViewController) weakWhenViewController = whenViewController;
    [whenViewController setDeleteHandler:^{
        [weakSelf.behaviourList removeWhen:when];
    }];
    [whenViewController setDidFocusRectHandler:^(CGRect rect) {
        rect = [weakSelf.scrollView.contentView convertRect:rect fromView:weakWhenViewController.view];
        if (!CGRectContainsRect([weakSelf.scrollView.contentView visibleRect], rect)) {
            [weakSelf.scrollView.contentView scrollRectToVisible:rect];
        }
    }];
    return whenViewController;
}

- (void)deleteWhen:(id)when {
    PCWhenInfo *info = [self whenInfoForWhen:when];
    if (!info) return;

    PCWhenInfo *previousInfo = [self previousWhenInfoForInfo:info];
    PCWhenInfo *nextInfo = [self nextWhenInfoForInfo:info];

    [self invalidateConstraintsForWhenInfo:previousInfo];
    [self invalidateConstraintsForWhenInfo:nextInfo];

    PCWhenViewController *viewController = info.viewController;
    if (viewController.view.window.firstResponder == viewController) {
        [viewController.view.window makeFirstResponder:self];
    }

    [self.scrollContent removeConstraints:info.constraints];
    [self.filteredWhens removeObject:when];
    [self.whenInfos removeObject:info];

    NSArray *constraints = [self finalConstraintsForWhenView:viewController.view];
    [self.scrollContent addConstraints:constraints];

    [self updateConstraintsWithAnimation:^{
        viewController.view.alphaValue = 0;
        if (nextInfo) {
            [self selectWhenInfo:nextInfo];
        }
        else {
            [self selectWhenInfo:previousInfo];
        }
    } completion:^{
        [self.scrollContent removeConstraints:constraints];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }];
}

- (void)moveWhen:(id)when toIndex:(NSInteger)index {
    PCWhenInfo *info = [self whenInfoForWhen:when];
    if (!info) return;
    
    // invalidate everything just to make sure all the connected neighbours are refreshed
    [self invalidateAllWhenConstraints];
    [self.view layoutSubtreeIfNeeded];
    
    // change the index in the whenInfos
    [self.whenInfos removeObject:info];
    [self.whenInfos insertObject:info atIndex:index];    
    
    [self updateConstraintsWithAnimation:^{
    } completion:^{
    }];
}

- (PCWhenInfo *)previousWhenInfoForInfo:(PCWhenInfo *)info {
    NSInteger index = [self.whenInfos indexOfObject:info];
    if (index == NSNotFound || index < 0) return nil;
    index -= 1;
    if (index < 0 || index >= self.whenInfos.count) return nil;
    return self.whenInfos[index];
}

- (PCWhenInfo *)nextWhenInfoForInfo:(PCWhenInfo *)info {
    NSInteger index = [self.whenInfos indexOfObject:info];
    if (index == NSNotFound || index < 0) return nil;
    index += 1;
    if (index >= self.whenInfos.count) return nil;
    return self.whenInfos[index];
}

- (void)selectWhenInfo:(PCWhenInfo *)whenInfo {
    if (!whenInfo) return;

    PCWhenViewController *viewController = whenInfo.viewController;
    [viewController.view.window makeFirstResponder:viewController];

    CGRect rect = viewController.view.frame;
    if (!CGRectContainsRect([self.scrollView.contentView visibleRect], rect)) {
        [self.scrollView.contentView scrollRectToVisible:rect];
    }
}

- (PCWhenInfo *)selectedWhenInfo {
    for (PCWhenInfo *info in self.whenInfos) {
        if (info.viewController.selected) {
            return info;
        }
    }
    return nil;
}

- (PCWhenInfo *)whenInfoForWhen:(PCWhen *)when {
    for (PCWhenInfo *info in self.whenInfos) {
        if (info.when == when) {
            return info;
        }
    }
    return nil;
}

- (NSInteger)indexOfWhenInfoIdenticalToWhen:(PCWhen *)when {
    for (NSUInteger index = 0; index < self.whenInfos.count; index++) {
        PCWhenInfo *info = self.whenInfos[index];
        if ([info.when isEqualTo:when]) {
            return index;
        }
    }
    return NSNotFound;
}

- (NSInteger)selectedWhenIndex {
    for (NSUInteger index = 0; index < self.whenInfos.count; index++) {
        PCWhenInfo *info = self.whenInfos[index];
        if (info.viewController.selected || [info.viewController hasThenSelected]) {
            return index;
        }
    }
    return NSNotFound;
}

- (NSInteger)whenIndexContainingMatchingThen:(PCThen *)then {
    for (NSUInteger index = 0; index < self.whenInfos.count; index++) {
        PCWhenInfo *info = self.whenInfos[index];
        if ([info.when containsThenMatching:then]) {
            return index;
        }
    }
    return NSNotFound;
}

- (PCWhenInfo *)selectedWhenInfoForDragging {
    if ([self selectedWhenInfo]) return [self selectedWhenInfo];
    for (PCWhenInfo *info in self.whenInfos) {
        if ([info.viewController hasThenSelected]) return info;
    }
    return nil;
}

#pragma mark - UI

- (void)clearSearchField {
    if ([self.searchField.stringValue length] == 0) return;

    self.searchField.stringValue = @"";
    [self search:self.searchField];
}

#pragma mark Constraints

- (NSArray *)constraintsForWhenView:(NSView *)view withPreviousView:(NSView *)previousView previousMatchingView:(NSView *)previousMatchingView matchesFilter:(BOOL)matchesFilter {

    NSView *container = self.scrollContent;
    view.alphaValue = matchesFilter ? 1 : 0;

    NSMutableArray *constraints = [NSMutableArray array];

    // Equal width to container minus padding
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeWidth multiplier:1 constant:-PCWhenHorizontalPadding * 2]];

    if (matchesFilter) {
        // Center horizontally in container
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    }
    else {
        // Hide off to the left
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
    }
    
    if (!previousMatchingView) {
        NSString *format = matchesFilter ? @"V:|-(padding)-[view]" : @"V:|-(padding)-[view]";
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:@{ @"padding": @(PCWhenVerticalPadding) } views:@{ @"view": view }]];
    }
    else {
        NSString *format = matchesFilter ? @"V:[previousView]-(padding)-[view]" : @"V:[previousView]-(padding)-[view]";
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:@{ @"padding": @(PCWhenVerticalPadding) } views:@{ @"view": view, @"previousView": previousMatchingView }]];
    }
    return constraints;
}

- (NSArray *)initialConstraintsForWhen:(PCWhen *)when {
    PCWhenInfo *info = [self whenInfoForWhen:when];
    NSView *whenView = info.viewController.view;
    NSView *container = self.scrollContent;

    PCWhenInfo *previousInfo = [self previousWhenInfoForInfo:info];

    NSMutableArray *constraints = [NSMutableArray array];

    // Equal width to container with minus padding
    [constraints addObject:[NSLayoutConstraint constraintWithItem:whenView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeWidth multiplier:1 constant:-PCWhenHorizontalPadding * 2]];

    if (!previousInfo) {
        // Center horizontally in container
        [constraints addObject:[NSLayoutConstraint constraintWithItem:whenView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

        // Hide up above
        [constraints addObject:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:whenView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    else {
        // Hide off to the left
        [constraints addObject:[NSLayoutConstraint constraintWithItem:whenView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];

        // Vertical position
        NSView *previousView = previousInfo.viewController.view;
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-(padding)-[view]" options:0 metrics:@{ @"padding": @(PCWhenVerticalPadding) } views:@{ @"view": whenView, @"previousView": previousView }]];
    }

    return constraints;
}

- (NSArray *)finalConstraintsForWhenView:(NSView *)view {
    NSMutableArray *constraints = [NSMutableArray array];
    NSView *container = self.scrollContent;

    // Equal width to container minus padding
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeWidth multiplier:1 constant:-PCWhenHorizontalPadding * 2]];

    // Hide off to the left
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];

    // Just maintain current y
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(yOrigin)-[view]" options:0 metrics:@{ @"yOrigin": @(view.frame.origin.y) } views:@{ @"view": view }]];

    return constraints;
}

#pragma mark - INPopoverControllerDelegate

- (BOOL)popoverShouldClose:(INPopoverController *)popover {
    if (popover == self.statementSelectionPopover) {
        self.statementSelectionPopover = nil;
        return YES;
    }
    return NO;
}

#pragma mark - PCBehaviourListDelegate

- (void)didAddWhen:(PCWhen *)when atIndex:(NSInteger)index {
    [self insertWhen:when atIndex:index];
}

- (void)didRemoveWhen:(PCWhen *)when {
    [self deleteWhen:when];
}

- (void)didMoveWhen:(PCWhen *)when toIndex:(NSInteger)index {
    [self moveWhen:when toIndex:index];
}

#pragma mark - PCBehaviourWhenMovedNotification

- (void)moveWhensToNewIndex:(NSNotification *)notification {
    // new index of the selected when we wanted to place in the current array
    // (include existed one, so it is as if there will be 2 selected when)
    NSInteger newIndex = [notification.userInfo[PCBehaviourWhenMovedIndexKey] integerValue];
    
    PCWhenInfo *selectedInfo = [self selectedWhenInfoForDragging];
    
    if (selectedInfo == nil) return; // just return if we can't find selected info
    
    NSInteger currentIndex = [self.whenInfos indexOfObject:selectedInfo];
    
    if (currentIndex == newIndex) return; // if we are moving to the exact same index, just quit
    
    if (currentIndex < newIndex) {
        // if we are moving ahead in the list, we have to remove ourself first, so the index is minus 1
        newIndex--;
        if (currentIndex == newIndex) return; // if we are moving to the exact same index, just quit
    }

    [self.behaviourList moveWhen:selectedInfo.when toIndex:newIndex];
}

@end
