//
//  SKNode+CoordinateConversion.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-07-08.
//
//

#import <SpriteKit/SpriteKit.h>


@interface SKNode (CoordinateConversion)

- (void)pc_translateFromParent:(SKNode *)parent toParent:(SKNode *)insertionNode;

- (CGPoint)pc_convertToNodeSpace:(CGPoint)worldPoint;
- (CGPoint)pc_convertToWorldSpace:(CGPoint)nodePoint;
- (CGFloat)pc_convertRotationInDegreesToNodeSpace:(CGFloat)rotation;
- (CGFloat)pc_convertRotationInDegreesToWorldSpace:(CGFloat)rotation;
- (CGVector)pc_convertScaleToNodeSpace:(CGVector)worldScale;
- (CGVector)pc_convertScaleToWorldSpace:(CGVector)nodeScale;
- (CGAffineTransform)pc_nodeToParentTransform;

- (CGAffineTransform)pc_nodeToAncestorSpaceTransform:(SKNode *)target;

/**
 Centers the node in its parent
 */
- (void)pc_centerInParent;

/**
 Aspect fits the node in its parent, without stretching the node (max possible scale is 1, 1)
 */
- (void)pc_aspectFitInParent;

/**
  Aspect fills the node in its parent, stretching the node if necessary
 */
- (void)pc_aspectFillParent;


#pragma mark - Size

/**
 Calculates what the provided size, in my space, would be in another nodes space.
 @param size The size to convert
 @param node The node to convert the size to. The node can be an ancestor or this, or this could be an ancestor of that, or they could exist at completely different points in the node tree, and the size will be converted. The only case in which a size cannot be calculated is when the nodes are not both members of the same scene.
 @returns The calculated size, or CGSizeZero if the nodes were in different scenes or this node was not included in any scene.
 */
- (CGSize)pc_convertSize:(CGSize)size toNode:(SKNode *)node;

@end
