//
//  CCBPSKTextField.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-22.
//
//

#import "CCBPSKTextField.h"
#import "PlugInNode.h"
#import "SKControlSubclass.h"
#import "PCResourceManager.h"

#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+NodeInfo.h"

static void * const CCBPSKTextFieldLayoutChangeContext = (void *)&CCBPSKTextFieldLayoutChangeContext;

@interface CCBPSKTextField ()

@property (strong, nonatomic) SKSpriteNode *backgroundSpriteNode;
@property (assign, nonatomic) NSUInteger keyboardType;

@end

@implementation CCBPSKTextField

+ (id)textFieldWithTexture:(SKTexture *)texture {
    return [[self alloc] initWithTexture:texture];
}

- (instancetype)init {
    self = [self initWithTexture:nil];
    return self;
}

- (id)initWithTexture:(SKTexture *)texture {
    self = [super init];
    if (self) {
        if (texture) {
            self.backgroundSpriteFrame = texture;
            [self addBackgroundSpriteNodeWithTexture:texture];
        }
        
        _padding = 4;
    }
    
    return self;
}

- (void)layout {
    [super layout];
    
    CGSize size = self.preferredSize;
    self.contentSize = size;

    if (self.backgroundSpriteNode) {
        self.backgroundSpriteNode.contentSize = self.backgroundSpriteNode.texture.size;
        self.backgroundSpriteNode.xScale = self.contentSize.width / self.backgroundSpriteNode.contentSize.width;
        self.backgroundSpriteNode.yScale = self.contentSize.height / self.backgroundSpriteNode.contentSize.height;
    }
}

- (void)addBackgroundSpriteNodeWithTexture:(SKTexture *)texture {
    if (self.backgroundSpriteNode) return;

    self.backgroundSpriteNode = [SKSpriteNode spriteNodeWithTexture:texture];
    self.backgroundSpriteNode.centerRect = CGRectMake(0.45, 0.45, .1, .1);
    [self addChild:self.backgroundSpriteNode];
    [self layout];
}

- (void)showMissingResourceImageIfResourceMissing {
    NSString *uuid = [self extraPropForKey:@"backgroundSpriteFrame"];
    if (![[PCResourceManager sharedManager] resourceWithUUID:uuid]) {
        [self showMissingResourceImageWithKey:@"backgroundSpriteFrame"];
    }
}

#pragma mark Properties

- (float)fontSizeInPoints {
    return self.fontSize;
}

- (void)setBackgroundSpriteFrame:(SKTexture *)backgroundSpriteFrame {
    if (!self.backgroundSpriteNode) {
        if (backgroundSpriteFrame) {
            [self addBackgroundSpriteNodeWithTexture:backgroundSpriteFrame];
        }
    } else {
        self.backgroundSpriteNode.texture = backgroundSpriteFrame;
        [self layout];
    }
}

- (SKTexture *)backgroundSpriteFrame {
    return self.backgroundSpriteNode.texture;
}

@end
