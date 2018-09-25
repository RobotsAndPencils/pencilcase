//
//  PCTextView+JSExport.h
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-10.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCTextView.h"
#import "NSObject+JSDataBinding.h"

@protocol PCTextViewExport <JSExport, NSObjectJSDataBindingExport>

@property (copy, nonatomic) NSString *rtfContent;
@property (copy, nonatomic) NSString *string;
@property (strong, nonatomic) UITextView *textView;

@end

@interface PCTextView (JSExport) <PCTextViewExport>

@end
