//
//  PCMathUtilities.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-09-02.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#ifndef __PCPlayer__PCMathUtilities__
#define __PCPlayer__PCMathUtilities__

#include <stdio.h>
#import <CoreGraphics/CGGeometry.h>
#import <math.h>

#define PC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (CGFloat)M_PI * 180.0f)
#define PC_DEGREES_TO_RADIANS(__ANGLE__) ((CGFloat)M_PI * (__ANGLE__) / 180.0f)

#define PC_SWAP(a, b) ({ __typeof__(a) t = (a); a = b; b = t; })

CGFloat pc_clampf(CGFloat value, CGFloat min, CGFloat max);


// From chipmunk
int pc_ConvexHull(int count, CGPoint *verts, CGPoint *result, int *first, CGFloat tol);

static inline CGFloat pc_sign(CGFloat f) {
    return (f >= 0 ? 1 : -1);
}

static inline CGPoint pc_rotatePointByRotation(CGPoint pointToRotate, CGFloat rotation) {
    return CGPointMake(pointToRotate.x * cos(rotation) - pointToRotate.y * sin(rotation),
                       pointToRotate.x * sin(rotation) + pointToRotate.y * cos(rotation));
}

void pc_applyRotationToPoints(CGFloat rotation, CGPoint *points, uint count);

#define PC_CGRECT_IS_NAN(rect) (isnan(rect.origin.x)||isnan(rect.origin.y)||isnan(rect.size.width)||isnan(rect.size.height))

#endif /* defined(__PCPlayer__PCMathUtilities__) */
