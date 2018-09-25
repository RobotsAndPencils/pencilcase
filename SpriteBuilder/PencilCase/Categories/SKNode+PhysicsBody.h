//
//  SKNode+PhysicsBody.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-15.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKNode (PhysicsBody)

- (BOOL)pc_supportsTexturePhysicsBody;
- (SKTexture *)pc_textureForPhysicsBody;

@end
