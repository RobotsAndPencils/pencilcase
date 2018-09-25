//
//  PCScene.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-21.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PCUpdateNode.h"
#import "PCOverlayNode.h"

extern NSString *const PCDidEvaluateActionsNotification;
extern NSString *const PCDidSimulatePhysicsNotification;

@interface PCScene : SKScene

- (void)registerForUpdates:(id<PCUpdateNode>)object;
- (void)unregisterForUpdates:(id<PCUpdateNode>)object;

@end
