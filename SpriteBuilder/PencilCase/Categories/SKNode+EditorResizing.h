//
//  SKNode+EditorResizing.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-20.
//
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, PCAxis) {
    PCAxisHorizontal,
    PCAxisVertical,
};

@interface SKNode (EditorResizing)

/**
 Called when the user begins resizing a node to give the node a chance to update its appearance, state, etc.
 */
- (void)beginResizing;

/**
 Called when the user finishes resizing a node to give the node a chance to do anything it should do upon completion
 of resize, rather than having it update constantly while editing.
 */
- (void)finishResizing;

/**
 Calculates a new position for the node, thus that when it is dragged by a handle, the opposite handle will remaining in the exact same position.
 @param newScale a CGVector representing the scale that the node soon have
 @param cornerIndex The corner that the user is dragging, for determining the opposite corner.
 @returns The position the node should be set to when the scale is applied
 */
- (CGPoint)pc_positionWhenScaledToNewScale:(CGVector)newScale cornerIndex:(CCBCornerId)cornerIndex;

/**
 Given a mouse dragging a handle of the node, the new content size the node should be at, assuming that we do not want the
 opposite handle to move
 @param mousePosition the current position of the mouse, in our parents node space
 @param cornerIndex The corner that the user is dragging, for determining the opposite corner
 @returns The content size the node should be set to
 */
- (CGSize)pc_sizeFromMousePosition:(CGPoint)mousePosition cornerIndex:(CCBCornerId)cornerIndex;

/**
 Given a mouse dragging a handle of the node, the new scale the node will be at, assuming that we do not want the opposite handle to move
 @param mousePosition the position of the mouse
 @param cornerIndex The corner that the user is dragging, for determining the opposite corner.
 @returns The scale the node should be set to to
 */
- (CGVector)pc_scaleFromMousePosition:(CGPoint)mousePosition cornerIndex:(CCBCornerId)cornerIndex;

/**
 Calculates the new position for a node that will be given the new size, such that the opposite corner does not appear to move.
 @param contentSize what the nodes new size will be
 @param cornerIndex which corner is being dragged
 @returns The new position such that the opposite corner does not appear to shift
 */
- (CGPoint)pc_positionWhenContentSizeSetToSize:(CGSize)contentSize cornerIndex:(CCBCornerId)cornerIndex;

/**
 Locks the aspect ratio of scale to the given axis. The idea is that the caller wants to lock the scale aspect ratio by explicitly choosing which axis to hold fixed and which to change
 @param scale The proposed scale of the node
 @param axis The axis to hold fixed (implying that the other axis is the one that is changed)
 @returns The scale locked into an aspect ratio of 1
 */
+ (CGVector)pc_lockAspectRatioOfScale:(CGVector)scale toAxis:(PCAxis)axis;

/**
 Given that the user is dragging a handle of a node, lock it to an aspect ratio based on which handle
 @param scale The desired scale of the node, without being locked to an aspect ratio
 @param cornerIndex the corner that the user is scaling the node with
 @returns The scale locked into an aspect ratio
 */
+ (CGVector)pc_lockAspectRatioOfScale:(CGVector)scale cornerIndex:(CCBCornerId)cornerIndex;

/**
 Locks the aspect ratio of the node's content size to the given axis. The idea is that the caller wants to lock the size aspect ratio by explicitly choosing which axis to hold fixed and which to change
 @param size The proposed size for the node before being locked to an aspect ratio
 @param axis The axis to hold fixed (implying that the other axis is the one that is changed)
 @returns The content size locked into an aspect ratio of 1
 */
- (CGSize)pc_lockAspectRatioOfSize:(CGSize)size toAxis:(PCAxis)axis;

/**
 Given the the user is dragging a handle of a node, lock the content size to an aspect ratio
 @param size the proposed size for the node before being locked to an aspect ratio
 @param cornerIndex the corner that the user is resizing the node with
 @returns the content sie locked to an aspect ratio
 */
- (CGSize)pc_lockAspectRatioOfSize:(CGSize)size cornerIndex:(CCBCornerId)cornerIndex;

/**
 Makes the frame origin and size integral so that we don't have to deal with subpixels
 */
- (void)pc_makeFrameIntegral;

@end
