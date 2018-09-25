//
//  CCBPSKSprite.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-23.
//
//

#import "CCBPSKSprite.h"
#import "PCResourceManager.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"
#import "ResourceManagerUtil.h"

@interface CCBPSKSprite ()
@property (nonatomic) BOOL wasHiddenBeforePreview;
@end

@implementation CCBPSKSprite

- (instancetype)init {
    self = [super init];
    if (self) {
        self.colorBlendFactor = 1;
        self.color = [NSColor whiteColor];
    }
    return self;
}

- (void)removeFromParent {
    [super removeFromParent];
}

#pragma mark Properties

- (CGSize)contentSize {
    return self.texture.size;
}

- (SKTexture *)spriteFrame {
    return self.userData[@"spriteFrame"];
}

- (void)setSpriteFrame:(SKTexture *)spriteFrame {
    self.texture = spriteFrame;
    
    if (!spriteFrame) {
        [self.userData removeObjectForKey:@"spriteFrame"];
        return;
    }
    self.userData[@"spriteFrame"] = spriteFrame;
}

- (void)setTexture:(SKTexture *)texture {
    [super setTexture:texture];
    if (texture) [self setContentSize:texture.size];
}

- (void)setColorRGBA:(NSColor *)colorRGBA {
    self.color = colorRGBA;
}

- (NSColor *)colorRGBA {
    return self.color;
}

// override the position and scale properties to make sure there are no NaN
- (void)setPosition:(CGPoint)position {
	if (isnan(position.x) || isnan(position.y)) position = CGPointZero;
	[super setPosition:position];
}

- (void)setScaleX:(CGFloat)scaleX {
	if (isnan(scaleX)) scaleX = 1.0;
	[super setScaleX:scaleX];
}

- (void)setScaleY:(CGFloat)scaleY {
	if (isnan(scaleY)) scaleY = 1.0;
	[super setScaleY:scaleY];
}

- (BOOL)shouldHideForPreview {
    NSString *uuid = [self extraPropForKey:@"spriteFrame"];
    return uuid.length == 0;
}

#pragma mark - SKNode+PhysicsBody

- (BOOL)pc_supportsTexturePhysicsBody {
    return YES;
}

- (SKTexture *)pc_textureForPhysicsBody {
    return self.texture;
}

#pragma mark - PCCustomPreviewNode

- (void)previewWillBegin {
    self.wasHiddenBeforePreview = self.hidden;
    if ([self shouldHideForPreview]) {
        self.hidden = YES;
    }
}

- (void)previewDidFinish {
    self.hidden = self.wasHiddenBeforePreview;
}

#pragma mark - Resources

- (void)showMissingResourceImageIfResourceMissing {
    NSString *uuid = [self extraPropForKey:@"spriteFrame"];
    if (![[PCResourceManager sharedManager] resourceWithUUID:uuid]) {
        [self showMissingResourceImageWithKey:@"spriteFrame"];
    }
}

@end
