//
//  PCPhysicsWrapperNode.h
//  
//
//  Created by Stephen Gazzard on 2015-02-03.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCPhysicsBodyParameters.h"

/**
 @discussion There is a bug in SpriteKite where a node with a negative scale completely breaks the physics simulation. This is considered by some to be a problem. To work around it, instead of adding the physics body directly to a node (which may have a negative scale), we add it to an invisible object which participates in the physics for the node and updates the node at appropriate times
 */
@interface PCPhysicsWrapperNode : SKSpriteNode

@property (readonly, nonatomic) SKNode *controlledNode;
@property (assign, nonatomic) BOOL enabled;

- (id)initWithNode:(SKNode *)node physicsBodyParameters:(PCPhysicsBodyParameters *)physicsBodyParameters;

@end
