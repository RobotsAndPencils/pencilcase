//
//  SKPhysicsBody+State.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

#import "SKPhysicsBody+State.h"

@implementation SKPhysicsBody (State)

+ (void)copyStateFrom:(SKPhysicsBody *)physicsBody to:(SKPhysicsBody *)targetBody {
    targetBody.dynamic = physicsBody.dynamic;
    targetBody.friction = physicsBody.friction;
    targetBody.allowsRotation = physicsBody.allowsRotation;
    targetBody.restitution = physicsBody.restitution;
    targetBody.density = physicsBody.density;
    targetBody.affectedByGravity = physicsBody.affectedByGravity;
    targetBody.velocity = physicsBody.velocity;
    targetBody.angularVelocity = physicsBody.angularVelocity;
}

@end
