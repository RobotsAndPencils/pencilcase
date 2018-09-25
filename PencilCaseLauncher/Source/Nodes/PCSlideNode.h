//
//  SlideNode.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

@import CoreLocation;
@import SpriteKit;
@import JavaScriptCore;

FOUNDATION_EXPORT NSString * const PCSlideLoadedEventNotification;
FOUNDATION_EXPORT NSString * const PCSlideWillUnloadEventNotification;

@class PCJSContext;
@class PCCollisionMonitor;
@class PCCard;

@interface PCSlideNode : SKSpriteNode

@property (assign, nonatomic) CGPoint gravity;
@property (weak, nonatomic) PCJSContext *context;
@property (strong, nonatomic, readonly) PCCollisionMonitor *collisionMonitor;
@property (nonatomic, weak) PCCard *card;

- (void)addNodesToContext:(NSArray *)nodes;
- (void)addNodeAndNodesChildrenToContext:(SKNode *)node;
- (void)removeNodeAndNodesChildrenFromContext:(SKNode *)node;

#pragma mark - Timelines

- (void)playTimelineWithName:(NSString *)timelineName completion:(void (^)())completion;
- (void)stopTimelineWithName:(NSString *)timelineName;

@end
