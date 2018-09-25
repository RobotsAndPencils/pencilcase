//
//  PCBSKTextInputView.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-08-10.
//
//

#import "PCBSKTextInputView.h"

#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+NodeInfo.h"
#import "CGPointUtilities.h"
#import "PCResourceManager.h"

@interface PCBSKTextInputView ()

@property (strong, nonatomic) NSView *view;
@property (strong, nonatomic) SKSpriteNode *backgroundSprite;

///There is a bug in sprite kit where an SKSpriteNode with centerRect set that renders for the first time with an opacity of 0 will fail out with EXC_BAD_ACCESS. Interestingly, if the SKSpriteNode _starts_ with a non-0 opacity and it is subsequently reduced to 0, the crash does not seem to occur, although it does on next card load. We work around this, but we still want our users to be able to select an opacity of 0, so we track the 'real' opacity with this float.
@property (assign, nonatomic) CGFloat realOpacity;

@end

@implementation PCBSKTextInputView

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

#pragma mark - Private

- (void)layout {
    if (self.backgroundSprite.texture) {
        self.backgroundSprite.contentSize = self.backgroundSprite.texture.size;
        self.backgroundSprite.xScale = self.contentSize.width / self.backgroundSprite.contentSize.width;
        self.backgroundSprite.yScale = self.contentSize.height / self.backgroundSprite.contentSize.height;
    }
    [self.backgroundSprite pc_centerInParent];
}

#pragma mark - Properties

- (void)setBackgroundSpriteFrame:(SKTexture *)texture {
    if (!self.backgroundSprite) {
        self.backgroundSprite = [SKSpriteNode node];
        self.backgroundSprite.centerRect = CGRectMake(0.45, 0.45, .1, .1);
        if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:pc_ElCapitanOperatingSystemVersion]) {
            self.backgroundSprite.colorBlendFactor = 0.99;
        }
        [self addChild:self.backgroundSprite];
    }
    self.backgroundSprite.texture = texture;
    [self layout];
}

- (void)setOpacity:(CGFloat)opacity {
    self.realOpacity = opacity;
    [super setOpacity:MAX(opacity, 0.01f)];
    self.backgroundSprite.hidden = opacity <= 0;
}

- (CGFloat)opacity {
    return self.realOpacity;
}

- (SKTexture *)backgroundSpriteFrame {
    return self.backgroundSprite.texture;
}

- (void)showMissingResourceImageIfResourceMissing {
    NSString *uuid = [self extraPropForKey:@"backgroundSpriteFrame"];
    if (![[PCResourceManager sharedManager] resourceWithUUID:uuid]) {
        [self showMissingResourceImageWithKey:@"backgroundSpriteFrame"];
    }
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self layout];
}

- (void)setXScale:(CGFloat)xScale {
    [super setXScale:xScale];
    [self layout];
}

- (void)setYScale:(CGFloat)yScale {
    [super setYScale:yScale];
    [self layout];
}

#pragma mark - PCFontConsuming

- (NSDictionary *)fontNamesAndSizes {
    return @{self.fontName:@[@(self.fontSize)]};
}

@end
