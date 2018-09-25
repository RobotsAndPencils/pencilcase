//
//  PCSKSliderNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-22.
//
//

#import "PCSKSliderNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+NodeInfo.h"
#import "PlugInNode.h"

@interface PCSKSliderNode ()

@property (assign, nonatomic) CGFloat minimumValue;
@property (assign, nonatomic) CGFloat maximumValue;
@property (assign, nonatomic) CGFloat currentValue;

@end

@implementation PCSKSliderNode

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self setup];
}

#pragma mark - Private

- (void)setup {
    if (!self.texture) {
        NSString *imagePath = [[self.plugIn bundle] pathForImageResource:@"slider"];
        self.texture = [SKTexture textureWithImageNamed:imagePath];
        self.contentSize = self.texture.size;
    }
}

#pragma mark - Properties

@end
