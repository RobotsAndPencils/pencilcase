//
//  SKCropNode+Nesting.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-12.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKCropNode(Nesting)

- (SKNode *)constrainMaskToParentCropNodes:(SKNode *)maskNode inScene:(SKScene *)scene;

@end
