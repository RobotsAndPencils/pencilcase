//
//  SKNode+PhysicsExport.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "SKNode+PhysicsExport.h"
#import "PCPhysicsBodyParameters.h"

@implementation SKNode (PhysicsExport)

//@property (nonatomic, getter = physicsBodyIsDynamic) BOOL physicsBodyDynamic;
- (BOOL)physicsBodyIsDynamic {
    return self.pc_proxiedPhysicsBody.isDynamic;
}

- (void)setPhysicsBodyDynamic:(BOOL)dynamic {
    self.pc_proxiedPhysicsBody.dynamic = dynamic;
}

//@property (nonatomic) BOOL physicsBodyAllowsRotation;
- (BOOL)physicsBodyAllowsRotation {
    return self.pc_proxiedPhysicsBody.allowsRotation;
}

- (void)setPhysicsBodyAllowsRotation:(BOOL)allowsRotation {
    self.pc_proxiedPhysicsBody.allowsRotation = allowsRotation;
}

//@property (nonatomic) BOOL physicsBodyPinned;
- (BOOL)physicsBodyPinned {
    return self.pc_proxiedPhysicsBody.pinned;
}

- (void)setPhysicsBodyPinned:(BOOL)pinned {
    self.pc_proxiedPhysicsBody.pinned = pinned;
}

//@property (nonatomic, getter = physicsBodyIsResting) BOOL physicsBodyResting;
- (BOOL)physicsBodyIsResting {
    return self.pc_proxiedPhysicsBody.isResting;
}

- (void)setPhysicsBodyResting:(BOOL)resting {
    self.pc_proxiedPhysicsBody.resting = YES;
}

//@property (nonatomic) CGFloat physicsBodyFriction;
- (CGFloat)physicsBodyFriction {
    return self.pc_proxiedPhysicsBody.friction;
}

- (void)setPhysicsBodyFriction:(CGFloat)friction {
    self.pc_proxiedPhysicsBody.friction = friction;
}

//@property (nonatomic) CGFloat physicsBodyCharge;
- (CGFloat)physicsBodyCharge {
    return self.pc_proxiedPhysicsBody.charge;
}

- (void)setPhysicsBodyCharge:(CGFloat)charge {
    self.pc_proxiedPhysicsBody.charge = charge;
}

//@property (nonatomic) CGFloat physicsBodyRestitution;
- (CGFloat)physicsBodyRestitution {
    return self.pc_proxiedPhysicsBody.restitution;
}

- (void)setPhysicsBodyRestitution:(CGFloat)physicsBodyRestitution {
    self.pc_proxiedPhysicsBody.restitution = physicsBodyRestitution;
}

//@property (nonatomic, assign) CGFloat physicsBodyLinearDamping;
- (CGFloat)physicsBodyLinearDamping {
    return self.pc_proxiedPhysicsBody.linearDamping;
}

- (void)setPhysicsBodyLinearDamping:(CGFloat)physicsBodyLinearDamping {
    self.pc_proxiedPhysicsBody.linearDamping = physicsBodyLinearDamping;
}

//@property (nonatomic, assign) CGFloat physicsBodyAngularDamping;
- (CGFloat)physicsBodyAngularDamping {
    return self.pc_proxiedPhysicsBody.angularDamping;
}

- (void)setPhysicsBodyAngularDamping:(CGFloat)physicsBodyAngularDamping {
    self.pc_proxiedPhysicsBody.angularDamping = physicsBodyAngularDamping;
}

//@property (nonatomic) CGFloat physicsBodyDensity;
- (CGFloat)physicsBodyDensity {
    return self.pc_proxiedPhysicsBody.density;
}

- (void)setPhysicsBodyDensity:(CGFloat)physicsBodyDensity {
    self.pc_proxiedPhysicsBody.density = physicsBodyDensity;
}

//@property (nonatomic) CGFloat physicsBodyMass;
- (CGFloat)physicsBodyMass {
    return self.pc_proxiedPhysicsBody.mass;
}

- (void)setPhysicsBodyMass:(CGFloat)physicsBodyMass {
    self.pc_proxiedPhysicsBody.mass = physicsBodyMass;
}

//@property (nonatomic, readonly) CGFloat physicsBodyArea;
- (CGFloat)physicsBodyArea {
    return self.pc_proxiedPhysicsBody.area;
}

//@property (nonatomic, assign) BOOL physicsBodyAffectedByGravity;
- (BOOL)physicsBodyAffectedByGravity {
    return self.pc_proxiedPhysicsBody.affectedByGravity;
}

- (void)setPhysicsBodyAffectedByGravity:(BOOL)physicsBodyAffectedByGravity {
    self.pc_proxiedPhysicsBody.affectedByGravity = physicsBodyAffectedByGravity;
}

//@property (nonatomic, readonly) NSArray *physicsBodyJoints;
- (NSArray *)physicsBodyJoints {
    return self.pc_proxiedPhysicsBody.joints;
}

//@property (nonatomic) CGVector physicsBodyVelocity;
- (CGVector)physicsBodyVelocity {
    return self.pc_proxiedPhysicsBody.velocity;
}

- (void)setPhysicsBodyVelocity:(CGVector)physicsBodyVelocity {
    self.pc_proxiedPhysicsBody.velocity = physicsBodyVelocity;
}

//@property (nonatomic) CGFloat physicsBodyAngularVelocity;
- (CGFloat)physicsBodyAngularVelocity {
    return self.pc_proxiedPhysicsBody.angularVelocity;
}

- (void)setPhysicsBodyAngularVelocity:(CGFloat)physicsBodyAngularVelocity {
    self.pc_proxiedPhysicsBody.angularVelocity = physicsBodyAngularVelocity;
}

- (void)applyForce:(CGVector)force {
    [self.pc_proxiedPhysicsBody applyForce:force];
}

- (void)applyForce:(CGVector)force atPoint:(CGPoint)point {
    [self.pc_proxiedPhysicsBody applyForce:force atPoint:point];
}

- (void)applyTorque:(CGFloat)torque {
    [self.pc_proxiedPhysicsBody applyTorque:torque];
}

- (void)applyImpulse:(CGVector)impulse {
    [self.pc_proxiedPhysicsBody applyImpulse:impulse];
}

- (void)applyImpulse:(CGVector)impulse atPoint:(CGPoint)point {
    [self.pc_proxiedPhysicsBody applyImpulse:impulse atPoint:point];
}

- (void)applyAngularImpulse:(CGFloat)impulse {
    [self.pc_proxiedPhysicsBody applyAngularImpulse:impulse];
}

- (NSArray *)allContactedBodies {
    return [self.pc_proxiedPhysicsBody allContactedBodies];
}

- (void)makeDynamic {
    self.pc_proxiedPhysicsBody.dynamic = self.pc_proxiedPhysicsBody.affectedByGravity = self.pc_proxiedPhysicsBody.allowsRotation = YES;
}

- (void)makeStatic {
    self.pc_proxiedPhysicsBody.dynamic = self.pc_proxiedPhysicsBody.affectedByGravity = self.pc_proxiedPhysicsBody.allowsRotation = NO;
}

- (void)setAllowsUserDragging:(BOOL)allowsUserDragging {
    objc_setAssociatedObject(self, @selector(allowsUserDragging), @(allowsUserDragging), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)allowsUserDragging {
    return [objc_getAssociatedObject(self, @selector(allowsUserDragging)) boolValue];
}

- (SKPhysicsBody *)pc_proxiedPhysicsBody {
    SKPhysicsBody *proxiedBody = objc_getAssociatedObject(self, @selector(pc_proxiedPhysicsBody));
    return proxiedBody ?: self.physicsBody;
}

- (void)setPc_proxiedPhysicsBody:(SKPhysicsBody *)pc_proxiedPhysicsBody {
    objc_setAssociatedObject(self, @selector(pc_proxiedPhysicsBody), pc_proxiedPhysicsBody, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PCPhysicsWrapperNode *)pc_physicsWrapperNode {
    return objc_getAssociatedObject(self, @selector(pc_physicsWrapperNode));
}

- (void)setPc_physicsWrapperNode:(PCPhysicsWrapperNode *)pc_physicsWrapperNode {
    objc_setAssociatedObject(self, @selector(pc_physicsWrapperNode), pc_physicsWrapperNode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (uint32_t)categoryBitMask {
    return self.pc_proxiedPhysicsBody.categoryBitMask;
}

- (void)setCategoryBitMask:(uint32_t)categoryBitMask {
    self.pc_proxiedPhysicsBody.categoryBitMask = categoryBitMask;
}

- (uint32_t)collisionBitMask {
    return self.pc_proxiedPhysicsBody.collisionBitMask;
}

- (void)setCollisionBitMask:(uint32_t)collisionBitMask {
    self.pc_proxiedPhysicsBody.collisionBitMask = collisionBitMask;
}

- (uint32_t)contactTestBitMask {
    return self.pc_proxiedPhysicsBody.contactTestBitMask;
}

- (void)setContactTestBitMask:(uint32_t)contactTestBitMask {
    self.pc_proxiedPhysicsBody.contactTestBitMask = contactTestBitMask;
}


@end
