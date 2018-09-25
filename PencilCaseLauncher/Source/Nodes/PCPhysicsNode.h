//
//  PCPhysicsNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PCPhysicsNode : SKSpriteNode

@property (assign, nonatomic) CGPoint gravity;
@property (assign, nonatomic) float sleepTimeThreshold;

@end
