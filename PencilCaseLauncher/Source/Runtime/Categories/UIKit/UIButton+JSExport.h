//
//  UIButton+JSExport.h
//  PencilCaseJSDemo
//
//  Created by Brandon on 1/6/2014.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@import UIKit;
@import JavaScriptCore;
#import "NSObject+JSDataBinding.h"

@protocol UIButtonExport <JSExport, NSObjectJSDataBindingExport>

+ (id)buttonWithType:(UIButtonType)buttonType;

@property(nonatomic,retain)   UIColor     *tintColor;
@property(nonatomic,readonly) UIButtonType buttonType;

- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (NSString *)titleForState:(UIControlState)state;

@end

@interface UIButton (JSExport) <UIButtonExport>

@end
