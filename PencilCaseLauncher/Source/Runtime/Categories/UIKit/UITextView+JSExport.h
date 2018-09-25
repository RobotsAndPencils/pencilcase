//
//  UITextView+JSExport.h
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-10.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import <UIKit/UIKit.h>
#import "NSObject+JSDataBinding.h"

@protocol UITextViewExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;    // default is NSLeftTextAlignment
@property (nonatomic) NSRange selectedRange;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, getter=isSelectable) BOOL selectable; // toggle selectability, which controls the ability of the user to select content and interact with URLs & attachments
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;

@property (nonatomic) BOOL allowsEditingTextAttributes; // defaults to NO
@property (nonatomic, copy) NSAttributedString *attributedText; // default is nil
@property (nonatomic, copy) NSDictionary *typingAttributes; // automatically resets when the selection changes

- (void)scrollRangeToVisible:(NSRange)range;

// Presented when object becomes first responder.  If set to nil, reverts to following responder chain.  If
// set while first responder, will not take effect until reloadInputViews is called.
@property (readwrite, retain) UIView *inputView;
@property (readwrite, retain) UIView *inputAccessoryView;

@property (nonatomic) BOOL clearsOnInsertion; // defaults to NO. if YES, the selection UI is hidden, and inserting text will replace the contents of the field. changing the selection will automatically set this to NO.

// Create a new text view with the specified text container (can be nil) - this is the new designated initializer for this class
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer NS_AVAILABLE_IOS(7_0);

// Get the text container for the text view
@property (nonatomic, readonly) NSTextContainer *textContainer;
// Inset the text container's layout area within the text view's content area
@property (nonatomic, assign) UIEdgeInsets textContainerInset;

// Convenience accessors (access through the text container)
@property (nonatomic, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, readonly, retain) NSTextStorage *textStorage;

// Style for links
@property (nonatomic, copy) NSDictionary *linkTextAttributes;

@end

@interface UITextView (JSExport) <UITextViewExport>

@end
