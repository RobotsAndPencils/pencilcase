//
//  PCCollisionTrackingInfo.m
//  
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

#import "PCCollisionTrackingInfo.h"
#import "SKNode+HitTest.h"
#import "PCJSContext+CommonEvents.h"
#import "SKNode+PhysicsExport.h"

@interface PCCollisionTrackingInfo()

@property (assign, nonatomic) BOOL collidingLastFrame;

@end

@implementation PCCollisionTrackingInfo

- (instancetype)initWithNode:(SKNode *)firstNode andNode:(SKNode *)secondNode {
    self = [super init];
    if (self) {
        _firstNode = firstNode;
        _secondNode = secondNode;
        _numberOfTrackers = 1;
    }

    return self;
}

#pragma mark - Public

- (void)notifyJavascriptIfCollisionIsOccurring:(PCJSContext *)context {
    if ((self.firstNode.pc_proxiedPhysicsBody && self.secondNode.pc_proxiedPhysicsBody) || ![self.firstNode pc_hitTestWithNode:self.secondNode]) {
        self.collidingLastFrame = NO;
        return;
    }

    //Only update on new collisions
    if (self.collidingLastFrame) return;

    self.collidingLastFrame = YES;
    [context triggerCollisionEventBetweenNode:self.firstNode andNode:self.secondNode];
}

@end
