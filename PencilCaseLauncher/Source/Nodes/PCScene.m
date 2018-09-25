//
//  PCScene.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-21.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCScene.h"
#import "PCJSContext.h"
#import "PCOverlayView.h"
#import "SKNode+LifeCycle.h"

NSString *const PCDidEvaluateActionsNotification = @"PCDidEvaluateActionsNotification";
NSString *const PCDidSimulatePhysicsNotification = @"PCDidSimulatePhysicsNotification";

@interface PCScene ()

@property (strong, nonatomic) NSMutableSet *updateNodes;

@end

@implementation PCScene

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        self.updateNodes = [NSMutableSet set];
        self.scaleMode = SKSceneScaleModeFill;
    }
    return self;
}


#pragma mark - Super

- (void)update:(NSTimeInterval)currentTime {
    [super update:currentTime];
    if (self.paused) return;
    for (id<PCUpdateNode>updateNode in self.updateNodes) {
        [updateNode update:currentTime];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"cardUpdate"
    }];
}

- (void)didEvaluateActions {
    [super didEvaluateActions];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCDidEvaluateActionsNotification object:nil];
}

- (void)didSimulatePhysics {
    [super didSimulatePhysics];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCDidSimulatePhysicsNotification object:nil];

    for (SKNode<PCUpdateNode> *node in self.updateNodes) {
        if (![node respondsToSelector:@selector(physicsDidSimulate)]) continue;
        [node physicsDidSimulate];
    }
}

- (void)didFinishUpdate {
    [super didFinishUpdate];
    [[PCOverlayView overlayView] updateTrackingNodePositions];
}

#pragma mark - Public

- (void)registerForUpdates:(id<PCUpdateNode>)object {
    [self.updateNodes addObject:object];
}

- (void)unregisterForUpdates:(id<PCUpdateNode>)object {
    [self.updateNodes removeObject:object];
}

@end
