//
//  PCFrameSnapping.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-21.
//
//

#import "PCSnapFrame.h"
#import "CGPointUtilities.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+EditorResizing.h"
#import "PCMathUtilities.h"

@implementation PCSnapFrame

- (id)initWithNode:(SKNode *)node {
    self = [super init];
    if (self) {
        self.frame = [self createFrameFromNode:node];
        self.node = node;
    }
    return self;
}

- (CGRect)createFrameFromNode:(SKNode *)node {
    if (node == nil) return CGRectZero;
    CGVector worldScale = [node.parent pc_convertScaleToWorldSpace:CGVectorMake(node.xScale, node.yScale)];
    CGFloat worldRotation = [node.parent pc_convertRotationInDegreesToWorldSpace:node.rotation];
    CGPoint worldPosition = [node.parent pc_convertToWorldSpace:node.position];

    SKNode *rootNode = [PCStageScene scene].rootNode;
    CGVector rootScale = [rootNode pc_convertScaleToNodeSpace:worldScale];
    CGSize rootSize = CGSizeMake(node.contentSize.width * rootScale.dx, node.contentSize.height * rootScale.dy);
    CGFloat rootRotation = [rootNode.parent pc_convertRotationInDegreesToNodeSpace:worldRotation];
    CGPoint rootPosition = [rootNode pc_convertToNodeSpace:worldPosition];

    CGRect frame = CGRectMake(rootPosition.x - node.anchorPoint.x * rootSize.width, rootPosition.y - node.anchorPoint.y * rootSize.height, rootSize.width, rootSize.height);

    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, rootPosition.x, rootPosition.y);
    transform = CGAffineTransformRotate(transform, DEGREES_TO_RADIANS(rootRotation));
    transform = CGAffineTransformTranslate(transform, -rootPosition.x, -rootPosition.y);

    CGRect smallestRect = CGRectApplyAffineTransform(frame, transform);

    // the previous transform will returning the smallest containing rect of the transformed rect and thus
    // looses the fact that the original rect may have been inverted (i.e. inverted scale)
    CGPoint origin = smallestRect.origin;
    CGSize size = smallestRect.size;

    if (pc_sign(smallestRect.size.width) != pc_sign(rootSize.width)) {
        origin.x -= rootSize.width;
        size.width *= -1;
    }
    if (pc_sign(smallestRect.size.height) != pc_sign(rootSize.height)) {
        origin.y -= rootSize.height;
        size.height *= -1;
    }

    smallestRect.origin = origin;
    smallestRect.size = size;

    self.anchorInFrame = CGPointMake(rootPosition.x - smallestRect.origin.x, rootPosition.y - smallestRect.origin.y);

    return smallestRect;

}

- (id)initWithGuide:(PCGuide *)guide {
    self = [super init];
    if (self) {
        SKNode *bgLayer = [PCStageScene scene].bgLayer;
        CGFloat stageSize = bgLayer.frame.size.width;
        switch (guide.orientation) {
            case PCGuideOrientationHorizontal:
                return [[PCSnapFrame alloc] initWithFrame:CGRectMake(-stageSize, guide.position, stageSize, 1)];

            case PCGuideOrientationVertical:
            default:
                return [[PCSnapFrame alloc] initWithFrame:CGRectMake(guide.position, -stageSize, 1, stageSize)];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom {
    return self.frame.origin.y;
}

- (CGFloat)top {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)centerX {
    return self.frame.origin.x + self.frame.size.width * 0.5f;
}

- (CGFloat)centerY {
    return self.frame.origin.y + self.frame.size.height * 0.5f;
}

- (void)setLeft:(CGFloat)left {
    self.frame = CGRectMake(left, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setRight:(CGFloat)right {
    self.frame = CGRectMake(right - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setCenterX:(CGFloat)centerX {
    self.frame = CGRectMake(centerX - self.frame.size.width * 0.5f, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setTop:(CGFloat)top {
    self.frame = CGRectMake(self.frame.origin.x, top - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)setBottom:(CGFloat)bottom {
    self.frame = CGRectMake(self.frame.origin.x, bottom, self.frame.size.width, self.frame.size.height);
}

- (void)setCenterY:(CGFloat)centerY {
    self.frame = CGRectMake(self.frame.origin.x, centerY - self.frame.size.height * 0.5f, self.frame.size.width, self.frame.size.height);
}

- (NSArray *)siblingNodesSortedByDistance:(NSMutableArray *)sourceArray {
    return [sourceArray sortedArrayUsingComparator:^NSComparisonResult(PCSnapFrame *firstNode, PCSnapFrame *secondNode) {
        CGFloat distanceToFirstNode = pc_CGPointDistance(self.frame.origin, firstNode.frame.origin);
        CGFloat distanceToSecondNode = pc_CGPointDistance(self.frame.origin, secondNode.frame.origin);
        if (distanceToFirstNode > distanceToSecondNode) {
            return NSOrderedDescending;
        } else if (distanceToFirstNode < distanceToSecondNode) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (PCTransformSnapEdge)edgesCurrentlyBeingTransformedByHandle:(PCTransformEdgeHandle)handle {
    PCTransformSnapEdge edgeBeingTransformed = PCTransformSnapEdgeNone;
    switch (handle) {
        case PCTransformEdgeHandleBottomLeft:
            edgeBeingTransformed |= PCTransformSnapEdgeLeft;
            edgeBeingTransformed |= PCTransformSnapEdgeBottom;
            break;
        case PCTransformEdgeHandleBottomRight:
            edgeBeingTransformed |= PCTransformSnapEdgeRight;
            edgeBeingTransformed |= PCTransformSnapEdgeBottom;
            break;
        case PCTransformEdgeHandleTopRight:
            edgeBeingTransformed |= PCTransformSnapEdgeRight;
            edgeBeingTransformed |= PCTransformSnapEdgeTop;
            break;
        case PCTransformEdgeHandleTopLeft:
            edgeBeingTransformed |= PCTransformSnapEdgeLeft;
            edgeBeingTransformed |= PCTransformSnapEdgeTop;
            break;
        case PCTransformEdgeHandleBottom:
            edgeBeingTransformed |= PCTransformSnapEdgeBottom;
            break;
        case PCTransformEdgeHandleRight:
            edgeBeingTransformed |= PCTransformSnapEdgeRight;
            break;
        case PCTransformEdgeHandleTop:
            edgeBeingTransformed |= PCTransformSnapEdgeTop;
            break;
        case PCTransformEdgeHandleLeft:
            edgeBeingTransformed |= PCTransformSnapEdgeLeft;
            break;
        default:
            break;
    }

    return edgeBeingTransformed;
}

- (PCSnapPoints)snapPointsWithNode:(PCSnapFrame *)node snapHandle:(PCTransformEdgeHandle)snapHandle snapSensitivity:(CGFloat)sensitivity {
    PCSnapPoints result = PCSnapPointNone;

    PCTransformSnapEdge snapEdges = [self edgesCurrentlyBeingTransformedByHandle:snapHandle];

    if (snapEdges & PCTransformSnapEdgeLeft || snapEdges == PCTransformSnapEdgeNone) {
        if (fabs(self.left - node.left) < sensitivity) {
            result |= PCSnapPointLeftToLeft;
        }
        if (fabs(self.left - node.centerX) < sensitivity) {
            result |= PCSnapPointLeftToMiddleX;
        }
        if (fabs(self.left - node.right) < sensitivity) {
            result |= PCSnapPointLeftToRight;
        }
    }

    if (snapEdges & PCTransformSnapEdgeRight || snapEdges == PCTransformSnapEdgeNone) {
        if (fabs(self.right - node.left) < sensitivity) {
            result |= PCSnapPointRightToLeft;
        }
        if (fabs(self.right - node.centerX) < sensitivity) {
            result |= PCSnapPointRightToMiddleX;
        }
        if (fabs(self.right - node.right) < sensitivity) {
            result |= PCSnapPointRightToRight;
        }
    }

    if (snapEdges & PCTransformSnapEdgeBottom || snapEdges == PCTransformSnapEdgeNone) {
        if (fabs(self.bottom - node.bottom) < sensitivity) {
            result |= PCSnapPointBottomToBottom;
        }
        if (fabs(self.bottom - node.centerY) < sensitivity) {
            result |= PCSnapPointBottomToMiddleY;
        }
        if (fabs(self.bottom - node.top) < sensitivity) {
            result |= PCSnapPointBottomToTop;
        }
    }

    if (snapEdges & PCTransformSnapEdgeTop || snapEdges == PCTransformSnapEdgeNone) {
        if (fabs(self.top - node.bottom) < sensitivity) {
            result |= PCSnapPointTopToBottom;
        }
        if (fabs(self.top - node.centerY) < sensitivity) {
            result |= PCSnapPointTopToMiddleY;
        }
        if (fabs(self.top - node.top) < sensitivity) {
            result |= PCSnapPointTopToTop;
        }
    }
    
    if (snapEdges == PCTransformSnapEdgeNone) {
        if (fabs(self.centerY - node.centerY) < sensitivity) {
            result |= PCSnapPointMiddleYToMiddleY;
        }
        if (fabs(self.centerX - node.centerX) < sensitivity) {
            result |= PCSnapPointMiddleXToMiddleX;
        }
        if (fabs(self.centerY - node.bottom) < sensitivity) {
            result |= PCSnapPointMiddleYToBottom;
        }
        
        if (fabs(self.centerY - node.top) < sensitivity) {
            result |= PCSnapPointMiddleYToTop;
        }
        if (fabs(self.centerX - node.left) < sensitivity) {
            result |= PCSnapPointMiddleXToLeft;
        }
        if (fabs(self.centerX - node.right) < sensitivity) {
            result |= PCSnapPointMiddleXToRight;
        }
    }

    return result;
}

/**
 @discussion Flips between stage-relative and node-relative CCBCornerId. This method flips from one
 representation to the other regardless of which one was passed in.

 A stage-relative cornerId works like this:

  Left           Left
   +---------+    +---------+
   |         |    |         |
  [|] Button |    | nottuB [|]
   |         |    |         |
   +---------+    +---------+

 A node-relative cornerId works like this:

  Left                    Left
   +---------+    +---------+
   |         |    |         |
  [|] Button |    | nottuB [|]
   |         |    |         |
   +---------+    +---------+

 This function translates the input cornerId from one representation to the other regardless of which representation was passed in.

 @param cornerId The corner id that should be flipped to the opposite representation
 @returns The corner id after flipping it to the alternate representation
 */
- (CCBCornerId)flipCornerId:(CCBCornerId)cornerId {
    if (self.node.transformStartScaleX < 0) {
        cornerId = CCBOppositeHorizontalCorner(cornerId);
    }
    if (self.node.transformStartScaleY < 0) {
        cornerId = CCBOppositeVerticalCorner(cornerId);
    }

    return cornerId;
}

/**
 Translate a stage-relative CCBCornerId into a node-relative PCTransformEdgeHandle.
 */
- (PCTransformEdgeHandle)transformEdgeHandleFromCornerId:(CCBCornerId)cornerId {
    return (PCTransformEdgeHandle) [self flipCornerId:cornerId];
}

/**
 Translate a node-relative PCTransformEdgeHandle into a stage-relative CCBCornerId.
 */
- (CCBCornerId)cornerIdFromTransformEdgeHandle:(PCTransformEdgeHandle)handle {
    return [self flipCornerId:(CCBCornerId) handle];
}

- (CGPoint)handleLocation:(PCTransformEdgeHandle)handle {
    switch (handle) {
        case PCTransformEdgeHandleBottomLeft:
            return CGPointMake(self.left, self.bottom);
        case PCTransformEdgeHandleBottomRight:
            return CGPointMake(self.right, self.bottom);
        case PCTransformEdgeHandleTopRight:
            return CGPointMake(self.right, self.top);
        case PCTransformEdgeHandleTopLeft:
            return CGPointMake(self.left, self.top);
        case PCTransformEdgeHandleBottom:
            return CGPointMake(self.centerX, self.bottom);
        case PCTransformEdgeHandleRight:
            return CGPointMake(self.right, self.centerY);
        case PCTransformEdgeHandleTop:
            return CGPointMake(self.centerX, self.top);
        case PCTransformEdgeHandleLeft:
            return CGPointMake(self.left, self.centerY);
        default:
            return CGPointZero;
    }
}

- (BOOL)snapEdgesToFrame:(PCSnapFrame *)frame withHandle:(PCTransformEdgeHandle)handle lockAspectRatio:(BOOL)lockAspectRatio {
    if (handle == PCTransformEdgeHandleNone) {
        return NO;
    }

    PCSnapPoints snapPoints = [self snapPointsWithNode:frame snapHandle:handle snapSensitivity:PCDefaultDragSnapSensitivity];
    if (snapPoints == PCSnapPointNone) {
        return NO;
    }

    CGPoint handleLocation = [self handleLocation:handle];

    if (snapPoints & PCSnapPointRightToLeft) {
        handleLocation.x = frame.left;
    } else if (snapPoints & PCSnapPointRightToRight) {
        handleLocation.x = frame.right;
    } else if (snapPoints & PCSnapPointRightToMiddleX) {
        handleLocation.x = frame.centerX;
    } else if (snapPoints & PCSnapPointLeftToRight) {
        handleLocation.x = frame.right;
    } else if (snapPoints & PCSnapPointLeftToLeft) {
        handleLocation.x = frame.left;
    } else if (snapPoints & PCSnapPointLeftToMiddleX) {
        handleLocation.x = frame.centerX;
    }

    if (snapPoints & PCSnapPointTopToBottom) {
        handleLocation.y = frame.bottom;
    } else if (snapPoints & PCSnapPointTopToTop) {
        handleLocation.y = frame.top;
    } else if (snapPoints & PCSnapPointTopToMiddleY) {
        handleLocation.y = frame.centerY;
    } else if (snapPoints & PCSnapPointBottomToTop) {
        handleLocation.y = frame.top;
    } else if (snapPoints & PCSnapPointBottomToBottom) {
        handleLocation.y = frame.bottom;
    } else if (snapPoints & PCSnapPointBottomToMiddleY) {
        handleLocation.y = frame.centerY;
    }

    SKNode *rootNode = [PCStageScene scene].rootNode;
    CGPoint handlePositionInWorld = [rootNode pc_convertToWorldSpace:handleLocation];
    CGPoint handlePositionInNodeParent = [self.node.parent pc_convertToNodeSpace:handlePositionInWorld];
    PCAxis lockedAxis = snapPoints & PCSnapPointToVerticalEdgeMask ? PCAxisHorizontal : PCAxisVertical;

    // Hack! Unflip the corner since `pc_?????FromMousePosition:cornerIndex:` assumes the cornerId
    // is still relative to the stage.
    CCBCornerId cornerId = [self cornerIdFromTransformEdgeHandle:handle];

    if (self.node.editorResizeBehaviour == PCEditorResizeBehaviourScale) {
        CGVector scale = [self.node pc_scaleFromMousePosition:handlePositionInNodeParent cornerIndex:(CCBCornerId) cornerId];
        if (lockAspectRatio) {
            scale = [SKNode pc_lockAspectRatioOfScale:scale toAxis:lockedAxis];
        }

        self.node.position = [self.node pc_positionWhenScaledToNewScale:scale cornerIndex:(CCBCornerId) cornerId];
        self.node.xScale = scale.dx;
        self.node.yScale = scale.dy;
    }
    else {
        CGSize newContentSize = [self.node pc_sizeFromMousePosition:handlePositionInNodeParent cornerIndex:(CCBCornerId) handle];
        if (lockAspectRatio) {
            newContentSize = [self.node pc_lockAspectRatioOfSize:newContentSize toAxis:lockedAxis];
        }
        self.node.position = [self.node pc_positionWhenContentSizeSetToSize:newContentSize cornerIndex:(CCBCornerId) handle];
        self.node.contentSize = NSMakeSize(fabs(newContentSize.width / self.node.xScale), fabs(newContentSize.height / self.node.yScale));
    }

    return YES;
}

- (BOOL)snapNodeToFrame:(PCSnapFrame *)frame withHandle:(PCTransformEdgeHandle)handle {
    if (handle != PCTransformEdgeHandleNone) {
        return NO;
    }

    // validate the shape frame being passed in and make sure it has a valid CGRect frame
    if (CGRectIsNull(frame.frame) || CGRectIsInfinite(frame.frame) || PC_CGRECT_IS_NAN(frame.frame)) {
        return NO;
    }

    PCSnapPoints snapPoints = ([self snapPointsWithNode:frame snapHandle:handle snapSensitivity:PCDefaultDragSnapSensitivity]);
    if (snapPoints == PCSnapPointNone) {
        return NO;
    }

    if (snapPoints & PCSnapPointMiddleXToMiddleX) {
        self.centerX = frame.centerX;
    } else if (snapPoints & PCSnapPointLeftToLeft) {
        self.left = frame.left;
    } else if (snapPoints & PCSnapPointLeftToMiddleX) {
        self.left = frame.centerX;
    } else if (snapPoints & PCSnapPointLeftToRight) {
        self.left = frame.right;
    } else if (snapPoints & PCSnapPointMiddleXToLeft) {
        self.centerX = frame.left;
    } else if (snapPoints & PCSnapPointMiddleXToRight) {
        self.centerX = frame.right;
    } else if (snapPoints & PCSnapPointRightToLeft) {
        self.right = frame.left;
    } else if (snapPoints & PCSnapPointRightToMiddleX) {
        self.right = frame.centerX;
    } else if (snapPoints & PCSnapPointRightToRight) {
        self.right = frame.right;
    }

    if (snapPoints & PCSnapPointMiddleYToMiddleY) {
        self.centerY = frame.centerY;
    } else if (snapPoints & PCSnapPointBottomToBottom) {
        self.bottom = frame.bottom;
    } else if (snapPoints & PCSnapPointBottomToMiddleY) {
        self.bottom = frame.centerY;
    } else if (snapPoints & PCSnapPointBottomToTop) {
        self.bottom = frame.top;
    } else if (snapPoints & PCSnapPointMiddleYToBottom) {
        self.centerY = frame.bottom;
    } else if (snapPoints & PCSnapPointMiddleYToTop) {
        self.centerY = frame.top;
    } else if (snapPoints & PCSnapPointTopToBottom) {
        self.top = frame.bottom;
    } else if (snapPoints & PCSnapPointTopToMiddleY) {
        self.top = frame.centerY;
    } else if (snapPoints & PCSnapPointTopToTop) {
        self.top = frame.top;
    }

    CGPoint rootPoint = CGPointMake(self.frame.origin.x + self.anchorInFrame.x, self.frame.origin.y + self.anchorInFrame.y);
    SKNode *rootNode = [PCStageScene scene].rootNode;
    CGPoint worldPoint = [rootNode pc_convertToWorldSpace:rootPoint];

    self.node.position = [self.node.parent pc_convertToNodeSpace:worldPoint];
    return YES;
}

@end
