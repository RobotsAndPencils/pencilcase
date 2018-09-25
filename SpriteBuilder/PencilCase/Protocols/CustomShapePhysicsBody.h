//
//  CustomShapePhysicsBody.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-05-26.
//
//

#import "NodePhysicsBody.h"
#import <Foundation/Foundation.h>

@protocol CustomShapePhysicsBody <NSObject>

/**
 Given the provided physics body, gives the node the opportunity to configure it in whichever way makes  sense.
 @param nodePhysicsBody The Physics Body that will represent the node in the physics simulator, not yet configured.
 */
- (void)setDefaultPhysicsBodyParametersOn:(NodePhysicsBody *)nodePhysicsBody;

@end
