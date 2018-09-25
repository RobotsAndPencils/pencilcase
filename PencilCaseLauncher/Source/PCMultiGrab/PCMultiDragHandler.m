//
//  PCMultiDragHandler.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCMultiDragHandler.h"
#import <RXCollections/RXCollection.h>
#import "PCMultiDragGestureRecognizer.h"
#import "PCDrag.h"
#import "PCMultiDragTouch.h"
#import "SKNode+PhysicsExport.h"
#import "SKNode+LifeCycle.h"

@interface PCMultiDragHandler () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) SKNode *rootNode;

@property (strong, nonatomic) NSMutableArray *activeDrags;
@property (strong, nonatomic) PCMultiDragGestureRecognizer *gestureRecognizer;
@property (assign, nonatomic) NSTimeInterval lastUpdateTime;

@end

@implementation PCMultiDragHandler

- (instancetype)initWithRootNode:(SKNode *)root {
    self = [super init];
    if (self) {
        self.rootNode = root;

        self.activeDrags = [NSMutableArray array];

        self.gestureRecognizer = [[PCMultiDragGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        self.gestureRecognizer.delegate = self;
        [self.rootNode.pc_scene.view addGestureRecognizer:self.gestureRecognizer];
    }
    return self;
}

- (void)dealloc {
    [self teardown];
}

- (void)teardown {
    self.gestureRecognizer.delegate = nil;
    [self.gestureRecognizer.view removeGestureRecognizer:self.gestureRecognizer];
    self.gestureRecognizer = nil;
}

- (void)handleGesture:(PCMultiDragGestureRecognizer *)gestureRecognizer {
    NSArray *endedDrags = [self.activeDrags rx_filterWithBlock:^BOOL(PCDrag *drag) {
        return ![gestureRecognizer.activeTouches containsObject:drag.touch];
    }];

    NSArray *newTouches = [gestureRecognizer.activeTouches rx_filterWithBlock:^BOOL(PCMultiDragTouch *touch) {
        return ![self.activeDrags rx_detectWithBlock:^BOOL(PCDrag *each) {
            return each.touch == touch;
        }];
    }];

    for (PCMultiDragTouch *touch in newTouches) {
        [self startNewDragFromTouch:touch];
    }

    for (PCDrag *drag in endedDrags) {
        [self endDrag:drag];
    }

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded
        || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        [self cleanup];
    }
}

#pragma mark - Private

- (void)cleanup {
    for (PCDrag *drag in self.activeDrags) {
        [self endDrag:drag];
    }
    [self.activeDrags removeAllObjects];
}

- (void)startNewDragFromTouch:(PCMultiDragTouch *)touch {
    CGPoint viewPoint = [touch.touch locationInView:self.rootNode.pc_scene.view];
    CGPoint scenePoint = [self.rootNode.pc_scene.view convertPoint:viewPoint toScene:self.rootNode.pc_scene];
    CGPoint rootNodePoint = [self.rootNode.pc_scene convertPoint:scenePoint toNode:self.rootNode];

    SKNode *draggingNode = [self newDraggableNodeUnderPointInScene:scenePoint];
    if (!draggingNode) return; // Shouldn't happen if we are blocking proper touches in delegate

    SKNode *draggingFingerTrackingNode = [SKNode node];
    draggingFingerTrackingNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
    draggingFingerTrackingNode.physicsBody.affectedByGravity = NO;
    draggingFingerTrackingNode.physicsBody.angularDamping = 0.8;
    draggingFingerTrackingNode.physicsBody.mass = draggingNode.physicsBody.mass;
    draggingFingerTrackingNode.physicsBody.collisionBitMask = 0;
    draggingFingerTrackingNode.physicsBody.categoryBitMask = 0;
    draggingFingerTrackingNode.position = rootNodePoint;
    draggingFingerTrackingNode.physicsBody.linearDamping = 50;
    [self.rootNode addChild:draggingFingerTrackingNode];

    SKPhysicsJointPin *draggingJoint = [SKPhysicsJointPin jointWithBodyA:draggingFingerTrackingNode.physicsBody bodyB:draggingNode.physicsBody anchor:scenePoint];
    [self.rootNode.pc_scene.physicsWorld addJoint:draggingJoint];

    PCDrag *drag = [[PCDrag alloc] init];
    drag.draggingNode = draggingNode;
    drag.fingerTrackingNode = draggingFingerTrackingNode;
    drag.joint = draggingJoint;
    drag.touch = touch;

    [self.activeDrags addObject:drag];
}

- (void)endDrag:(PCDrag *)drag {
    [self.rootNode.pc_scene.physicsWorld removeJoint:drag.joint];
    [drag.fingerTrackingNode removeFromParent];
    [self.activeDrags removeObject:drag];
}

- (void)update:(NSTimeInterval)currentTime {
    if (self.lastUpdateTime == 0) {
        self.lastUpdateTime = currentTime;
        return;
    };
    CFTimeInterval timeChange = currentTime - self.lastUpdateTime;

    for (PCDrag *drag in self.activeDrags) {

        SKNode *node = drag.fingerTrackingNode;
        SKPhysicsBody *body = node.physicsBody;

        // Use current velocity of body to figure out where it is headed.
        CGPoint heading = node.position;
        heading.x += body.velocity.dx * timeChange;
        heading.y += body.velocity.dy * timeChange;

        // Calcuate a vector from heading to desired location
        CGVector travelVector = [self vectorFromPoint:heading toPoint:[self desiredPositionForDrag:drag]];

        CGVector impulse = CGVectorMake(0, 0);
        CGFloat travelTime = 0.03;
        if (ABS(travelVector.dx) > 1) {
            impulse.dx = body.mass * travelVector.dx / travelTime;
        }
        if (ABS(travelVector.dy) > 1) {
            impulse.dy = body.mass * travelVector.dy / travelTime;
        }

        CGFloat maxImpulse = 5000 * body.mass;
        impulse.dx = MAX(MIN(impulse.dx, maxImpulse), -maxImpulse);
        impulse.dy = MAX(MIN(impulse.dy, maxImpulse), -maxImpulse);


        [body applyImpulse:impulse];
    }
    self.lastUpdateTime = currentTime;
}

- (CGPoint)desiredPositionForDrag:(PCDrag *)drag {
    CGPoint viewPoint = [drag.touch.touch locationInView:self.rootNode.pc_scene.view];
    CGPoint scenePoint = [self.rootNode.pc_scene.view convertPoint:viewPoint toScene:self.rootNode.pc_scene];
    CGPoint rootNodePoint = [self.rootNode.pc_scene convertPoint:scenePoint toNode:self.rootNode];
    return rootNodePoint;
}

- (CGVector)vectorFromPoint:(CGPoint)pointA toPoint:(CGPoint)pointB {
    return CGVectorMake(pointB.x - pointA.x, pointB.y - pointA.y);
}

- (SKNode *)newDraggableNodeUnderPointInScene:(CGPoint)point {
    NSArray *nodesAlreadyDragging = [self.activeDrags rx_mapWithBlock:^id(PCDrag *each) {
        return each.draggingNode;
    }];
    return [[self allNodesAtPoint:point withinNode:self.rootNode.pc_scene] rx_detectWithBlock:^BOOL(SKNode *node) {
        return node.physicsBody && node.physicsBody.dynamic && node.allowsUserDragging && ![nodesAlreadyDragging containsObject:node];
    }];
}

- (NSArray *)allNodesAtPoint:(CGPoint)point withinNode:(SKNode *)node {
    NSMutableArray *nodes = [NSMutableArray array];
    for (SKNode *child in node.children) {
        if (CGRectContainsPoint(child.frame, point)) {
            [nodes addObject:child];
        }
        [nodes addObjectsFromArray:[self allNodesAtPoint:[child convertPoint:point fromNode:node] withinNode:child]];
    }
    return nodes;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.rootNode.pc_scene.view];
    point = [self.rootNode.pc_scene.view convertPoint:point toScene:self.rootNode.pc_scene];
    BOOL draggableNodeUnderPoint = !![self newDraggableNodeUnderPointInScene:point];
    return draggableNodeUnderPoint;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
