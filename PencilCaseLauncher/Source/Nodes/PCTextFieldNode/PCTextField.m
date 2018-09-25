//
//  PCTextField.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCTextField.h"
#import "PCControlSubclass.h"
#import "PCOverlayView.h"
#import "PCOverlayNode.h"
#import <objc/runtime.h>
#import "SKNode+JavaScript.h"

#import "SKNode+CoordinateConversion.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "PCJSContext.h"
#import "PCAppViewController.h"

@interface PCTextField () <UITextFieldDelegate, PCOverlayNode>

@property (strong, nonatomic) SKSpriteNode *background;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIView *containerView;
@property (assign, nonatomic) BOOL keyboardIsShown;
@property (assign, nonatomic) CGRect keyboardFrame;
@property (assign, nonatomic) CGFloat keyboardHeight;
@property (strong, nonatomic) NSMutableArray *jsEditingHandlers;
@property (assign, nonatomic) UIKeyboardType keyboardType;
@property (assign, nonatomic) CGFloat padding;

@end

@implementation PCTextField

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.background = [[SKSpriteNode alloc] initWithTexture:nil color:[UIColor whiteColor] size:CGSizeMake(10, 10)];
    [self addChild:self.background];

    // Create UITextField and set it up
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.delegate = self;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.secureTextEntry = self.isSecureText;
    self.textField.keyboardType = self.keyboardType;

    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.textField];

    // Set default font size
    self.fontSize = 17;
    self.padding = 4;

    _jsEditingHandlers = [NSMutableArray array];
    [self setTarget:self selector:@selector(handleControlEvent)];
}

- (NSArray *)handlersForState:(BOOL)isEditing {
    NSArray *handlers = [NSArray array];
    for (NSDictionary *handlerDictionary in self.jsEditingHandlers) {
        BOOL desiredEditingState = ![handlerDictionary[@"state"] boolValue];
        if (desiredEditingState == isEditing) {
            handlers = [handlers arrayByAddingObject:handlerDictionary[@"managedHandler"]];
        }
    }
    return handlers;
}

- (void)handleControlEvent {
    for (JSManagedValue *managedHandler in [self handlersForState:self.textField.isEditing]) {
        [managedHandler.value callWithArguments:@[ self.textField.text, @(self.textField.isEditing) ]];
    }
}

#pragma mark - Public

- (void)addBeginEndHandlerForState:(NSNumber *)state handler:(JSValue *)handler {
    JSManagedValue *managedHandler = [JSManagedValue managedValueWithValue:handler andOwner:self];
    NSDictionary *handlerDictionary = @{ @"state": state, @"managedHandler": managedHandler };
    [self.jsEditingHandlers addObject:handlerDictionary];
}

- (void)focus {
    [self.textField becomeFirstResponder];
}

#pragma mark - Life Cycle

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Layout

- (void)layout {
    [super layout];

    self.textField.font = [self.textField.font fontWithSize:self.fontSize];

    if (self.background.texture) {
        self.background.contentSize = self.background.texture.size;
        self.background.xScale = self.contentSize.width / self.background.contentSize.width;
        self.background.yScale = self.contentSize.height / self.background.contentSize.height;
        self.background.centerRect = CGRectMake(0.45, 0.45, .1, .1);
    }
    else {
        self.background.centerRect = CGRectMake(0, 0, 1, 1);
    }
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self triggerAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"editingBegan",
        PCJSContextEventNotificationArgumentsKey: @[]
    }];
    [[PCAppViewController lastCreatedInstance] nodeDidBeginEditingText:self];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self triggerAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"editingFinished",
        PCJSContextEventNotificationArgumentsKey: @[]
    }];
    [[PCAppViewController lastCreatedInstance] nodeDidFinishEditingText:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Properties

- (void)setString:(NSString *)string {
    self.textField.text = string;
}

- (NSString *)string {
    return self.textField.text;
}

- (void)setBackgroundSpriteFrame:(SKTexture *)spriteFrame {
    self.background.texture = spriteFrame;
    [self setNeedsLayout];
}

- (SKTexture *)backgroundSpriteFrame {
    return self.background.texture;
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    [self setNeedsLayout];
}

- (void)setIsSecureText:(BOOL)isSecureText {
    _isSecureText = isSecureText;
    self.textField.secureTextEntry = isSecureText;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    self.textField.keyboardType = keyboardType;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.textField.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.containerView;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (!frameChanged) return;

    CGRect newFrame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds));
    if (CGRectGetWidth(newFrame) > self.padding) {
        newFrame.origin.x = self.padding;
        newFrame.size.width -= self.padding;
    }
    self.textField.frame = newFrame;
}

@end
