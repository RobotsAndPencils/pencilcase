//
//  SKNode+JSExport.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-20.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "SKNode+JSExport.h"
#import "SKNode+PhysicsExport.h"
#import "PCPhysicsBodyParameters.h"
#import "PCPhysicsWrapperNode.h"
#import <objc/runtime.h>
#import "PCSlideNode.h"
#import "PCContextCreation.h"

@implementation SKNode (JSExport)

- (CGPoint)scalePoint {
    return CGPointMake(self.xScale, self.yScale);
}

- (void)setScalePoint:(CGPoint)scalePoint {
    self.xScale = scalePoint.x;
    self.yScale = scalePoint.y;
}

- (void)setPhysicsEnabled:(BOOL)physicsEnabled {
    if (self.physicsEnabled == physicsEnabled) return;

    PCPhysicsWrapperNode *wrapper = self.pc_physicsWrapperNode;
    if (physicsEnabled && !wrapper) {
        wrapper = [[PCPhysicsWrapperNode alloc] initWithNode:self physicsBodyParameters:[PCPhysicsBodyParameters defaultPhysicsParamsForNode:self]];
        [self.parent addChild:wrapper];
    }
    wrapper.enabled = physicsEnabled;
}

- (BOOL)physicsEnabled {
    return self.pc_physicsWrapperNode && self.pc_physicsWrapperNode.enabled;
}

@end
