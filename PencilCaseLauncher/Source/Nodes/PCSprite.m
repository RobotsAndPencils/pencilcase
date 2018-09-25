//
//  PCSprite.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCSprite.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+PhysicsBody.h"

@implementation PCSprite

- (instancetype)init {
    self = [super init];
    if (self) {
        self.colorBlendFactor = 1;
        self.color = [UIColor whiteColor];
    }
    return self;
}

#pragma mark Properties

- (CGSize)contentSize {
    return self.texture.size;
}

- (SKTexture *)spriteFrame {
    return self.texture;
}

- (void)setSpriteFrame:(SKTexture *)spriteFrame {
    self.texture = spriteFrame;
}

- (void)setTexture:(SKTexture *)texture {
    [super setTexture:texture];
    if (texture) [self setContentSize:texture.size];
}

- (void)setColorRGBA:(UIColor *)colorRGBA {
    self.color = colorRGBA;
}

- (UIColor *)colorRGBA {
    return self.color;
}

#pragma mark - SKNode+PhysicsBody

- (SKTexture *)pc_textureForPhysicsBody {
    return self.texture;
}

@end
