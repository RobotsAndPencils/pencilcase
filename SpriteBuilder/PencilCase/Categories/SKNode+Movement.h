//
//  SKNode+Movement.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-09.
//
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, PCMoveDirection) {
    PCMoveDirectionLeft,
    PCMoveDirectionRight,
    PCMoveDirectionUp,
    PCMoveDirectionDown
};

typedef NS_ENUM(NSUInteger, PCAlignment) {
    PCAlignmentHorizontalCenter,
    PCAlignmentVerticalCenter,
    PCAlignmentLeft,
    PCAlignmentRight,
    PCAlignmentTop,
    PCAlignmentBottom,
    PCAlignmentAcross,
    PCAlignmentDown,
    PCAlignmentSameWidth,
    PCAlignmentSameHeight,
    PCAlignmentSameSize
};

@interface SKNode (Movement)

/**
 Aligns the given nodes with the given alignment type
 @param nodes The nodes to align
 @param alignmentType how to align the nodes with each other
 */
+ (void)pc_alignNodes:(NSArray *)nodes withAlignment:(PCAlignment)alignmentType;

/**
 Moves the given nodes in the given direction
 @param nodes The nodes to move
 @param direction the direction to move the nodes in
 */
+ (void)pc_moveNodes:(NSArray *)nodes inDirection:(PCMoveDirection)direction;

/**
 Nudges the nodes in the given direction
 @param nodes the nodes to move
 @param direction the direction to move the nodes in
 */
+ (void)pc_nudgeNodes:(NSArray *)nodes inDirection:(PCMoveDirection)direction;


/**
 *  Align all node edges to the outermost coordinate of that edge type
 *
 *  @param nodes The nodes to align
 *  @param alignmentType The edge to use for alignment
 */
+ (void)pc_alignNodes:(NSArray *)nodes toEdgeWithAlignmentType:(PCAlignment)alignmentType;

/**
 *  Align nodes to the center between the maximum and minimum coordinates along the alignment axis
 *  e.g. find center . between objects [ ] on stage: |       [ ]     .     [ ] |
 *
 *  @param nodes The nodes to align
 *  @param alignmentType The axes used to align to
 */
+ (void)pc_alignNodes:(NSArray *)nodes toCenterWithAlignmentType:(PCAlignment)alignmentType;

/**
 *  Based on the leftmost and rightmost coordinates of the currently selected nodes, distributes nodes in-between those two end nodes with even spacing
 *  Requires three or more nodes to be selected to perform any work, because otherwise there is no work to do
 *
 *  @param objects Objects to distribute
 */
+ (void)pc_distributeNodesHorizontally:(NSArray *)nodes;

/**
 *  Based on the bottommost and topmost coordinates of the currently selected nodes, distributes nodes in-between those two end nodes with even spacing
 *  Requires three or more nodes to be selected to perform any work, because otherwise there is no work to do
 *
 *  @param objects Objects to distribute
 */
+ (void)pc_distributeNodesVertically:(NSArray *)nodes;

/**
 *  Match all selected nodes to either the parent (if only one selected node) or the first selected node
 *
 *  @param objects Objects to match
 *  @param matchSizeType The type of size matching to do
 */
+ (void)pc_matchNodes:(NSArray *)nodes sizeWithType:(int)matchSizeType;

/**
 *  Sets the position of nodes to integral values by rounding
 *
 *  Rounds up from 0.5, down otherwise
 *
 *  @param nodes Nodes to align
 */
+ (void)pc_alignNodesToPixels:(NSArray *)nodes;

@end
