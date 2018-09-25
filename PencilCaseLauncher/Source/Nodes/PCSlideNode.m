//
//  SlideNode.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "PCSlideNode.h"
#import "PCJSContext.h"
#import "SKNode+JavaScript.h"
#import "PCMultiDragHandler.h"
#import "SKNode+SFGestureRecognizers.h"
#import "PCReaderManager.h"
#import "PCMotionManager.h"
#import "PCForceNode.h"
#import <RXCollections/RXCollection.h>
#import <PencilCaseLauncher/PCApp.h>
#import "NSObject+JSDataBinding.h"
#import "PCAppViewController.h"
#import "PCCollisionMonitor.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+GeneralHelpers.h"
#import "PCCard.h"
#import "PCScene.h"
#import "PCCard.h"
#import "CCFileUtils.h"
#import "PCNodeCollisionHandler.h"
#import "PCPhysicsWrapperNode.h"
#import "PCCollisionMonitor.h"
#import "PCJSContext+CommonEvents.h"
#import "PCApp.h"
#import "PCContextData.h"
#import "PCConstants.h"

NSString * const PCSlideLoadedEventNotification = @"PCSlideLoadedEventNotification";
NSString * const PCSlideWillUnloadEventNotification = @"PCSlideWillUnloadEventNotification";

@interface PCSlideNode () <SKPhysicsContactDelegate, PCUpdateNode>

@property (strong, nonatomic) PCMultiDragHandler *multiDragHandler;
@property (assign, nonatomic) BOOL followAccelerometer;
@property (assign, nonatomic) BOOL autocreatePhysicsBoundaries;
@property (copy, nonatomic) CMAccelerometerHandler accelerometerHandler;
@property (strong, nonatomic) id<NSObject> contextNotificationObserver;
@property (strong, nonatomic, readwrite) PCCollisionMonitor *collisionMonitor;
@property (strong, nonatomic) JSValue *allNodesValue;

@end

@implementation PCSlideNode

- (id)init {
    self = [super init];
    if (self) {
        self.context = [PCAppViewController lastCreatedInstance].cardAtCurrentIndex.context;
        [[[PCReaderManager sharedManager] currentReader].animationManager setDelegate:self];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.contextNotificationObserver name:PCJSContextEventNotificationName object:nil];
}

- (void)pc_presentationDidStart {
    [PCContextData cleanupDataMonitoring];

    NSArray *allNodes = [self allNodes];
    for (SKNode *node in allNodes) {
        node.originalOpacity = node.alpha;
    }

    // Sometimes we need a reference to _this exact_ card, as opposed to Creation.currentCard(), which depending on timing might not be _this exact_ card when invoked.
    self.context[@"Card"] = self;

    [self addNodesToContext:allNodes];
    [self setAllGestureRecogizersEnabled:NO];
    [self setupDelegateForPhysicsNodes:allNodes];
    [self evaluateCardScript];
    [self updateScenePhysics];

    __weak __typeof(self) weakSelf = self;
    self.contextNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:PCJSContextEventNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        SKNode *node = note.object;
        NSString *eventName = note.userInfo[PCJSContextEventNotificationEventNameKey];
        NSArray *arguments = note.userInfo[PCJSContextEventNotificationArgumentsKey];
        if (node) {
            NSString *nodeRepresentation = [NSString stringWithFormat:@"Creation.nodeWithUUID('%@')", node.uuid];
            [weakSelf.context triggerEventOnJavaScriptRepresentation:nodeRepresentation eventName:eventName arguments:arguments];
        }
        else {
            if ([eventName isEqualToString:@"cardUpdate"]) {
                [weakSelf.context triggerEventWithName:eventName arguments:arguments loggingEnabled:PCCollisionAndCardUpdateTriggerLoggingEnabled];
            }
            else {
                [weakSelf.context triggerEventWithName:eventName arguments:arguments];
            }
        }
    }];

    if (self.followAccelerometer) {
        __weak typeof(self) _self = self;
        self.accelerometerHandler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
            CGFloat magnitude = sqrtf(powf(_self.gravity.x, 2) + powf(_self.gravity.y, 2));
            CGPoint gravity = [_self gravityForAccelerometerData:accelerometerData];
            gravity = pc_CGPointMultiply(gravity, magnitude);
            _self.pc_scene.physicsWorld.gravity = CGVectorMake(gravity.x, gravity.y);
        };
        [[PCMotionManager sharedInstance] registerForAccelerometerUpdatesWithHandler:self.accelerometerHandler];
    }

    if (self.autocreatePhysicsBoundaries) {
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:PCSlideLoadedEventNotification object:self];
    [self setAllGestureRecogizersEnabled:YES];

    // The global "cardLoad" event is deprecated in favor of "load" triggered on the card itself. This is more consistent with other events and also prevents an event fired globally from causing evaluation of listeners on more than one card at a time (this happens during a transition).
    BOOL creationUsesDeprecatedCardLoadEvent = [PCAppViewController lastCreatedInstance].runningApp.fileFormatVersion.integerValue < PCFirstFileVersionWithScopedCardLoadEvent;
    if (creationUsesDeprecatedCardLoadEvent) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:@{
            PCJSContextEventNotificationEventNameKey : @"cardLoad"
        }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
            PCJSContextEventNotificationEventNameKey : @"loaded"
        }];
    }

    [super pc_presentationDidStart];
}

- (void)pc_presentationCompleted {
    CCBAnimationManager *animationManager = (CCBAnimationManager *)self.userObject;
    if (animationManager.autoPlaySequenceId >= 0) {
        [animationManager runAnimationsForSequenceId:animationManager.autoPlaySequenceId tweenDuration:0 completion:nil];
    }

    [super pc_presentationCompleted];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    self.context[@"Card"] = nil;
    self.context = nil;
}

/**
 * Accelerometer data does not consider status bar orientation. Search at the following linke for "Handling Accelerometer Events Using Core Motion"
 * https://developer.apple.com/library/prerelease/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/motion_event_basics/motion_event_basics.html#//apple_ref/doc/uid/TP40009541-CH6-SW1
 */
- (CGPoint)gravityForAccelerometerData:(CMAccelerometerData *)accelerometerData {
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return CGPointMake(accelerometerData.acceleration.y, -accelerometerData.acceleration.x);
        case UIInterfaceOrientationLandscapeRight:
            return CGPointMake(-accelerometerData.acceleration.y, accelerometerData.acceleration.x);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGPointMake(-accelerometerData.acceleration.x, -accelerometerData.acceleration.y);
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationUnknown:
        default:
            return CGPointMake(accelerometerData.acceleration.x, accelerometerData.acceleration.y);
    }
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self.pc_PCScene registerForUpdates:self];
    [self updateScenePhysics];
}

-(void)fireTimelineEventCallback:(NSString *)data {
    [self.context triggerEventWithName:data];
}

// We need to let the context know just before the slide transitions out
- (void)pc_willExitScene {
    [self.multiDragHandler teardown];
    [self removeAllGestureRecognizers];
    [self.context triggerEventWithName:@"cardUnload"];
    
    self.accelerometerHandler = nil;

    //Nodes may have SKActions in progress, and if those actions are created from SKNode+Animation or the timeline, they will have a block at the end that will call back into the JSContext to fulfill a promise. This block will retain the JSValue it needs to call back, which will retain the JSContext, which will retain all nodes, which will retain the action, and now we have a retain cycle. To fix it, we just remove all nodes actions when changing cards.
    [[self flattenedRecursiveChildrenForNode:self.parent] makeObjectsPerformSelector:@selector(removeAllActions)];

    [self removeAllChildren]; // Because our physics node is retaining us :(
    self.allNodesValue = nil;
    self.context[@"Card"] = nil;
    self.context = nil; // Let go of context since it's holding a strong ref to us

    [self.pc_PCScene unregisterForUpdates:self];
    [super pc_willExitScene];
}

#pragma mark - PCUpdateNode implementation

- (void)update:(NSTimeInterval)currentTime {
    NSArray *nodesWithPhysicsBodies = [self nodesWithPhysicsBodies];
    [[self forceNodes] enumerateObjectsUsingBlock:^(PCForceNode *forceNode, NSUInteger idx, BOOL *stop) {
        [forceNode applyForceToNodes:nodesWithPhysicsBodies delta:currentTime];
    }];
    [self.multiDragHandler update:currentTime];
}

- (void)physicsDidSimulate {
    //Collision monitor is lazy inited, so call via ivar here to prevent accidental initialisation
    if (!_collisionMonitor) return;

    [self.collisionMonitor notifyJavascriptIfAnyCollisionsAreOccurring:self.context];
}

#pragma mark - Timelines

- (void)playTimelineWithName:(NSString *)timelineName completion:(void (^)())completion {
    [self.card.animationManager runAnimationsForSequenceNamed:timelineName completion:completion ?: ^{}];
}

- (void)stopTimelineWithName:(NSString *)timelineName {
    [self.card.animationManager stopAnimationForSequenceNamed:timelineName];
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKNode *nodeA = [contact.bodyA.node isKindOfClass:[PCPhysicsWrapperNode class]] ? [(PCPhysicsWrapperNode *)contact.bodyA.node controlledNode] : contact.bodyA.node;
    SKNode *nodeB = [contact.bodyB.node isKindOfClass:[PCPhysicsWrapperNode class]] ? [(PCPhysicsWrapperNode *)contact.bodyB.node controlledNode] : contact.bodyB.node;
    if (!nodeA.name || !nodeB.name) return;

    [self.context triggerCollisionEventBetweenNode:nodeA andNode:nodeB];
}

#pragma mark - Private

- (void)addNodesToContext:(NSArray *)nodes {
    if (!self.context) return;

    if (([PCAppViewController lastCreatedInstance].runningApp.fileFormatVersion.integerValue >=PCFirstFileVersionWithoutExposingNodesByAuthorName)) {
        if (!self.allNodesValue) {
            self.allNodesValue = [JSValue valueWithNewObjectInContext:self.context];
        }
        for (SKNode *node in nodes) {
            self.allNodesValue[node.uuid] = [JSValue valueWithObject:node inContext:self.context];
        }
    } else for (SKNode *node in nodes) {
        if (PCIsEmpty(node.name)) continue;
        self.context[node.name] = node;
    }
}

- (void)addNodeAndNodesChildrenToContext:(SKNode *)node {
    if (!self.context) return;

    for (SKNode *childNode in node.children) {
        [self addNodeAndNodesChildrenToContext:childNode];
    }
    if (([PCAppViewController lastCreatedInstance].runningApp.fileFormatVersion.integerValue >=PCFirstFileVersionWithoutExposingNodesByAuthorName)) {
        if (PCIsEmpty(node.uuid)) return;
        self.allNodesValue[node.uuid] = node;
    } else {
        if (PCIsEmpty(node.name)) return;
        self.context[node.name] = node;
    }
}

- (void)removeNodeAndNodesChildrenFromContext:(SKNode *)node {
    if (!self.context) return;
    
    for (SKNode *childNode in node.children) {
        [self removeNodeAndNodesChildrenFromContext:childNode];
    }
    if (self.allNodesValue) {
        self.allNodesValue[node.uuid] = nil;
    } else {
        self.context[node.name] = nil;
    }
}

- (void)evaluateCardScript {
    NSString *fullJSFilePath = [[CCFileUtils sharedFileUtils] fullPathForFilename:[PCAppViewController lastCreatedInstance].cardAtCurrentIndex.jsFilePath];
    if (fullJSFilePath) {
        [self.context evaluateScriptFileAtPath:fullJSFilePath requiresShim:NO];
    }
}

- (void)removeAllGestureRecognizers {
    NSArray *allNodes = [self allNodes];
    NSArray *gestureRecognizers;
    for (SKNode *node in allNodes) {
        gestureRecognizers = [node sf_gestureRecognizers];
        for (UIGestureRecognizer *recognizer in gestureRecognizers) {
            [node sf_removeGestureRecognizer:recognizer];
        }
    }
}

- (void)setAllGestureRecogizersEnabled:(BOOL)enabled {
    NSArray *allNodes = [self allNodes];
    NSArray *gestureRecognizers;
    for (SKNode *node in allNodes) {
        gestureRecognizers = [node sf_gestureRecognizers];
        for (UIGestureRecognizer *recognizer in gestureRecognizers) {
            recognizer.enabled = enabled;
        }
    }
}

- (void)setupDelegateForPhysicsNodes:(NSArray *)nodes {
    self.pc_scene.physicsWorld.contactDelegate = self;
    self.multiDragHandler = [[PCMultiDragHandler alloc] initWithRootNode:self];
}

- (NSArray *)forceNodes {
    return [[self flattenedRecursiveChildren] rx_filterWithBlock:^BOOL(SKNode *each) {
        return [each isKindOfClass:[PCForceNode class]];
    }];
}

- (NSArray *)nodesWithPhysicsBodies {
    return [[self flattenedRecursiveChildren] rx_filterWithBlock:^BOOL(SKNode *each) {
        return !![each physicsBody];
    }];
}

- (NSArray *)flattenedRecursiveChildren {
    return [self flattenedRecursiveChildrenForNode:self];
}

- (NSArray *)flattenedRecursiveChildrenForNode:(SKNode *)node {
    NSMutableArray *children = [node.children mutableCopy];
    for (SKNode *child in node.children) {
        [children addObjectsFromArray:[self flattenedRecursiveChildrenForNode:child]];
    }
    return children;
}

- (void)updateScenePhysics {
    self.pc_scene.physicsWorld.gravity = CGVectorMake(self.gravity.x, self.gravity.y);
}

- (PCCollisionMonitor *)collisionMonitor {
    if (!_collisionMonitor) {
        _collisionMonitor = [[PCCollisionMonitor alloc] init];
    }
    return _collisionMonitor;
}

#pragma mark - Physics

- (void)setGravity:(CGPoint)gravity {
    _gravity = gravity;
    [self updateScenePhysics];
}

@end
