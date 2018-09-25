//
//  UIControl+JSAction.h
//  PencilCaseJSDemo
//
//  Created by Brandon on 12/27/2013.
//  Copyright (c) 2013 Robots and Pencils. All rights reserved.
//

@import UIKit;
@import JavaScriptCore;

@interface UIControl (JSAction)

- (void)setTouchUpInsideHandler:(JSValue *)handler;

@end
