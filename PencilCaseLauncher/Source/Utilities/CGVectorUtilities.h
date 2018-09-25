//
//  CGVectorUtilities.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-07-08.
//
//

#ifndef PCCGVECTORUTILITIES_H_
#define PCCGVECTORUTILITIES_H_

#import <CoreGraphics/CGGeometry.h>

CG_EXTERN const CGVector pc_CGVectorZero;

/**
 *  Converts radians to a normalized vector.
 *
 *  @param angle Angle in radians
 *
 *  @return Normalized vector
 */
CG_INLINE CGVector pc_CGVectorMakeNormalizedWithAngle(const CGFloat angle) {
    return CGVectorMake(cos(angle), sin(angle));
}

/**
 *  Creates a vector from one point to another
 *
 *  @param point1
 *  @param point2
 *
 *  @return The vector between the points
 */
CG_INLINE CGVector pc_CGVectorMakeWithPoints(const CGPoint point1, const CGPoint point2) {
    return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
}

/**
 *  Converts a normalized vector to an angle in radians
 *
 *  @param vector Normalized vector
 *
 *  @return Angle in radians
 */
CG_INLINE CGFloat pc_CGVectorToAngle(const CGVector vector) {
    return atan2(vector.dy, vector.dx);
}

CG_INLINE CGVector pc_CGVectorSubtract(const CGVector a, const CGVector b) {
    return CGVectorMake(a.dx - b.dx, a.dy - b.dy);
}

CG_INLINE CGVector __pc_CGVectorApplyAffineTransform(CGVector vector, CGAffineTransform t) {
    CGVector v;
    v.dx = (CGFloat)((double)t.a * vector.dx + (double)t.c * vector.dy + t.tx);
    v.dy = (CGFloat)((double)t.b * vector.dx + (double)t.d * vector.dy + t.ty);
    return v;
}
#define pc_CGVectorApplyAffineTransform __pc_CGVectorApplyAffineTransform

/**
 *  Calculates the determinant of two vectors in a 2x2 matrix
 *
 *  @param vector1
 *  @param vector2
 *
 *  @return The determinant of the matrix
 */
CG_INLINE CGFloat pc_CGVectorDeterminant(const CGVector vector1, const CGVector vector2) {
    return vector1.dx * vector2.dy - vector1.dy * vector2.dx;
}

/**
 *  Creates a new vector by multiplying the components of two other vectors
 *
 *  @param vector1
 *  @param vector2
 *
 *  @return The multiplied vector
 */
CG_INLINE CGVector pc_CGVectorMultiply(const CGVector vector1, const CGVector vector2) {
    return CGVectorMake(vector1.dx * vector2.dx, vector1.dy * vector2.dy);
}

/**
 *  Creates a new vector by dividing the components of two other vectors
 *
 *  @param vector1
 *  @param vector2
 *
 *  @return The divided vector
 */
CG_INLINE CGVector pc_CGVectorDivide(const CGVector vector1, const CGVector vector2) {
    return CGVectorMake(vector1.dx / vector2.dx, vector1.dy / vector2.dy);
}

#endif
