//
//  PCSKCameraCaptureNode.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-18.
//
//

#import "PCSKCameraCaptureNode.h"
#import "SKNode+CocosCompatibility.h"
#import "PositionPropertySetter.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"
#import "PlugInNode.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+NodeInfo.h"
#import "NodeInfo.h"
#import "PCResourceManager.h"
#import "SKNode+CoordinateConversion.h"

@interface PCSKCameraCaptureNode()

/**
 *  One of either imageSprite or cameraSprite should exist at all times, but never both. 
 *  When image sprite exists, the users has selected a background image, and it should scale to aspect fill the node. 
 *  When camera sprite exists, the user has not set a background image, and it should stay centered in the node.
 */
@property (weak, nonatomic) SKSpriteNode *imageSprite;
@property (weak, nonatomic) SKSpriteNode *cameraSprite;

@end

@implementation PCSKCameraCaptureNode

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    if ([self.children count] != 0) return;
    [self addDefaultCameraIcon];
}

#pragma mark - Properties

- (void)setSpriteFrame:(SKTexture *)texture {
    [self removeAllChildren];

    if (texture) {
        SKSpriteNode *newSprite = [SKSpriteNode spriteNodeWithTexture:texture];
        [self addChild:newSprite];
        [newSprite pc_aspectFillParent];
        [newSprite pc_centerInParent];
        self.imageSprite = newSprite;
    } else {
        [self addDefaultCameraIcon];
    }
}

- (SKTexture *)spriteFrame {
    return self.imageSprite.texture;
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    if (self.imageSprite) {
        [self.imageSprite pc_aspectFillParent];
        [self.imageSprite pc_centerInParent];
    } else {
        [self.cameraSprite pc_aspectFitInParent];
        [self.cameraSprite pc_centerInParent];
    }
}

#pragma mark - Private

- (void)addDefaultCameraIcon {
    NSString *iconPath = [self.plugIn.bundle pathForImageResource:@"Icon"];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:iconPath];
    sprite.userObject = [NodeInfo nodeInfoWithPlugIn:nil];
    sprite.anchorPoint = NSMakePoint(0.5, 0.5);

    [self addChild:sprite];
    [sprite pc_aspectFitInParent];
    [sprite pc_centerInParent];
    self.cameraSprite = sprite;
}

#pragma mark - Resources

- (void)showMissingResourceImageIfResourceMissing {
    NSString *uuid = [self extraPropForKey:@"spriteFrame"];
    if (uuid.length && ![[PCResourceManager sharedManager] resourceWithUUID:uuid]) {
        [self showMissingResourceImageWithKey:@"spriteFrame"];
    }
}

@end
