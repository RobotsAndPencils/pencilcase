//
//  SKNode+PhysicsExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+JSDataBinding.h"
@import JavaScriptCore;

@class PCPhysicsWrapperNode;

// Physics on SKNode - We can't export SKPhysicsNode because it's a class cluster :(
@protocol SKNodePhysics <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic, getter = physicsBodyIsDynamic) BOOL physicsBodyDynamic;
@property (nonatomic) BOOL physicsBodyAllowsRotation;
@property (nonatomic) BOOL physicsBodyPinned;
@property (nonatomic, getter = physicsBodyIsResting) BOOL physicsBodyResting;
@property (nonatomic) CGFloat physicsBodyFriction;
@property (nonatomic) CGFloat physicsBodyCharge;
@property (nonatomic) CGFloat physicsBodyRestitution;
@property (nonatomic, assign) CGFloat physicsBodyLinearDamping;
@property (nonatomic, assign) CGFloat physicsBodyAngularDamping;
@property (nonatomic) CGFloat physicsBodyDensity;
@property (nonatomic) CGFloat physicsBodyMass;
@property (nonatomic, readonly) CGFloat physicsBodyArea;
@property (nonatomic, assign) BOOL physicsBodyAffectedByGravity;
@property (nonatomic, readonly) NSArray *physicsBodyJoints;
@property (assign, nonatomic) BOOL allowsUserDragging;
@property (nonatomic, assign) uint32_t categoryBitMask;
@property (nonatomic, assign) uint32_t collisionBitMask;
@property (nonatomic, assign) uint32_t contactTestBitMask;

@property (nonatomic) CGVector physicsBodyVelocity;
@property (nonatomic) CGFloat physicsBodyAngularVelocity;

// There's a bug in SK where a node with negative scale will sometimes completely break a scene if it has a physics body
// We're using PCPhysicsWrapperNode to work around this, which has the physics body that an "actual" node would normally have
// This means that any of the above accessors would normally no longer work as intended.
// To get around this, this property was added.
// We can't swizzle the physicsBody accessors to try to use the proxied body if it exists, because of at least the following case:
//   When addChild: is called, a physics body of that node will be added to the physics world
//   If we were to swizzle physicsBody to return either the proxied body or the real body, the wrapper and real nodes would return the same body
//   Attempting to add the same body to a physics world more than once will throw an exception
// For this reason the property accessors that are used here (for change property behaviours) try to use the proxied body if it exists
// This seems to leak the least amount of the current workaround's implementation into SKNode itself, in that it's general I guess.
// Removing the need to use the wrapper node in the future should require no changes to this implementation (although it may be desired).
//
// The getter for this property will return the proxied body if it is non-nil or the physicsBody property
@property (nonatomic, strong) SKPhysicsBody *pc_proxiedPhysicsBody;
@property (nonatomic, strong) PCPhysicsWrapperNode *pc_physicsWrapperNode;

- (void)applyForce:(CGVector)force;
- (void)applyForce:(CGVector)force atPoint:(CGPoint)point;
- (void)applyTorque:(CGFloat)torque;
- (void)applyImpulse:(CGVector)impulse;
- (void)applyImpulse:(CGVector)impulse atPoint:(CGPoint)point;
- (void)applyAngularImpulse:(CGFloat)impulse;
- (NSArray *)allContactedBodies;

// Custom
- (void)makeDynamic;
- (void)makeStatic;

@end


@interface SKNode (PhysicsExport) <SKNodePhysics>

@property (assign, nonatomic) BOOL allowsUserDragging;

@end
