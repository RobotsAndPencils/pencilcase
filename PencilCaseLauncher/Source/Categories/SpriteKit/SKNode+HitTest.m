//
//  asdf.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-04.
//
//

#import "SKNode+HitTest.h"

#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CoordinateConversion.h"

@implementation SKNode (HitTest)

- (BOOL)hitTestWithWorldRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    if (isnan(self.position.x) || isnan(self.position.y)) {
        return NO;
    }
    if (!self.pc_scene) return NO;

    // We will work in this node's parent space for hit testing
    CGPoint start = [self.parent convertPoint:startPoint fromNode:self.pc_scene];
    CGPoint end = [self.parent convertPoint:endPoint fromNode:self.pc_scene];
    
    CGFloat width = end.x - start.x;
    CGFloat height = end.y - start.y;
    
    CGRect rectBounds = CGRectMake(start.x, start.y, width, height);
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:rectBounds];
    
    CGFloat nodeX = self.position.x - self.anchorPoint.x * self.size.width;
    CGFloat nodeY = self.position.y - self.anchorPoint.y * self.size.height;
    CGRect frame = CGRectMake(nodeX, nodeY, self.size.width, self.size.height);

    // rotateByRadians: will rotate about the origin, but we need to rotate about the node's anchor point
    UIBezierPath *rotatedSelfPath = [UIBezierPath bezierPathWithRect:frame];
    [rotatedSelfPath applyTransform:CGAffineTransformMakeTranslation(-self.position.x, -self.position.y)];
    [rotatedSelfPath applyTransform:CGAffineTransformMakeRotation(self.zRotation)];
    [rotatedSelfPath applyTransform:CGAffineTransformMakeTranslation(self.position.x, self.position.y)];

    BOOL intersect = doRectPathsIntersect(rectPath, rotatedSelfPath);
    return intersect;
}

- (BOOL)hitTestWithWorldPoint:(CGPoint)point {
    return [self hitTestWithWorldRect:point endPoint:point];
}

- (BOOL)pc_hitTestWithNode:(SKNode *)node {
    UIBezierPath *myPath = [self pc_bezierPathInWorldSpace];
    UIBezierPath *theirPath = [node pc_bezierPathInWorldSpace];
    return doRectPathsIntersect(myPath, theirPath);
}

#pragma mark - Private

- (UIBezierPath *)pc_bezierPathInWorldSpace {
    if (!self.pc_scene) return nil;

    CGPoint anchorPointInParentSpace = CGPointMake(self.xScale < 0 ? 1 - self.anchorPoint.x : self.anchorPoint.x,
                                                   self.yScale < 0 ? 1 - self.anchorPoint.y : self.anchorPoint.y);
    CGPoint bottomLeftInParentSpace = CGPointMake(self.position.x - anchorPointInParentSpace.x * self.size.width,
                                                  self.position.y - anchorPointInParentSpace.y * self.size.height);

    CGPoint bottomLeftInWorldSpace = [self.parent convertPoint:bottomLeftInParentSpace toNode:self.pc_scene];
    CGSize sizeInWorldSpace = [self.parent pc_convertSize:self.size toNode:self.pc_scene];
    CGPoint positionInWorldSpace = [self.parent convertPoint:self.position toNode:self.pc_scene];

    CGRect frame = { bottomLeftInWorldSpace, sizeInWorldSpace };
    // rotateByRadians: will rotate about the origin, but we need to rotate about the node's anchor point
    UIBezierPath *rotatedPath = [UIBezierPath bezierPathWithRect:frame];
    [rotatedPath applyTransform:CGAffineTransformMakeTranslation(-positionInWorldSpace.x, -positionInWorldSpace.y)];
    [rotatedPath applyTransform:CGAffineTransformMakeRotation(self.zRotation)];
    [rotatedPath applyTransform:CGAffineTransformMakeTranslation(positionInWorldSpace.x, positionInWorldSpace.y)];
    return rotatedPath;
}

#pragma mark - Helpers

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
BOOL doRectPathsIntersect(UIBezierPath *a, UIBezierPath *b) {
    if (!a || !b) return NO;

    NSArray *cornersA = pointsOfPath(a);
    NSArray *cornersB = pointsOfPath(b);
    CGPoint point, pointA1, pointA2, pointB1, pointB2;

    // Check point containment
    for (NSValue *cornerValue in cornersB) {
        point = [cornerValue CGPointValue];
        if ([a containsPoint:point]) return YES;
    }
    for (NSValue *cornerValue in cornersA) {
        point = [cornerValue CGPointValue];
        if ([b containsPoint:point]) return YES;
    }
    
    // Check line segment intersection
    // Iterate through all line segments with consecutive points to test intersection and return on first intersect
    for (NSInteger aCornerIndex = 0; aCornerIndex < [cornersA count]; aCornerIndex += 1) {
        pointA1 = [cornersA[aCornerIndex] CGPointValue];
        pointA2 = [cornersA[(aCornerIndex + 1) % [cornersA count]] CGPointValue];
        for (NSInteger bCornerIndex = 0; bCornerIndex < [cornersB count]; bCornerIndex += 1) {
            pointB1 = [cornersB[bCornerIndex] CGPointValue];
            pointB2 = [cornersB[(bCornerIndex + 1) % [cornersB count]] CGPointValue];
            if (doLineSegmentsIntersect(pointA1, pointA2, pointB1, pointB2)) return YES;
        }
    }
    
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
NSArray *pointsOfPath(UIBezierPath *path) {
    CGPathRef CGPath = path.CGPath;
    NSMutableArray *bezierPoints = [NSMutableArray array];
    CGPathApply(CGPath, (__bridge void *)(bezierPoints), CGPathApplierGetCorners);
    return [bezierPoints copy];
}

void CGPathApplierGetCorners(void *info, const CGPathElement *element) {
    NSMutableArray *corners = (__bridge NSMutableArray *)info;

    CGPoint *points = element->points;
    CGPathElementType type = element->type;

    switch (type) {
        case kCGPathElementMoveToPoint:
            [corners addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
        case kCGPathElementAddLineToPoint:
            [corners addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
        case kCGPathElementAddCurveToPoint:
        case kCGPathElementAddQuadCurveToPoint:
            [corners addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
        case kCGPathElementCloseSubpath:
            break;
        default:
            break;
    }
}

@end
