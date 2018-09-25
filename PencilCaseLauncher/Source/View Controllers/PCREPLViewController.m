//
//  PCREPLViewController.m
//  PCPlayer
//
//  Created by Brandon on 2014-03-24.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCREPLViewController.h"

static const NSInteger PCHistoryIndexLineInProgress = -1;

@interface PCREPLViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (copy, nonatomic) NSMutableString *log;
@property (strong, nonatomic) NSMutableOrderedSet *history;
@property (assign, nonatomic) NSInteger historyIndex;
@property (copy, nonatomic) NSString *historySavedLineInProgress;

@end

@implementation PCREPLViewController

- (instancetype)init {
    self = [super initWithNibName:@"PCREPLView" bundle:nil];
    if (self) {
        _log = [NSMutableString string];
        _history = [[NSMutableOrderedSet alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];

    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, CGRectGetHeight(self.textField.frame))];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.leftView = leftPaddingView;
    self.textView.text = self.log;
}

- (NSArray *)keyCommands {
    return @[
             [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(fillPreviousCommandFromHistory)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(fillNextCommandFromHistory)],
             ];
}

#pragma mark - Public

- (void)printLine:(NSString *)text {
    NSString *newLineText = [@"\n" stringByAppendingString:text];
    [self log:newLineText];
}

#pragma mark - Actions

- (IBAction)closeREPL:(id)sender {
    [self.textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(replShouldDismiss)]) {
        [self.delegate replShouldDismiss];
    }
}

- (void)fillPreviousCommandFromHistory {
    if (self.historyIndex == PCHistoryIndexLineInProgress) {
        self.historySavedLineInProgress = self.textField.text;
    }
    if ([self.history count] > self.historyIndex + 1) {
        self.historyIndex += 1;
        self.textField.text = self.history[self.historyIndex];
    }
}

- (void)fillNextCommandFromHistory {
    if ([self.history count] > self.historyIndex - 1) {
        self.historyIndex -= 1;
        self.textField.text = self.history[self.historyIndex];
    }
    else {
        self.historyIndex = PCHistoryIndexLineInProgress;
        self.textField.text = self.historySavedLineInProgress;
    }
}

#pragma mark - Private

- (void)log:(NSString *)text {
    [self.log appendString:text];
    [self.textView insertText:text];
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 0)];
}

- (void)addCommandToHistory:(NSString *)text {
    [self.history removeObject:text];
    [self.history insertObject:text atIndex:0];
    self.historyIndex = PCHistoryIndexLineInProgress;
    self.historySavedLineInProgress = @"";
}

- (BOOL)handleCommand:(NSString *)text {
    if ([text isEqualToString:@"clear"]) {
        [self.log deleteCharactersInRange:NSMakeRange(0, self.log.length)];
        self.textView.text = @"";
        return YES;
    }
    return NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL handledInternally = [self handleCommand:textField.text];
    if (!handledInternally && self.textInputHandler) {
        JSValue *result = self.textInputHandler(textField.text);
        [self printLine:[NSString stringWithFormat:@"%@", result]];
    }

    [self addCommandToHistory:textField.text];
    textField.text = @"";
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(replDidResignFirstResponder)]) {
        [self.delegate replDidResignFirstResponder];
    }
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    self.bottomConstraint.constant = frame.size.height;
    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    self.bottomConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
