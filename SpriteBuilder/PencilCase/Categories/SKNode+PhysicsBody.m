//
//  SKNode+PhysicsBody.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-15.
//
//

#import "SKNode+PhysicsBody.h"

@implementation SKNode (PhysicsBody)

- (BOOL)pc_supportsTexturePhysicsBody {
    return NO;
}

- (SKTexture *)pc_textureForPhysicsBody {
    return nil;
}

@end
