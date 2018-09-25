//
//  SKNode+Selection.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-08-08.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKNode (Selection)

typedef NS_ENUM(NSInteger, PCTransformEdgeHandle) {
    PCTransformEdgeHandleBottomLeft = 0,
    PCTransformEdgeHandleBottomRight,
    PCTransformEdgeHandleTopRight,
    PCTransformEdgeHandleTopLeft,
    PCTransformEdgeHandleBottom,
    PCTransformEdgeHandleRight,
    PCTransformEdgeHandleTop,
    PCTransformEdgeHandleLeft,

    PCTransformEdgeHandleCount = 8,
    PCTransformEdgeHandleNone
};

@property (nonatomic, assign, readonly) BOOL userSelectable;

/**
 @discussion Gets the corner points that should be used for the selection handles on a node. This takes into consideration how the handles will appear to the user - we do not want them to appear crowded, so this method does some size checks and keeps the handles far enough apart that the user should be able to see and click on all all points when the handles are rendered.
 @param points An array of 8 CGPoints that will be populated with the calculated points. THIS METHOD DOES NOT DO BOUNDS CHECKING. THIS MUST BE AN ARRAY OF 8 POINTS OR BAD THINGS WILL HAPPEN.
 @param targetNodeSpace The node space that the points should be in. The size check will be based on the size the node appears to be in this node space, not the size that the node is in its own node space.
 */
- (void)pc_calculateSelectionCornerPointsWithPoints:(CGPoint *)points inNodeSpace:(SKNode *)targetNodeSpace;

/**
 @discussion Gets the 8 points that represent the nodes corners and edges, in the nodes parent space, with no checks applied to the space between these points. Should note that for a node with a scale of 0, this will always calculate all points as being the nodes position.
 @param points The array to store the calculated points in. THIS METHOD DOES NOT DO BOUNDS CHECKING. THIS MUST BE AN ARRAY OF 8 POINTS OR BAD THINGS WILL HAPPEN.
 */
- (void)pc_calculateCornerPointsWithPoints:(CGPoint *)points;

/**
 @returns The SKTexture that should be used for rendering the node transform handles, as well as for any calculation about the space between such handles
 */
+ (SKTexture *)pc_handleTexture;

@end
