//
//  UIView+SpriteKit.m
//  PencilCaseJSDemo
//
//  Created by Brandon on 12/27/2013.
//  Copyright (c) 2013 Robots and Pencils. All rights reserved.
//

#import "UIView+SpriteKit.h"
@import ObjectiveC;
@import JavaScriptCore;

@implementation UIView (SpriteKit)

- (void)runAction:(SKAction *)action {
    [self.node runAction:action];
}

- (BOOL)affectedByGravity {
    return self.node.physicsBody.affectedByGravity;
}

- (void)setAffectedByGravity:(BOOL)affectedByGravity {
    self.node.physicsBody.affectedByGravity = affectedByGravity;
}

static const char *ActionCompletionBlock = "ActionCompletionBlock";

- (void)runAction:(SKAction *)action completion:(JSValue *)block {
    objc_setAssociatedObject(self, &ActionCompletionBlock, block, OBJC_ASSOCIATION_RETAIN);
    [self.node runAction:action completion:^{
        JSValue *block = objc_getAssociatedObject(self, &ActionCompletionBlock);
        [block callWithArguments:@[]];
    }];
}

#pragma mark - Private

- (SKNode *)node {
    return objc_getAssociatedObject(self, "CLR_trackingNode");
}

@end
