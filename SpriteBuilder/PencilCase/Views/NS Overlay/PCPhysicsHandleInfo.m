//
//  PCPhysicsHandleInfo.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-12-18.
//
//

#import "PCPhysicsHandleInfo.h"

@implementation PCPhysicsHandleInfo

- (id)initWithPoints:(NSMutableArray *)points andShapeType:(PCPhysicsBodyShape)shape {
    self = [super init];
    if (self) {
        self.physicsBodyPoints = points;
        self.shapeType = shape;
    }
    return self;
}

- (NSBezierPath *)bezierPathForHandleInfo {
    if (self.physicsBodyPoints.count == 0) return nil;
    NSBezierPath *path = [[NSBezierPath alloc] init];
    switch (self.shapeType) {
        case PCPhysicsBodyShapePolygon: {
            CGPoint firstPoint = [self.physicsBodyPoints[0] pointValue];
            [path moveToPoint: CGPointMake(firstPoint.x, firstPoint.y)];
            for (int i = 1; i < self.physicsBodyPoints.count; i++) {
                CGPoint point = [self.physicsBodyPoints[i] pointValue];
                [path lineToPoint:CGPointMake(point.x, point.y)];
            }
            [path closePath];
            [NSColor.blackColor setStroke];
            [path setLineWidth: 1];
            return path;
        }
        case PCPhysicsBodyShapeCircle: {
            if (self.physicsBodyPoints.count < 2) return nil;
            CGPoint center = [self.physicsBodyPoints[0] pointValue];
            CGPoint radiusPoint = [self.physicsBodyPoints[1] pointValue];
            CGFloat radius = radiusPoint.x - center.x;
            CGPoint bottomLeft = CGPointMake(center.x - radius, center.y - radius);
            CGFloat size = fabs(2 * radius);
            path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(bottomLeft.x, bottomLeft.y, size, size)];
            return path;
        }
        case PCPhysicsBodyShapeTexture:
            return nil;
        default:
            return nil;
    }
}

@end
