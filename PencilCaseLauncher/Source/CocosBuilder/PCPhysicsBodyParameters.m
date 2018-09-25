//
//  PCPhysicsBodyParameters.m
//  
//
//  Created by Stephen Gazzard on 2015-02-04.
//
//

#import "PCPhysicsBodyParameters.h"
#import "SKNode+PhysicsBody.h"
#import "SKNode+CocosCompatibility.h"

@implementation PCPhysicsBodyParameters

- (SKPhysicsBody *)createPhysicsBodyForNode:(SKNode *)node {
    SKPhysicsBody *body = [self initialisePhysicsBodyFromBodyShapeForNode:node];
    if (!body) return nil;

    body.contactTestBitMask = 0xFFFFFFFF;
    body.dynamic = self.dynamic;

    if (body.dynamic) {
        body.affectedByGravity = self.affectedByGravity;
        body.allowsRotation = self.allowsRotation;
    }

    body.density = self.density;
    body.friction = self.friction;
    body.restitution = self.elasticity;

    return body;
}

+ (instancetype)defaultPhysicsParamsForNode:(SKNode *)node {
    PCPhysicsBodyParameters *physicsBodyParameters = [[self alloc] init];
    SKTexture *texture = [node pc_textureForPhysicsBody];
    if (texture) {
        physicsBodyParameters.bodyShape = 2; // texture
    }
    else {
        physicsBodyParameters.bodyShape = -1;
    }

    physicsBodyParameters.dynamic = YES;
    physicsBodyParameters.affectedByGravity = YES;
    physicsBodyParameters.allowsRotation = YES;
    physicsBodyParameters.allowsUserDragging = YES;

    physicsBodyParameters.density = 1;
    physicsBodyParameters.friction = 0.3;
    physicsBodyParameters.elasticity = 0.3;

    physicsBodyParameters.originalAnchorPoint = node.anchorPoint;

    return physicsBodyParameters;
}

#pragma mark - Private Helpers

- (SKPhysicsBody *)initialisePhysicsBodyFromBodyShapeForNode:(SKNode *)node {
    switch (self.bodyShape) {
        case 0: {
            NSMutableArray *adjustedPoints = [NSMutableArray array];
            CGPoint anchorPointOffset = pc_CGPointSubtract(self.originalAnchorPoint, node.anchorPoint);
            CGPoint positionOffset = CGPointMake(anchorPointOffset.x * node.size.width, anchorPointOffset.y * node.size.height);
            for (NSValue *pointValue in self.points) {
                CGPoint originalPoint = [pointValue CGPointValue];
                CGPoint scaledPoint = CGPointMake(originalPoint.x * node.xScale, originalPoint.y * node.yScale);
                CGPoint translatedPoint = pc_CGPointAdd(scaledPoint, positionOffset);
                [adjustedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
            }
            CGPathRef path = [PCPhysicsBodyParameters newPathFromPoints:adjustedPoints];
            SKPhysicsBody *body = [SKPhysicsBody bodyWithPolygonFromPath:path];
            CGPathRelease(path);
            return body;
        }
        case 1:
            if (self.points.count == 0) break;
            return [SKPhysicsBody bodyWithCircleOfRadius:self.cornerRadius center:[self.points[0] CGPointValue]];
        case 2:
            return [SKPhysicsBody bodyWithTexture:[node pc_textureForPhysicsBody] size:node.size];
        case -1:
            return [SKPhysicsBody bodyWithRectangleOfSize:node.contentSize];
    }
    return nil;
}


+ (CGPathRef)newPathFromPoints:(NSArray *)points {
    if (points.count < 1) return NULL;

    CGFloat minX = CGFLOAT_MAX;
    CGFloat maxX = CGFLOAT_MIN;
    CGFloat minY = CGFLOAT_MAX;
    CGFloat maxY = CGFLOAT_MIN;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint point = [points[0] CGPointValue];
    CGPathMoveToPoint(path, nil, point.x, point.y);
    for (int i = 1; i < points.count; i++) {
        point = [points[i] CGPointValue];
        CGPathAddLineToPoint(path, nil, point.x, point.y);
        if (point.x < minX) {
            minX = point.x;
        }
        if (point.x > maxX) {
            maxX = point.x;
        }
        if (point.y < minY) {
            minY = point.y;
        }
        if (point.y > maxY) {
            maxY = point.y;
        }
    }

    CGFloat width = maxX - minX;
    CGFloat height = maxY - minY;
    CGAffineTransform transform = CGAffineTransformMakeScale((width - 2) / width, (height - 2) / height);
    path = CGPathCreateCopyByTransformingPath(path, &transform);

    return path;
}

@end
