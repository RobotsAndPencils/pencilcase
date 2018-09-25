//
//  SKNode+EditorResizing.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-20.
//
//

#import "SKNode+EditorResizing.h"
#import "SKNode+NodeInfo.h"
#import "CGPointUtilities.h"
#import "PCMathUtilities.h"
#import "CGSizeUtilities.h"
#import "SKNode+CoordinateConversion.h"
#import "PCStageScene.h"

@implementation SKNode (EditorResizing)

- (void)beginResizing {
    /* Empty implementation - Subclasses may override */
}

- (void)finishResizing {
    /* Empty implementation - Subclasses may override */
}

- (CGFloat)pc_centerXAroundCenterWithNewSize:(CGSize)newSize newScale:(CGVector)newScale {
    CGFloat currentCenter = self.position.x + (fabs(self.size.width) * (0.5f - self.anchorPoint.x)) * pc_sign(self.xScale);
    CGFloat offset = newSize.width * (0.5f - self.anchorPoint.x);
    if (PCEditorResizeBehaviourScale == self.editorResizeBehaviour) {
        offset *= pc_sign(newScale.dx);
    }
    return currentCenter - offset;
}

- (CGFloat)pc_centerYAroundCenterWithNewSize:(CGSize)newSize newScale:(CGVector)newScale {
    CGFloat currentCenter = self.position.y + (fabs(self.size.height) * (0.5f - self.anchorPoint.y)) * pc_sign(self.yScale);
    CGFloat offset = newSize.height * (0.5f - self.anchorPoint.y);
    if (PCEditorResizeBehaviourScale == self.editorResizeBehaviour) {
        offset *= pc_sign(newScale.dy);
    }
    return currentCenter - offset;
}

+ (BOOL)pc_shouldTreatCornerAsOppositeWithScale:(CGFloat)scale initialScale:(CGFloat)initialScale resizeBehaviour:(PCEditorResizeBehaviour)resizeBehaviour {
    //No fancy resizing shenanigans with resize behaviour
    if (resizeBehaviour == PCEditorResizeBehaviourContentSize) return scale < 0;
    //When the scales have opposite signs, that means that since the transform began the user is on the opposite side that they started and so we should treat our transform handle as the opposite handle. Likewise, if scale < 0, then our node is inverted as their anchor point will be flipped. If both are true they cancel each other out.
    return (scale * initialScale < 0) != (scale < 0);
}

+ (CGFloat)pc_staticPositionSuchThatCornerOpposite:(BOOL)lesserCorner /*Left or bottom*/ doesNotMoveFromPosition:(CGFloat)position size:(CGFloat)size anchorPoint:(CGFloat)anchorPoint flipped:(BOOL)flipped {
    //Simplification if (lesserCorner && !flipped || !lesserCorner && flipped), aka, should we treat this as the 'lesser' (left, bottom) corner
    if (lesserCorner != flipped) {
        /*
         +----------+
         |          |}  Given that we are moving the handle [|] and that our position (which matches our anchor point) is at x,
        [|] x       |}  The side that will not move is the greater side, so we want to find the distance to that. This is given
         |          |}  by the formula p' = p + s * (1 - a), where a is the value of x as a ratio to the full size of the object,
         +----------+   typically (but not always!) in the range 0 - 1
         */
        return position + size * (1 - anchorPoint);
    } else {
        /*
         +----------+
        {|          |  Given that we are moving the handle [|] and that our position (which matches our anchor point) is at x,
        {| x       [|] The side that will not move is the lesser side, so we want to find the distance to that. This is given
        {|          |  by the formula p' = p - s * a, where a is the value of x as a ratio to the full size of the object,
         +----------+   typically (but not always!) in the range 0 - 1
         */
        return position - size * anchorPoint;
    }
}

+ (CGFloat)pc_positionSuchThatCornerOpposite:(BOOL)lesserCorner /*Left or bottom*/ doesNotMoveFromStaticPosition:(CGFloat)position size:(CGFloat)size anchorPoint:(CGFloat)anchorPoint flipped:(BOOL)flipped {
    //Simplification of if (lesserCorner && !flipped || !lesserCorner && flipped), aka, should we treat this as the 'lesser' (left, bottom) corner
    if (lesserCorner != flipped) {
        /*
         +----------+
         |          |}  Given that we are moving the handle[|] and have already calculated the static position that will not move |},
        [|] x       |}  figure out what our position (anchor point) will be. This is given from the formula p' = p - s * (1 - a), where
         |          |}  a is hte value of x as a ratio to the full size of the object, typically (but not always!) in the range 0 - 1
         +----------+
         */
        return position - size * (1 - anchorPoint);
    } else {
        /*
         +----------+
        {|          |  Given that we are moving the handle [|] and have already calculated the static position that will not move {|,
        {| x       [|] figure out what our new position should be. This comes from the formula p' = p + s * a, where a is the value of
        {|          |  x as a ratio to the full size of the object, typically (but not always) in the range 0-1
         +----------+
         */
        return position + size * anchorPoint;
    }
}

+ (CGFloat)pc_newSizeMultiplierForResizeBehaviour:(PCEditorResizeBehaviour)resizeBehaviour currentScale:(CGFloat)currentScale newScale:(CGFloat)newScale flippedAfterNewScale:(BOOL)flippedAfterNewScale {
    switch (resizeBehaviour) {
        case PCEditorResizeBehaviourContentSize:
            return (flippedAfterNewScale ? -1 : 1) * pc_sign(currentScale);
        case PCEditorResizeBehaviourScale:
        default:
            return pc_sign(newScale);
    }
}

- (CGFloat)pc_xPositionSuchThatCornerOpposite:(CCBCornerId)cornerIndex doesNotMoveWithNewSize:(CGSize)newSize newScale:(CGVector)newScale {
    if (!CCBCornerIdIsOnLeftSide(cornerIndex) && !CCBCornerIdIsOnRightSide(cornerIndex)) return self.position.x;
    BOOL cornerIsLesserCorner = CCBCornerIdIsOnLeftSide(cornerIndex);

    BOOL flippedXAxisBeforeNewScale = [SKNode pc_shouldTreatCornerAsOppositeWithScale:self.xScale initialScale:self.transformStartScaleX resizeBehaviour:self.editorResizeBehaviour];
    CGFloat oldSizeMultiplier = pc_sign(self.xScale);
    CGFloat staticXPosition = [SKNode pc_staticPositionSuchThatCornerOpposite:cornerIsLesserCorner doesNotMoveFromPosition:self.position.x size:fabs(self.size.width) * oldSizeMultiplier anchorPoint:self.anchorPoint.x flipped:flippedXAxisBeforeNewScale];

    BOOL flippedXAxisAfterNewScale = [SKNode pc_shouldTreatCornerAsOppositeWithScale:newScale.dx initialScale:self.transformStartScaleX resizeBehaviour:self.editorResizeBehaviour];
    CGFloat newSizeMultiplier = [SKNode pc_newSizeMultiplierForResizeBehaviour:self.editorResizeBehaviour currentScale:self.xScale newScale:newScale.dx flippedAfterNewScale:flippedXAxisAfterNewScale];
    return [SKNode pc_positionSuchThatCornerOpposite:cornerIsLesserCorner doesNotMoveFromStaticPosition:staticXPosition size:newSize.width * newSizeMultiplier anchorPoint:self.anchorPoint.x flipped:flippedXAxisAfterNewScale];

}

- (CGFloat)pc_yPositionSuchThatCornerOpposite:(CCBCornerId)cornerIndex doesNotMoveWithNewSize:(CGSize)newSize newScale:(CGVector)newScale {
    if (!CCBCornerIdIsOnBottomSide(cornerIndex) && !CCBCornerIdIsOnTopSide(cornerIndex)) return self.position.y;
    BOOL cornerIsLesserCorner = CCBCornerIdIsOnBottomSide(cornerIndex);

    BOOL flippedYAxisBeforeNewScale = [SKNode pc_shouldTreatCornerAsOppositeWithScale:self.yScale initialScale:self.transformStartScaleY resizeBehaviour:self.editorResizeBehaviour];
    CGFloat oldSizeMultiplier = pc_sign(self.yScale);
    CGFloat staticYPosition = [SKNode pc_staticPositionSuchThatCornerOpposite:cornerIsLesserCorner doesNotMoveFromPosition:self.position.y size:fabs(self.size.height) * oldSizeMultiplier anchorPoint:self.anchorPoint.y flipped:flippedYAxisBeforeNewScale];

    BOOL flippedYAxisAfterNewScale = [SKNode pc_shouldTreatCornerAsOppositeWithScale:newScale.dy initialScale:self.transformStartScaleY resizeBehaviour:self.editorResizeBehaviour];
    CGFloat newSizeMultiplier = [SKNode pc_newSizeMultiplierForResizeBehaviour:self.editorResizeBehaviour currentScale:self.yScale newScale:newScale.dy flippedAfterNewScale:flippedYAxisAfterNewScale];
    return [SKNode pc_positionSuchThatCornerOpposite:cornerIsLesserCorner doesNotMoveFromStaticPosition:staticYPosition size:newSize.height * newSizeMultiplier anchorPoint:self.anchorPoint.y flipped:flippedYAxisAfterNewScale];
}

- (CGPoint)pc_positionWhenScaledToNewScale:(CGVector)newScale cornerIndex:(CCBCornerId)cornerIndex {
    //The rule is always that when a drag handle is moved, the opposite drag handle should appear not to move. So if you move the left drag handle, the right edge should not move. If you move the top left drag handle, the bottom right should not move. &c.
    CGSize newSize = CGSizeMake(self.contentSize.width * fabs(newScale.dx), self.contentSize.height * fabs(newScale.dy));
    return [self pc_positionWhenContentSizeSetToSize:newSize newScale:newScale cornerIndex:cornerIndex];
}

- (CGPoint)pc_positionWhenContentSizeSetToSize:(CGSize)newSize newScale:(CGVector)newScale cornerIndex:(CCBCornerId)cornerIndex  {
    CGPoint newPosition = self.position;
    if (CCBCornerIdIsVerticalEdge(cornerIndex)) {
        newPosition.x = [self pc_centerXAroundCenterWithNewSize:newSize newScale:newScale];
    } else {
        newPosition.x = [self pc_xPositionSuchThatCornerOpposite:cornerIndex doesNotMoveWithNewSize:newSize newScale:newScale];
    }

    if (CCBCornerIdIsHorizontalEdge(cornerIndex)) {
        newPosition.y = [self pc_centerYAroundCenterWithNewSize:newSize newScale:newScale];
    } else {
        newPosition.y = [self pc_yPositionSuchThatCornerOpposite:cornerIndex doesNotMoveWithNewSize:newSize newScale:newScale];
    }

    CGPoint translation = pc_CGPointSubtract(newPosition, self.position);
    translation = CGPointApplyAffineTransform(translation, CGAffineTransformMakeRotation(self.zRotation));
    newPosition = pc_CGPointAdd(self.position, translation);

    return newPosition;
}

- (CGSize)pc_sizeFromMousePosition:(CGPoint)mousePosition cornerIndex:(CCBCornerId)cornerIndex {
    CGSize desiredSize = CGSizeMake(fabs(self.size.width) * pc_sign(self.xScale),
                                    fabs(self.size.height) * pc_sign(self.yScale));

    CGPoint mousePositionWithoutRotation = pc_CGPointSubtract(mousePosition, self.position);
    mousePositionWithoutRotation = CGPointApplyAffineTransform(mousePositionWithoutRotation, CGAffineTransformMakeRotation(-self.zRotation));
    mousePositionWithoutRotation = pc_CGPointAdd(mousePositionWithoutRotation, self.position);

    BOOL nodeHasFlippedXAxis = self.editorResizeBehaviour == PCEditorResizeBehaviourScale && self.transformStartScaleX * self.xScale < 0;
    if ((CCBCornerIdIsOnRightSide(cornerIndex) && !nodeHasFlippedXAxis) || (CCBCornerIdIsOnLeftSide(cornerIndex) && nodeHasFlippedXAxis)) {
        if (self.xScale >= 0) {
            CGFloat currentLeft = self.position.x - fabs(self.size.width) * self.anchorPoint.x;
            desiredSize.width = mousePositionWithoutRotation.x - currentLeft;
        } else {
            CGFloat currentLeft = self.position.x - fabs(self.size.width) * (1 - self.anchorPoint.x);
            desiredSize.width = -(mousePositionWithoutRotation.x - currentLeft);
        }
    } else if ((CCBCornerIdIsOnLeftSide(cornerIndex) && !nodeHasFlippedXAxis) || (CCBCornerIdIsOnRightSide(cornerIndex) && nodeHasFlippedXAxis)) {
        if (self.xScale >= 0) {
            CGFloat currentRight = self.position.x + fabs(self.size.width) * (1 - self.anchorPoint.x);
            desiredSize.width = currentRight - mousePositionWithoutRotation.x;
        } else {
            CGFloat currentRight = self.position.x + fabs(self.size.width) * self.anchorPoint.x;
            desiredSize.width = -(currentRight - mousePositionWithoutRotation.x);
        }
    }

    BOOL nodeHasFlippedYAxis = self.editorResizeBehaviour == PCEditorResizeBehaviourScale && self.transformStartScaleY * self.yScale < 0;
    if ((CCBCornerIdIsOnTopSide(cornerIndex) && !nodeHasFlippedYAxis) || (CCBCornerIdIsOnBottomSide(cornerIndex) && nodeHasFlippedYAxis)) {
        if (self.yScale >= 0) {
            CGFloat currentBottom = self.position.y - fabs(self.size.height) * self.anchorPoint.y;
            desiredSize.height = mousePositionWithoutRotation.y - currentBottom;
        } else {
            CGFloat currentBottom = self.position.y - fabs(self.size.height) * (1 - self.anchorPoint.y);
            desiredSize.height = -(mousePositionWithoutRotation.y - currentBottom);
        }
    } else if ((CCBCornerIdIsOnBottomSide(cornerIndex) && !nodeHasFlippedYAxis) || (CCBCornerIdIsOnTopSide(cornerIndex) && nodeHasFlippedYAxis)) {
        if (self.yScale >= 0) {
            CGFloat currentTop = self.position.y + fabs(self.size.height) * (1 - self.anchorPoint.y);
            desiredSize.height = currentTop - mousePositionWithoutRotation.y;
        } else {
            CGFloat currentTop = self.position.y + fabs(self.size.height) * self.anchorPoint.y;
            desiredSize.height = -(currentTop - mousePositionWithoutRotation.y);
        }
    }
    return desiredSize;
}

- (CGVector)pc_scaleFromMousePosition:(CGPoint)mousePosition cornerIndex:(CCBCornerId)cornerIndex {
    CGSize desiredSize = [self pc_sizeFromMousePosition:mousePosition cornerIndex:cornerIndex];
    return CGVectorMake(desiredSize.width / self.contentSize.width, desiredSize.height / self.contentSize.height);
}

- (CGPoint)pc_positionWhenContentSizeSetToSize:(CGSize)contentSize cornerIndex:(CCBCornerId)cornerIndex {
    CGVector newScale = CGVectorMake(pc_sign(contentSize.width), pc_sign(contentSize.height));
    return [self pc_positionWhenContentSizeSetToSize:contentSize newScale:newScale cornerIndex:cornerIndex];
}

+ (CGVector)pc_lockAspectRatioOfScale:(CGVector)scale toAxis:(PCAxis)axis {
    if (axis == PCAxisHorizontal) {
        scale.dy = fabs(scale.dx) * pc_sign(scale.dy);
    } else {
        scale.dx = fabs(scale.dy) * pc_sign(scale.dx);
    }
    return scale;
}

+ (CGVector)pc_lockAspectRatioOfScale:(CGVector)scale cornerIndex:(CCBCornerId)cornerIndex {
    BOOL lockHorizontal;

    if (CCBCornerIdIsOnCorner(cornerIndex)) {
        lockHorizontal = fabs(scale.dx) < fabs(scale.dy);
    } else {
        lockHorizontal = CCBCornerIdIsHorizontalEdge(cornerIndex);
    }

    PCAxis axis = lockHorizontal ? PCAxisHorizontal : PCAxisVertical;
    return [self pc_lockAspectRatioOfScale:scale toAxis:axis];
}

- (CGSize)pc_lockAspectRatioOfSize:(CGSize)size toAxis:(PCAxis)axis {
    CGVector sizeAsScale = CGVectorMake(size.width / self.contentSize.width, size.height / self.contentSize.height);
    CGVector aspectRatioLockedScale = [SKNode pc_lockAspectRatioOfScale:sizeAsScale toAxis:axis];
    return CGSizeMake(aspectRatioLockedScale.dx * self.contentSize.width, aspectRatioLockedScale.dy * self.contentSize.height);
}

- (CGSize)pc_lockAspectRatioOfSize:(CGSize)size cornerIndex:(CCBCornerId)cornerIndex {
    CGVector sizeAsScale = CGVectorMake(size.width / self.contentSize.width, size.height / self.contentSize.height);
    CGVector aspectRatioLockedScale = [SKNode pc_lockAspectRatioOfScale:sizeAsScale cornerIndex:cornerIndex];
    return CGSizeMake(aspectRatioLockedScale.dx * self.contentSize.width, aspectRatioLockedScale.dy * self.contentSize.height);
}

- (void)pc_makeFrameIntegral {
    SKNode *rootNode = [PCStageScene scene].rootNode;

    // determine the scale and position in world space
    CGVector worldScale = [self.parent pc_convertScaleToWorldSpace:CGVectorMake(self.xScale, self.yScale)];
    CGPoint worldPosition = [self.parent pc_convertToWorldSpace:self.position];

    // convert to root space (i.e. the card's coord system)
    CGVector rootScale = [rootNode pc_convertScaleToNodeSpace:worldScale];
    CGPoint rootPosition = [rootNode pc_convertToNodeSpace:worldPosition];
    CGSize rootSize = CGSizeMake(self.contentSize.width * rootScale.dx, self.contentSize.height * rootScale.dy);
    CGRect rootFrame = CGRectMake(rootPosition.x - self.anchorPoint.x * rootSize.width, rootPosition.y - self.anchorPoint.y * rootSize.height, rootSize.width, rootSize.height);

    // align size and origin to whole pixels in root space
    CGSize integralRootSize = pc_CGSizeIntegral(rootFrame.size);
    CGPoint integralRootOrigin = pc_CGPointIntegral(rootFrame.origin);
    CGPoint integralRootPosition = CGPointMake(integralRootOrigin.x + self.anchorPoint.x * integralRootSize.width, integralRootOrigin.y + self.anchorPoint.y * integralRootSize.height);

    // now convert the integral values back to world space
    CGSize integralWorldSize = [rootNode pc_convertSize:integralRootSize toNode:rootNode.scene];
    CGPoint integralWorldPosition = [rootNode pc_convertToWorldSpace:integralRootPosition];

    // then convert to parent space
    self.position = [self.parent pc_convertToNodeSpace:integralWorldPosition];

    if ([self editorResizeBehaviour] == PCEditorResizeBehaviourScale) {
        // adjust the scale while holding the node's contentSize constant
        CGVector integralWorldScale = CGVectorMake(integralWorldSize.width / (self.contentSize.width ?: 1), integralWorldSize.height / (self.contentSize.height ?: 1));
        CGVector integralScale = [self.parent pc_convertScaleToNodeSpace:integralWorldScale];
        self.xScale = integralScale.dx;
        self.yScale = integralScale.dy;
    }
    else {
        // adjust the contentSize while holding the node's scale constant
        integralRootSize = [rootNode pc_convertSize:integralRootSize toNode:self.parent];
        self.contentSize = CGSizeMake(integralRootSize.width / self.xScale, integralRootSize.height / self.yScale);
    }
}

@end
