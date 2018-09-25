//
//  UIResponder+JSExport.h
//  PencilCaseJSDemo
//
//  Created by Brandon on 1/7/2014.
//  Copyright (c) 2014 RobotsAndPencils. All rights reserved.
//

@import UIKit;
@import JavaScriptCore;
#import "NSObject+JSDataBinding.h"

@protocol UIResponderExport <JSExport, NSObjectJSDataBindingExport>

- (UIResponder*)nextResponder;

- (BOOL)canBecomeFirstResponder;    // default is NO
- (BOOL)becomeFirstResponder;

- (BOOL)canResignFirstResponder;    // default is YES
- (BOOL)resignFirstResponder;

- (BOOL)isFirstResponder;

// Generally, all responders which do custom touch handling should override all four of these methods.
// Your responder will receive either touchesEnded:withEvent: or touchesCancelled:withEvent: for each
// touch it is handling (those touches it received in touchesBegan:withEvent:).
// *** You must handle cancelled touches to ensure correct behavior in your application.  Failure to
// do so is very likely to lead to incorrect behavior or crashes.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event;

- (void)remoteControlReceivedWithEvent:(UIEvent *)event;

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
// Allows an action to be forwarded to another target. By default checks -canPerformAction:withSender: to either return self, or go up the responder chain.
- (id)targetForAction:(SEL)action withSender:(id)sender;

@property(nonatomic,readonly) NSUndoManager *undoManager;

@property (nonatomic,readonly) NSArray *keyCommands; // returns an array of UIKeyCommand objects

// Called and presented when object becomes first responder.  Goes up the responder chain.
@property (readonly, retain) UIView *inputView;
@property (readonly, retain) UIView *inputAccessoryView;
/* When queried, returns the current UITextInputMode, from which the keyboard language can be determined.
 * When overridden it should return a previously-queried UITextInputMode object, which will attempt to be
 * set inside that app, but not persistently affect the user's system-wide keyboard settings. */
@property (readonly, retain) UITextInputMode *textInputMode;
/* When the first responder changes and an identifier is queried, the system will establish a context to
 * track the textInputMode automatically. The system will save and restore the state of that context to
 * the user defaults via the app identifier. Use of -textInputMode above will supercede use of -textInputContextIdentifier. */
@property (readonly, retain) NSString *textInputContextIdentifier;
// This call is to remove stored app identifier state that is no longer needed.
+ (void)clearTextInputContextIdentifier:(NSString *)identifier;

// If called while object is first responder, reloads inputView, inputAccessoryView, and textInputMode.  Otherwise ignored.
- (void)reloadInputViews;

@end

@interface UIResponder (JSExport)

@end
