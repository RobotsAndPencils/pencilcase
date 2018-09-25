//
//  SKPhysicsBody+State.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKPhysicsBody (State)

/**
 Copies all the values inside the target physics body that may actively change at run time. (Because SKPhysicsBody appears to be a 
 class cluster, this cannot be a class level method)
 @param physicsBody the physics body whose state we are going to mimic
 @param targetBody the physics body that will receive the state from the other physics body
 */
+ (void)copyStateFrom:(SKPhysicsBody *)physicsBody to:(SKPhysicsBody *)targetBody;

@end
