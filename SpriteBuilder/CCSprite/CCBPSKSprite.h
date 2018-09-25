//
//  CCBPSKSprite.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-23.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCCustomPreviewNode.h"

@class PCResource;

@interface CCBPSKSprite : SKSpriteNode <PCCustomPreviewNode>

@property (nonatomic, strong) SKTexture *spriteFrame;
@property (nonatomic, strong) PCResource *spriteFrameResource;
@property (nonatomic, strong) NSColor *colorRGBA;

@end
