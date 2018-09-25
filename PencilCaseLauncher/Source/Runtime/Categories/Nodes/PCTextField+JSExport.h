//
//  PCTextField+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-03-24.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCTextField.h"
#import "NSObject+JSDataBinding.h"

@protocol PCTextFieldExport <JSExport, NSObjectJSDataBindingExport>

@property (strong, nonatomic, readonly) UITextField *textField;
@property (strong, nonatomic) SKTexture *backgroundSpriteFrame;
@property (assign, nonatomic) float fontSize;
@property (assign, nonatomic) float padding;
@property (strong, nonatomic) NSString *string;
@property (assign, nonatomic) BOOL isSecureText;
@property (assign, nonatomic) UIKeyboardType keyboardType;

- (void)focus;

@end

@interface PCTextField (JSExport) <PCTextFieldExport>

@end
