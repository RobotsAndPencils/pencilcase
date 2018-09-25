//
//  PCTextInputView.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-04-24.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCTextInputView.h"
#import "SKNode+SFGestureRecognizers.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "PCOverlayView.h"
#import "SKNode+JavaScript.h"
#import "PCJSContext.h"
#import "PCScene.h"
#import "PCAppViewController.h"

@interface PCTextInputView () <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) SKSpriteNode *background;
@property (assign, nonatomic) BOOL keyboardIsShown;
@property (assign, nonatomic) CGFloat keyboardHeight;

@end

@implementation PCTextInputView

- (id)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;

        _background = [[SKSpriteNode alloc] initWithTexture:nil color:[UIColor whiteColor] size:CGSizeMake(10, 10)];
        _background.colorBlendFactor = 1;
        [self addChild:_background];

        _textView = [self createTextView];
    }
    return self;
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_presentationCompleted {
    [super pc_presentationCompleted];
    [self addTapGestureToEdit];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [self removeAllGestureRecognizers];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

- (void)touchUpInside:(UITouch *)touch withEvent:(UIEvent*)event {
    [self startEditing];
}

#pragma mark - Private

- (UITextView *)createTextView {
    UITextView *textView = [[UITextView alloc] init];
    textView.scrollEnabled = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.delegate = self;
    return textView;
}

- (void)startEditing {
    [self.textView becomeFirstResponder];
}

- (void)addTapGestureToEdit {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startEditing)];
    tapGesture.cancelsTouchesInView = NO;
    [self sf_addGestureRecognizer:tapGesture];
}

- (void)removeAllGestureRecognizers {
    for (UIGestureRecognizer *gesture in self.sf_gestureRecognizers) {
        [self sf_removeGestureRecognizer:gesture];
    }
}

- (void)layout {
    if (!self.background.texture) return;

    self.background.size = self.background.texture.size;
    self.background.xScale = self.contentSize.width / self.background.contentSize.width;
    self.background.yScale = self.contentSize.height / self.background.contentSize.height;
    [self.background pc_centerInParent];
}

#pragma mark - Properties

- (void)setText:(NSString *)text {
    if (![text isEqual:_text]) {
        _text = text;
        self.textView.text = text;
    }
}

- (void)setFontName:(NSString *)fontName {
    if (![fontName isEqual:_fontName]) {
        _fontName = fontName;
        CGFloat size = self.textView.font ? self.textView.font.pointSize : 17;
        self.textView.font = [UIFont fontWithName:fontName size:size];
    }
}

- (void)setFontSize:(CGFloat)fontSize {
    if (fontSize != _fontSize) {
        _fontSize = fontSize;
        NSString *fontName = self.textView.font ? self.textView.font.fontName : @"Helvetica";
        self.textView.font = [UIFont fontWithName:fontName size:fontSize];
    }
}

- (void)setBackgroundSpriteFrame:(SKTexture *)texture {
    self.background.texture = texture;
    if (texture) {
        self.background.centerRect = CGRectMake(0.45, 0.45, .1, .1);
    }
    else {
        self.background.centerRect = CGRectMake(0, 0, 1, 1);
    }
    [self layout];
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self layout];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.textView.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.text = self.textView.text;
    [[PCAppViewController lastCreatedInstance] nodeDidFinishEditingText:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
                                                                PCJSContextEventNotificationEventNameKey: @"editingFinished",
                                                                PCJSContextEventNotificationArgumentsKey: @[]
                                                               }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [[PCAppViewController lastCreatedInstance] nodeDidBeginEditingText:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"editingBegan",
        PCJSContextEventNotificationArgumentsKey: @[]
    }];
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.textView;
}

@end
