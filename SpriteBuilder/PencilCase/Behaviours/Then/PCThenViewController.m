//
//  PCThenViewController.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCThenViewController.h"
#import "PCThenBackgroundView.h"
#import "PCAddThenButton.h"
#import "PCThen.h"
#import "PCWhen.h"
#import "PCThenView.h"
#import "PCExpressionTextView.h"
#import "PCStatement.h"
#import "PCExpressionViewController.h"
#import "PCExpressionInspector.h"
#import "Constants.h"
#import "PCToken.h"
#import "NSUndoManager+ConditionalActionName.h"
#import "Constants.h"
#import "NSAttributedString+MutationHelpers.h"
#import "PCRunJavaScriptStatement.h"

@interface PCThenViewController () <NSTextViewDelegate, NSPopoverDelegate, PCThenDelegate>

@property (weak, nonatomic) IBOutlet PCThenView *thenView;
@property (weak, nonatomic) IBOutlet PCThenBackgroundView *thenBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundBottomConstraint;
@property (unsafe_unretained) IBOutlet PCExpressionTextView *expressionTextView;

@property (strong, nonatomic) PCExpressionViewController *expressionViewController;
@property (strong, nonatomic) NSPopover *expressionPopover;
@property (assign, nonatomic) BOOL shouldSaveExpressionOnDismiss; // We save if you click away to dismiss the popover but don't want to save if you click cancel. This state is needed to know the difference.

@end

@implementation PCThenViewController

@synthesize selected = _selected;


- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:PCTokenHighlightSourceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
            NSUUID *sourceUUID = notification.userInfo[PCTokenHighlightSourceUUIDKey];
            if (![weakSelf.then.statement.UUID isEqual:sourceUUID]) return;

            BOOL state = [notification.userInfo[PCTokenHighlightSourceStateKey] boolValue];
            NSColor *color = [(PCToken *)notification.object hoverColor];
            weakSelf.thenBackgroundView.sourceHighlightColor = color;
            weakSelf.thenBackgroundView.isSourceHighlighted = state;
        }];
    }
    return self;
}

- (void)dealloc {
    self.expressionPopover.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];

    self.view.layer.masksToBounds = NO;
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    [self closePopover];
}

- (IBAction)attachToNextThen:(id)sender {
    if (self.thenBackgroundView.hideBottomConnector) return;
    if (self.connectWithNextThenHandler) self.connectWithNextThenHandler();
}

- (void)updateUI {
    if (![self.expressionTextView.textStorage isEqual:[self.then.statement attributedString]]) {
        [self.expressionTextView.textStorage setAttributedString:[self.then.statement attributedString]];
        [self.expressionTextView.layoutManager ensureLayoutForTextContainer:self.expressionTextView.textContainer];
        [self.expressionTextView invalidateIntrinsicContentSize];
    }

    self.expressionTextView.editable = NO;
    self.expressionTextView.selectable = NO;
    self.expressionTextView.drawsBackground = NO;
    self.expressionTextView.delegate = self;
    self.expressionTextView.allowsUndo = NO;

    PCThen *previousThen = [self.then.when previousThenForThen:self.then];
    PCThen *nextThen = [self.then.when nextThenForThen:self.then];
    self.thenBackgroundView.topConnected = self.then.runWithPrevious;
    self.thenBackgroundView.bottomConnected = nextThen.runWithPrevious;
    self.thenBackgroundView.hideTopConnector = !previousThen.canRunWithNext || !self.then.canRunWithPrevious;
    self.thenBackgroundView.hideBottomConnector = !nextThen.canRunWithPrevious || !self.then.canRunWithNext;

    [self updateSelectedUI];
}

- (void)updateSelectedUI {
    self.thenBackgroundView.selected = self.selected;
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
    [self closePopover];
    if (self.deleteHandler) self.deleteHandler();
}

- (void)closePopover {
    if (self.expressionPopover.shown) {
        [self.expressionPopover close];
    }
}

#pragma mark - Private

#pragma mark - Copy/Paste

- (void)copy:(id)sender {
    [self.then copyToPasteboard];
}

- (void)cut:(id)sender {
    [self.then copyToPasteboard];
    [self deleteBackward:nil];
}

#pragma mark - PCBehaviourController

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateSelectedUI];
    if (self.selectionChangeHandler) self.selectionChangeHandler();
}

#pragma mark - Properties

- (void)setThen:(PCThen *)then {
    _then.delegate = nil;
    _then = then;
    _then.delegate = self;
}

#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    if (self.expressionPopover) return YES;

    PCExpression *expression = [self.then.statement expressionForLink:link];
    BOOL allowAdvanced = [self.then.statement allowAdvancedEntryForExpression:expression];
    NSViewController<PCExpressionInspector> *simpleInspector = [self.then.statement inspectorForExpression:expression];
    if (!simpleInspector) return YES;
    
    NSArray *suggestedTokens = [self.then.statement availableTokensForExpression:expression];
    self.expressionViewController = [[PCExpressionViewController alloc] initWithExpression:expression inspector:simpleInspector advancedAllowed:allowAdvanced suggestedTokens:suggestedTokens];

    self.expressionPopover = [[NSPopover alloc] init];
    self.expressionPopover.contentViewController = self.expressionViewController;
    self.expressionPopover.delegate = self;

    __weak typeof(self) weakSelf = self;
    __weak typeof(self.expressionPopover) weakPopover = self.expressionPopover;
    __weak typeof(self.expressionViewController) weakExpressionViewController = self.expressionViewController;
    self.shouldSaveExpressionOnDismiss = YES;
    [self.expressionViewController setFinishedHandler:^(BOOL save, PCExpression *expression, BOOL isSimple, NSArray *chunks) {
        weakSelf.shouldSaveExpressionOnDismiss = NO;
        [weakPopover close];
        weakSelf.expressionPopover = nil;
        if (save) {
            [weakSelf.then.statement updateExpression:expression withAdvancedChunks:chunks isSimpleMode:isSimple];
            weakExpressionViewController.simpleInspector.saveHandler(expression, weakExpressionViewController.simpleInspector);
            NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
            [undoManager setActionNameUndoGroupCreated:@"Change Then"];
        }
        [weakSelf.view.window makeFirstResponder:weakSelf];
    }];
    [self.expressionViewController setDidLayouthandler:^{
        weakPopover.contentSize = weakExpressionViewController.view.bounds.size;
    }];

    NSRange range = [self.then.statement rangeOfLink:link];
    CGRect rect = [textView.layoutManager boundingRectForGlyphRange:range inTextContainer:textView.textContainer];
    self.expressionPopover.animates = NO;
    self.expressionPopover.behavior = NSPopoverBehaviorSemitransient;
    [self.expressionPopover showRelativeToRect:rect ofView:textView preferredEdge:NSMaxYEdge];
    return YES;
}

- (void)setNextThenSelected:(BOOL)nextThenSelected {
    _nextThenSelected = nextThenSelected;
    self.thenBackgroundView.nextThenSelected = nextThenSelected;
}

#pragma mark - INPopoverControllerDelegate

- (BOOL)popoverShouldClose:(NSPopover *)popover {
    if (popover == self.expressionPopover && self.expressionViewController.shouldClose) {
        return YES;
    }
    return NO;
}

- (void)popoverDidClose:(NSNotification *)notification {
    if (self.shouldSaveExpressionOnDismiss) {
        [self.expressionViewController save];
    }
    [self.expressionViewController cleanupUndo];
    self.expressionViewController = nil;
    self.expressionPopover = nil;
}

#pragma mark - PCThenDelegate

- (void)thenNeedsDisplay:(PCThen *)then {
    [self updateUI];
}

@end
