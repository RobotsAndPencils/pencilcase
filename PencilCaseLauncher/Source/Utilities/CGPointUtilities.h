//
//  CGPointUtilities.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-19.
//
//

#ifndef PCCGPOINTUTILITIES_H_
#define PCCGPOINTUTILITIES_H_

#import <CoreGraphics/CGGeometry.h>

/** Returns opposite of point.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointNegative(const CGPoint point) {
    return CGPointMake(-point.x, -point.y);
}

/** Returns the sum of two points
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointAdd(const CGPoint point1, const CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

/** Returns the difference of two points.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointSubtract(const CGPoint point1, const CGPoint point2) {
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

/** Returns point multiplied by given factor.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointMultiply(const CGPoint point, const CGFloat factor) {
    return CGPointMake(point.x * factor, point.y * factor);
}

/** Returns point multiplied by another point.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointMultiplyByPoint(const CGPoint pointA, const CGPoint pointB) {
    return CGPointMake(pointA.x * pointB.x, pointA.y * pointB.y);
}

/** Calculates the midpoint between two points.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointMidpoint(const CGPoint point1, const CGPoint point2) {
    return pc_CGPointMultiply(pc_CGPointAdd(point1, point2), 0.5);
}

/** Calculates the dot product of two points.
 @return CGPoint
 */
CG_INLINE CGFloat pc_CGPointDot(const CGPoint point1, const CGPoint point2) {
    return point1.x * point2.x + point1.y * point2.y;
}

/** Calculates the cross product of two points.
 @return CGPoint
 */
CG_INLINE CGFloat pc_CGPointCross(const CGPoint point1, const CGPoint point2) {
    return point1.x * point2.y - point1.y * point2.x;
}

/** Calculates perpendicular of point, rotated 90 degrees counter-clockwise -- cross(point, perp(point)) >= 0
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointPerpendicular(const CGPoint point) {
    return CGPointMake(-point.y, point.x);
}

/** Calculates perpendicular of point, rotated 90 degrees clockwise -- cross(point, rperp(point)) <= 0
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointRightPerpendicular(const CGPoint point) {
    return CGPointMake(point.y, -point.x);
}

/** Calculates the projection of point1 over point2.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointProject(const CGPoint point1, const CGPoint point2) {
    return pc_CGPointMultiply(point2, pc_CGPointDot(point1, point2) / pc_CGPointDot(point2, point2));
}

/** Rotates two points.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointRotate(const CGPoint point1, const CGPoint point2) {
    return CGPointMake(point1.x * point2.x - point1.y * point2.y, point1.x * point2.y + point1.y * point2.x);
}

/** Unrotates two points.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointUnrotate(const CGPoint point1, const CGPoint point2) {
    return CGPointMake(point1.x * point2.x + point1.y * point2.y, point1.y * point2.x - point1.x * point2.y);
}

/** Calculates the square length of a CGPoint (not calling sqrt() )
 @return CGFloat
 */
CG_INLINE CGFloat pc_CGPointLengthSquare(const CGPoint point) {
    return pc_CGPointDot(point, point);
}

/** Calculates the square distance between two points (not calling sqrt() )
 @return CGFloat
 */
CG_INLINE CGFloat pc_CGPointDistanceSquare(const CGPoint point1, const CGPoint point2) {
    return pc_CGPointLengthSquare(pc_CGPointSubtract(point1, point2));
}

/** Returns the integral version of a point.
 @return CGPoint
 */
CG_INLINE CGPoint pc_CGPointRound(const CGPoint point) {
    CGPoint rounded;
    rounded.x = round(point.x);
    rounded.y = round(point.y);
    return rounded;
}

CG_INLINE CGPoint pc_CGPointIntegral(const CGPoint point) {
    return CGPointMake(round(point.x), round(point.y));
}

#endif