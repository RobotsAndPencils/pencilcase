//
//  PCTextField.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PCControl.h"
@import JavaScriptCore;

@interface PCTextField : PCControl

@property (strong, nonatomic, readonly) UITextField *textField;
@property (strong, nonatomic) SKTexture *backgroundSpriteFrame;
@property (assign, nonatomic) CGFloat fontSize;
@property (strong, nonatomic) NSString *string;
@property (assign, nonatomic) BOOL isSecureText;

- (void)addBeginEndHandlerForState:(NSNumber *)state handler:(JSValue *)handler;

@end
