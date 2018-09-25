//
//  PCSKForceNode.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-21.
//
//

#import "PCSKForceNode.h"
#import "PositionPropertySetter.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+LifeCycle.h"
#import "PlugInNode.h"

@interface PCSKForceNode ()
@property (nonatomic) BOOL wasHiddenBeforePreview;
@end

@implementation PCSKForceNode

- (BOOL)canParticipateInPhysics {
    return NO;
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self setup];
}

#pragma mark - Private

- (void)setup {
    if (!self.texture) {
        self.anchorPoint = NSMakePoint(0.5, 0);
        
        NSString *arrowPath = [[self.plugIn bundle] pathForImageResource:@"force-arrow"];
        self.texture = [SKTexture textureWithImageNamed:arrowPath];
        self.contentSize = self.texture.size;
    }
}

- (BOOL)shouldHideForPreview {
    return !self.drawArrow;
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

@end
