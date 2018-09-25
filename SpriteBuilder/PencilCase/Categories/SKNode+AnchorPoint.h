//
//  SKNode+AnchorPoint.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-31.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKNode(AnchorPoint)

/**
 The anchor point for the node, except that the setter does some math to keep the node visually at the same place.
 @note Why a property? So that the Inspector could tie into this.
 */
@property (assign, nonatomic) CGPoint positionAgnosticAnchorPoint;

/**
 SpriteKit has a pretty serious bug where setting the anchor point on a node with a negative scale just breaks it badly (Flips it, moves it, etc.). This method gets around this by temporarily giving the node a positive scale before setting the anchor point.
 @param anchorPoint The new anchor point
 */
- (void)setAnchorPointSafely:(CGPoint)anchorPoint;

/**
 Update that nodes position keyframes by a given translation.
 @param translation The amount to move the node's keyframes by
 */
- (void)translateAllKeyframesBy:(CGPoint)translation;

@end
