//
//  SKNode+AnchorPoint.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-31.
//
//

#import "SKNode+AnchorPoint.h"
#import "SKNode+CocosCompatibility.h"
#import "CGPointUtilities.h"
#import "SKNode+Sequencer.h"
#import "SequencerKeyframe.h"
#import "SequencerHandler.h"
#import "SequencerNodeProperty.h"

@implementation SKNode(AnchorPoint)

- (void)setPositionAgnosticAnchorPoint:(CGPoint)newAnchorPoint {
    CGPoint newAnchorPointInPixels = CGPointMake(self.contentSize.width * newAnchorPoint.x, self.contentSize.height * newAnchorPoint.y);
    CGPoint oldAnchorPointInPixels = CGPointMake(self.contentSize.width * self.anchorPoint.x, self.contentSize.height * self.anchorPoint.y);
    CGPoint childNodeTranslation = pc_CGPointSubtract(newAnchorPointInPixels, oldAnchorPointInPixels);
    for (SKNode *child in self.children) {
        [child translateAllPositionsBy:pc_CGPointMultiply(childNodeTranslation, -1)];
    }
    
    // -[SKNode convertPoint:toNode:] crashes with nil node (nil self.parent in this case)

    if (self.parent) {
        CGPoint newAnchorPointInParent = [self convertPoint:newAnchorPointInPixels toNode:self.parent];
        CGPoint oldAnchorPointInParent = [self convertPoint:oldAnchorPointInPixels toNode:self.parent];
        CGPoint myTranslation = pc_CGPointSubtract(newAnchorPointInParent, oldAnchorPointInParent);
        [self translateAllPositionsBy:myTranslation];
    }

    [self setAnchorPointSafely:newAnchorPoint];
}

- (CGPoint)positionAgnosticAnchorPoint {
    return self.anchorPoint;
}

- (void)setAnchorPointSafely:(CGPoint)anchorPoint {
    CGFloat originalXScale = self.xScale, originalYScale = self.yScale;
    self.xScale = 1, self.yScale = 1;
    self.anchorPoint = anchorPoint;
    self.xScale = originalXScale, self.yScale = originalYScale;
}

- (void)translateAllPositionsBy:(CGPoint)translation {
    self.position = pc_CGPointAdd(self.position, translation);
    [self translateAllKeyframesBy:translation];
    [self updateAnimateablePropertyValue:@[ @(self.position.x), @(self.position.y) ] propName:@"position" andCreateKeyFrameIfNone:NO withType:kCCBKeyframeTypePosition];
}

- (void)translateAllKeyframesBy:(CGPoint)translation {
    for (SequencerKeyframe *keyframe in [self keyframesForProperty:@"position"]) {
        NSArray *positionComponents = keyframe.value;
        CGPoint position = CGPointMake([positionComponents[0] floatValue], [positionComponents[1] floatValue]);
        CGPoint newPosition = pc_CGPointAdd(position, translation);
        keyframe.value = @[@(newPosition.x), @(newPosition.y)];
    }
}

@end
