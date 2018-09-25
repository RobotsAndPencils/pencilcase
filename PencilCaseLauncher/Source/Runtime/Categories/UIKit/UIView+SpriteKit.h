//
//  UIView+SpriteKit.h
//  PencilCaseJSDemo
//
//  Created by Brandon on 12/27/2013.
//  Copyright (c) 2013 Robots and Pencils. All rights reserved.
//

@import UIKit;
@import SpriteKit;
@import JavaScriptCore;

@interface UIView (SpriteKit)

@property (assign, nonatomic) BOOL affectedByGravity;

- (void)runAction:(SKAction *)action;
- (void)runAction:(SKAction *)action completion:(JSValue *)block;

@end
