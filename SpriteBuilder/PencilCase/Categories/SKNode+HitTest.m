//
//  asdf.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-04.
//
//

#import "SKNode+HitTest.h"
#import "SKNode+CocosCompatibility.h"
#import "PCMathUtilities.h"

@implementation SKNode (HitTest)

- (BOOL)pc_hitTestWithWorldRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    if (isnan(self.position.x) || isnan(self.position.y)) return NO;

    // We will work in this node's parent space for hit testing
    CGPoint start = [self.parent convertPoint:startPoint fromNode:self.scene];
    CGPoint end = [self.parent convertPoint:endPoint fromNode:self.scene];

    CGFloat width = end.x - start.x;
    CGFloat height = end.y - start.y;
    
    CGRect rectBounds = CGRectMake(start.x, start.y, width, height);
    NSBezierPath *rectPath = [NSBezierPath bezierPathWithRect:rectBounds];
    
    CGRect selfRect = CGRectMake(self.position.x, self.position.y, fabs(self.size.width) * pc_sign(self.xScale), fabs(self.size.height) * pc_sign(self.yScale));

    NSBezierPath *rotatedSelfPath = [self pc_bezierPathFromRect:selfRect withAnchorPoint:self.anchorPoint andRotationInDegrees:RADIANS_TO_DEGREES(self.zRotation)];

    return doRectPathsIntersect(rectPath, rotatedSelfPath);
}

- (BOOL)pc_hitTestWithWorldPoint:(CGPoint)point {
    return [self pc_hitTestWithWorldRect:point endPoint:point];
}

#pragma mark Helpers

/**
 *  Iterates through the corners of each path to see if at least one path contains at least one corner from the other.
 *  If so, there's an intersection.
 *  This expects straight-lined closed paths (convex or concave), so if a curve (but not its start or end point) is involved in an intersection it won't be detected by this function.
 *  Self-intersecting paths will treat a point "outside", but inside a space created by self-intersection, as contained. In other words its not supported as a special case.
 *  This should work for our current cases where we have rotated rectangular frames for objects.
 *  An improvement that could be made would be to support hit tests with curved paths (pen tool), or at least for circles (circle shapes).
 *
 *
 *  @param a First path
 *  @param b Second path
 *
 *  @return Whether the paths intersect
 */
BOOL doRectPathsIntersect(NSBezierPath *a, NSBezierPath *b) {
    if (bezierPathContainsCrashingControlPoint(a)) return NO;
    if (bezierPathContainsCrashingControlPoint(b)) return NO;

    NSArray *cornersA = pc_pointsOfPath(a);
    NSArray *cornersB = pc_pointsOfPath(b);
    NSPoint point, pointA1, pointA2, pointB1, pointB2;

    // Check point containment
    for (NSValue *cornerValue in cornersB) {
        point = [cornerValue pointValue];
        if ([a containsPoint:point]) return YES;
    }
    for (NSValue *cornerValue in cornersA) {
        point = [cornerValue pointValue];
        if ([b containsPoint:point]) return YES;
    }
    
    // Check line segment intersection
    // Iterate through all line segments with consecutive points to test intersection and return on first intersect
    for (NSInteger aCornerIndex = 0; aCornerIndex < [cornersA count]; aCornerIndex += 1) {
        for (NSInteger bCornerIndex = 0; bCornerIndex < [cornersB count]; bCornerIndex += 1) {
            pointA1 = [cornersA[aCornerIndex] pointValue];
            pointA2 = [cornersA[(aCornerIndex + 1) % [cornersA count]] pointValue];
            pointB1 = [cornersB[bCornerIndex] pointValue];
            pointB2 = [cornersB[(bCornerIndex + 1) % [cornersB count]] pointValue];
            if (doLineSegmentsIntersect(pointA1, pointA2, pointB1, pointB2)) return YES;
        }
    }
    
    return NO;
}

BOOL bezierPathContainsCrashingControlPoint(NSBezierPath *path) {
    CGRect rect = [path controlPointBounds];
    if (isinf(rect.origin.x) || isinf(rect.origin.y) || isinf(rect.size.width) || isinf(rect.size.height)) return YES;
    if (isnan(rect.origin.x) || isnan(rect.origin.y) || isnan(rect.size.width) || isnan(rect.size.height)) return YES;
    return NO;
}

/**
 *  Determines if three points are listed in CCW order
 *
 *  This function only determines CW vs CCW order, and treats colinearity as CW (returns NO)
 *  It is a simplification of finding the signed area of the triangle formed by the three points by calculating the determinant of:
 *
 *  | Ax Ay 1 |
 *  | Bx By 1 |
 *  | Cx Cy 1 |
 *
 *  This function is adapted from http://algs4.cs.princeton.edu/91primitives/
 *
 *  @param p1
 *  @param p2
 *  @param p3
 *
 *  @return Whether the points are in CCW order
 */
static inline BOOL CCW(CGPoint p1, CGPoint p2, CGPoint p3) {
    return (p2.x - p1.x) * (p3.y - p1.y) > (p3.x - p1.x) * (p2.y - p1.y);
}

/**
 *  Determines if two 2D line segments intersect
 *
 *  By checking if different sets of three points are ordered CCW or CW we are able to determine intersection.
 *  We are basically checking which sides of a line segment A the points of another segment B are on.
 *  If each point of line segment B is on a different side of line segment A we know they must intersect.
 *
 *  By example:
 *
 *  1 ----A----- 2
 *
 *        3
 *        |
 *        B
 *        |
 *        4
 *
 *  We can see that each of the orientation of each of the line segments tested in this function will find that the line segments don't intersect.
 *
 *  Conversely:
 *
 *            3
 *  1 ----A--/-- 2
 *          /
 *         B
 *        /
 *       4
 *
 *  If three or more endpoints are colinear, this function will determine that they don't intersect:
 *
 *  1-----A--3--2-B----4
 *
 *  For our uses here this isn't important because we're testing rectangular frames where if one segment is colinear with the segment from another
 *  frame then the point containment check will return true. For example in this case:
 *
 *  ⌈‾‾‾⌈⌉‾‾‾⌉
 *  | A || B |
 *  ⌊___⌊⌋___⌋
 *
 *  -[bezierPathOfA containsPoint:aCornerOfB], which uses the non-zero winding rule, will determine that the point is inside the path when the point is on the path.
 *
 *  This function is adapted from http://algs4.cs.princeton.edu/91primitives/
 *
 *  @param p1 First line segment start point
 *  @param p2 First line segment end point
 *  @param p3 Second line segment start point
 *  @param p4 Second line segment end point
 *
 *  @return Whether the line segments intersect
 */
static inline BOOL doLineSegmentsIntersect(const CGPoint p1, const CGPoint p2, const CGPoint p3, const CGPoint p4) {
    return (CCW(p1, p3, p4) != CCW(p2, p3, p4)) && (CCW(p1, p2, p3) != CCW(p1, p2, p4));
}

/**
 *  Finds the points of a path while treating any curves as if they were straight lines to a point
 *
 *  @param path The path to find the points of
 *
 *  @return An array of point values taken from the path elements
 */
NSArray *pc_pointsOfPath(NSBezierPath *path) {
    NSMutableArray *corners = [NSMutableArray array];
    NSBezierPathElement element;
    NSPoint points[3];
    BOOL closed = NO;
    for (NSInteger elementIndex = 0; elementIndex < [path elementCount]; elementIndex += 1) {
        element = [path elementAtIndex:elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement:
                [corners addObject:[NSValue valueWithPoint:points[0]]];
                break;
            case NSLineToBezierPathElement:
                [corners addObject:[NSValue valueWithPoint:points[0]]];
                break;
            case NSCurveToBezierPathElement:
                [corners addObject:[NSValue valueWithPoint:points[0]]];
                break;
            case NSClosePathBezierPathElement:
                closed = YES;
                break;
            default:
                break;
        }
        if (closed) break;
    }
    return corners;
}

/**
 *  Find the smallest rectangle that encompases a list of points
 *
 *  @param corners to search through
 *
 *  @return smallest CGRect that encompases a all the supplied points
 */
- (CGRect)pc_smallestRectFromPath:(NSBezierPath *)path {
    if (path == nil) return CGRectZero;
    NSArray *corners = pc_pointsOfPath(path);
    CGPoint firstCorner = [corners[0] pointValue];
    CGFloat minX, maxX;
    CGFloat minY, maxY;
    minX = maxX = firstCorner.x;
    minY = maxY = firstCorner.y;
    for (NSValue *point in corners) {
        CGPoint corner = [point pointValue];
        minX = MIN(minX, corner.x);
        maxX = MAX(maxX, corner.x);
        minY = MIN(minY, corner.y);
        maxY = MAX(maxY, corner.y);
    }
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

/**
 *  Get a bezier path representing a rotated CGRect
 *
 *  @param rect that you want to find a path from
 *
 *  @param anchor point of the rect you suppied
 *
 *  @param the rotation in degrees of the rect you supplied
 *
 *  @return A bezier path representing the rotated rect.
 */
- (NSBezierPath *)pc_bezierPathFromRect:(NSRect)rect withAnchorPoint:(CGPoint)anchorPoint andRotationInDegrees:(CGFloat)rotation {
    CGFloat nodeX = rect.origin.x - (anchorPoint.x * rect.size.width);
    CGFloat nodeY = rect.origin.y - (anchorPoint.y * rect.size.height);
    CGRect frame = CGRectMake(nodeX, nodeY, rect.size.width, rect.size.height);
    
    NSBezierPath *rotatedSelfPath = [NSBezierPath bezierPathWithRect:frame];
    NSAffineTransform *offsetTransform1 = [NSAffineTransform transform];
    [offsetTransform1 translateXBy:-rect.origin.x yBy:-rect.origin.y];
    [rotatedSelfPath transformUsingAffineTransform:offsetTransform1];
    NSAffineTransform *rotationTransform = [NSAffineTransform transform];
    [rotationTransform rotateByDegrees:rotation];
    [rotatedSelfPath transformUsingAffineTransform:rotationTransform];
    NSAffineTransform *offsetTransform2 = [NSAffineTransform transform];
    [offsetTransform2 translateXBy:rect.origin.x yBy:rect.origin.y];
    [rotatedSelfPath transformUsingAffineTransform:offsetTransform2];
    return rotatedSelfPath;
}

@end
