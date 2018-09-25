//
//  SKNode+Selection.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-08-08.
//
//

#import "SKNode+Selection.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+CoordinateConversion.h"
#import "CGPointUtilities.h"
#import "PCMathUtilities.h"

@implementation SKNode (Selection)

#pragma mark - Public

- (BOOL)userSelectable {
    return self.locked == NO && self.hidden == NO && self.parentHidden == NO && self.hideFromUI == NO && self.selectable == YES;
}

- (void)pc_calculateSelectionCornerPointsWithPoints:(CGPoint *)points inNodeSpace:(SKNode *)targetNodeSpace {
    //Check if we should use default implementation. SpriteKit transforms points correctly if they are not the child of a scaled or rotated node, and incorrectly
    //if they are. This method always calculates points correctly, but that gets strange when sprite kit is calculating them incorrectly. So defer to spritekit
    //implementation, in the case where it would appear wrong
    if ([self hasNonUniformScaleParent]) {
        [self pc_calculateCornerPointsWithPoints:points];
        for (NSUInteger pointIndex = 0; pointIndex < PCTransformEdgeHandleCount; pointIndex++) {
            points[pointIndex] = [self.parent convertPoint:points[pointIndex] toNode:targetNodeSpace];
        }
        return;
    }

    [self calculateLocalCornerPointsFromAnchorPoint:points];

    //Scale
    SKTexture *handleTexture = [SKNode pc_handleTexture];
    CGSize absoluteSize = CGSizeMake(fabs(self.size.width), fabs(self.size.height));
    CGSize sizeInTarget = [self.parent pc_convertSize:absoluteSize toNode:targetNodeSpace];
    CGSize clampedSize = CGSizeMake(MAX(fabs(sizeInTarget.width), handleTexture.size.width) * pc_sign(sizeInTarget.width),
                                    MAX(fabs(sizeInTarget.height), handleTexture.size.height) * pc_sign(sizeInTarget.height));
    for (NSUInteger pointIndex = 0; pointIndex < PCTransformEdgeHandleCount; pointIndex++) {
        points[pointIndex] = CGPointMake(points[pointIndex].x * clampedSize.width,
                                         points[pointIndex].y * clampedSize.height);
    }

    //Rotation
    CGFloat worldRotation = [self.parent pc_convertRotationInDegreesToWorldSpace:self.rotation];
    CGFloat targetRotation = [targetNodeSpace pc_convertRotationInDegreesToNodeSpace:worldRotation];
    pc_applyRotationToPoints(DEGREES_TO_RADIANS(targetRotation), points, PCTransformEdgeHandleCount);

    //Position
    CGPoint origin = [self.parent convertPoint:self.position toNode:targetNodeSpace];
    for (NSUInteger pointIndex = 0; pointIndex < PCTransformEdgeHandleCount; pointIndex++) {
        points[pointIndex] = pc_CGPointAdd(points[pointIndex], origin);
    }
}

- (void)pc_calculateCornerPointsWithPoints:(CGPoint *)points {
    CGPoint workingAnchorPoint = self.anchorPoint;
    CGSize workingSize = self.contentSize;
    CGFloat top = workingSize.height * (1 - workingAnchorPoint.y);
    CGFloat bottom = -workingSize.height * workingAnchorPoint.y;
    CGFloat left = -workingSize.width * workingAnchorPoint.x;
    CGFloat right = workingSize.width * (1 - workingAnchorPoint.x);

    if (self.yScale < 0) {
        PC_SWAP(top, bottom);
    }
    if (self.xScale < 0) {
        PC_SWAP(left, right);
    }

    points[PCTransformEdgeHandleBottomLeft] = [self convertPoint:CGPointMake(left, bottom) toNode:self.parent];
    points[PCTransformEdgeHandleBottomRight] = [self convertPoint:CGPointMake(right, bottom) toNode:self.parent];
    points[PCTransformEdgeHandleTopRight] = [self convertPoint:CGPointMake(right, top) toNode:self.parent];
    points[PCTransformEdgeHandleTopLeft] = [self convertPoint:CGPointMake(left, top) toNode:self.parent];

    points[PCTransformEdgeHandleTop] = [self convertPoint:CGPointMake((left + right) * 0.5, top) toNode:self.parent];
    points[PCTransformEdgeHandleBottom] = [self convertPoint:CGPointMake((left + right) * 0.5, bottom) toNode:self.parent];
    points[PCTransformEdgeHandleLeft] = [self convertPoint:CGPointMake(left, (top + bottom) * 0.5) toNode:self.parent];
    points[PCTransformEdgeHandleRight] = [self convertPoint:CGPointMake(right, (top + bottom) * 0.5) toNode:self.parent];
}

+ (SKTexture *)pc_handleTexture {
    static SKTexture *handleTexture;
    static dispatch_once_t dispatchToken;
    dispatch_once(&dispatchToken, ^{
        handleTexture = [SKTexture textureWithImage:[NSImage imageNamed:@"select-corner"]];
    });
    return handleTexture;
}

#pragma mark - Private

- (BOOL)hasNonUniformScaleParent {
    for (SKNode *parent = self.parent; parent; parent = parent.parent) {
        if (fabs(parent.xScale) != fabs(parent.yScale)) return YES;
    }
    return NO;
}

- (void)calculateLocalCornerPointsFromAnchorPoint:(CGPoint *)points {
    CGPoint workingAnchorPoint = CGPointMake(self.xScale >= 0 ? self.anchorPoint.x : 1 - self.anchorPoint.x,
                                             self.yScale >= 0 ? self.anchorPoint.y : 1 - self.anchorPoint.y);

    CGFloat left = -workingAnchorPoint.x;
    CGFloat right = 1 - workingAnchorPoint.x;
    CGFloat bottom = -workingAnchorPoint.y;
    CGFloat top = 1 - workingAnchorPoint.y;

    points[PCTransformEdgeHandleBottomLeft] = CGPointMake(left, bottom);
    points[PCTransformEdgeHandleBottomRight] = CGPointMake(right, bottom);
    points[PCTransformEdgeHandleTopRight] = CGPointMake(right, top);
    points[PCTransformEdgeHandleTopLeft] = CGPointMake(left, top);
    points[PCTransformEdgeHandleBottom] = CGPointMake((left + right) / 2.0f, bottom);
    points[PCTransformEdgeHandleRight] = CGPointMake(right, (bottom + top) / 2.0f);
    points[PCTransformEdgeHandleTop] = CGPointMake((left + right) / 2.0f, top);
    points[PCTransformEdgeHandleLeft] = CGPointMake(left, (bottom + top) / 2.0f);
}

@end
