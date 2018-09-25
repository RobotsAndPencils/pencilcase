//
//  PCTextInputView+JSExport.h
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2014-05-07.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//


@import JavaScriptCore;
#import "PCTextInputView.h"
#import "NSObject+JSDataBinding.h"

@protocol PCTextInputViewExport <JSExport, NSObjectJSDataBindingExport>

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *fontName;
@property (assign, nonatomic) CGFloat fontSize;
@property (strong, nonatomic) SKTexture *backgroundSpriteFrame;

@end


@interface PCTextInputView (JSExport) <PCTextInputViewExport>

@end
