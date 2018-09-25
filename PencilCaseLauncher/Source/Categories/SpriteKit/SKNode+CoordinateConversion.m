//
//  SKNode+CoordinateConversion.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-07-08.
//
//

// Header
#import "SKNode+CoordinateConversion.h"

// Categories
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"

// Project
#import "CGPointUtilities.h"
#import "CGVectorUtilities.h"
#import "PCMathUtilities.h"

@protocol PCOverlayNode;


@implementation SKNode (CoordinateConversion)

#pragma mark Point conversion

- (CGPoint)pc_convertToNodeSpace:(CGPoint)worldPoint {
    if (!self.pc_scene) return CGPointZero;

    CGPoint pointInNodeSpace = [self.pc_scene convertPoint:worldPoint toNode:self];
    return pointInNodeSpace;
}

- (CGPoint)pc_convertToWorldSpace:(CGPoint)nodePoint {
    if (!self.pc_scene) return CGPointZero;

    CGPoint pointInWorldSpace = [self convertPoint:nodePoint toNode:self.pc_scene];
    return pointInWorldSpace;
}

#pragma mark Rotation conversion

- (CGFloat)pc_convertRotationInDegreesToWorldSpace:(CGFloat)rotation {
    CGFloat compoundRotation = rotation;
    SKNode *node = self;
    do {
        compoundRotation *= pc_sign(node.xScale * node.yScale);
        compoundRotation += node.zRotation;
        node = node.parent;
    } while (node);
    return compoundRotation;
}

- (CGFloat)pc_convertRotationInDegreesToNodeSpace:(CGFloat)rotation {
    CGFloat compoundRotation = rotation;
    SKNode *node = self;
    do {
        compoundRotation *= pc_sign(node.xScale * node.yScale);
        compoundRotation -= node.zRotation;
        node = node.parent;
    } while (node);
    return compoundRotation;
}

#pragma mark - Size conversions

- (CGSize)pc_convertSize:(CGSize)size toNode:(SKNode *)targetNode {
    if (!self.scene || targetNode.scene != self.scene) return CGSizeZero;

    CGSize worldSize = size;
    for (SKNode *parent = self; parent; parent = parent.parent) {
        worldSize.width *= parent.xScale;
        worldSize.height *= parent.yScale;
        if (parent == targetNode) return worldSize;
    }

    //If we got here, that means that we were not a descendant of target node, so we have to navigate up the target node's tree to find either self, or the world transform of the target node
    CGPoint targetScale = CGPointMake(targetNode.xScale, targetNode.yScale);
    for (SKNode *parent = targetNode.parent; parent; parent = parent.parent) {
        if (parent == self) return CGSizeMake(size.width / targetScale.x, size.height / targetScale.y);
        targetScale.x *= parent.xScale;
        targetScale.y *= parent.yScale;
    }

    //Neither node was a direct descendent of the other, convert self's world scale to the targets space
    return CGSizeMake(worldSize.width / targetScale.x, worldSize.height / targetScale.y);
}

#pragma mark - Scale conversions

- (CGVector)pc_convertScaleToNodeSpace:(CGVector)worldScale {
    CGVector scale = worldScale;
    SKNode *node = self;
    
    do {
        scale = pc_CGVectorDivide(scale, CGVectorMake(node.xScale, node.yScale));
        node = node.parent;
    } while (node.parent);
    
    return scale;
}

- (CGVector)pc_convertScaleToWorldSpace:(CGVector)nodeScale {
    CGVector scale = nodeScale;
    SKNode *node = self;
    
    do {
        scale = pc_CGVectorMultiply(scale, CGVectorMake(node.xScale, node.yScale));
        node = node.parent;
    } while (node.parent);
    
    return scale;
}

#pragma mark Transforms

- (CGAffineTransform)pc_nodeToAncestorSpaceTransform:(SKNode *)ancestor {
    CGAffineTransform transform = CGAffineTransformIdentity;
    for (SKNode *p = self; p != nil && p != ancestor; p = p.parent) {
        if ([self conformsToProtocol:@protocol(PCOverlayNode)] && [p.parent conformsToProtocol:@protocol(PCOverlayNode)]) {
            transform = CGAffineTransformConcat(transform, [p pc_nodeToTrackingParentTransform]);
        } else {
            transform = CGAffineTransformConcat(transform, [p pc_nodeToParentTransform]);
        }
    }

    return transform;
}

- (CGAffineTransform)pc_nodeToFirstTrackingParentTransform {
    CGAffineTransform transform = [self pc_nodeToTrackingParentTransform];

    for (SKNode *p = self.parent; p != nil && ![p conformsToProtocol:@protocol(PCOverlayNode)]; p = p.parent) {
        transform = CGAffineTransformConcat(transform, [p pc_nodeToTrackingParentTransform]);
    }

    return transform;
}

- (CGAffineTransform)pc_nodeToWorldTransform {
    CGAffineTransform transform = [self pc_nodeToParentTransform];

    for (SKNode *p = self.parent; p != nil; p = p.parent) {
        transform = CGAffineTransformConcat(transform, [p pc_nodeToParentTransform]);
    }

    return transform;
}

- (CGAffineTransform)pc_nodeToParentTransform {
    CGAffineTransform position = CGAffineTransformMakeTranslation(self.position.x, self.position.y);
    CGAffineTransform scale = CGAffineTransformMakeScale(self.xScale, self.yScale);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(self.zRotation);
    return CGAffineTransformConcat(CGAffineTransformConcat(scale, rotation), position);
}

- (CGAffineTransform)pc_nodeToTrackingParentTransform {
    CGAffineTransform position = CGAffineTransformMakeTranslation(self.position.x, -self.position.y);
    CGAffineTransform scale = CGAffineTransformMakeScale(self.xScale, self.yScale);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-self.zRotation);
    return CGAffineTransformConcat(CGAffineTransformConcat(scale, rotation), position);
}

#pragma mark - Convenience

- (void)pc_centerInParent {
    SKNode *parent = self.parent;
    CGPoint point = CGPointMake(parent.anchorPoint.x * parent.contentSize.width, parent.anchorPoint.y * parent.contentSize.height);
    point = pc_CGPointSubtract(CGPointMake(self.anchorPoint.x * parent.contentSize.width, self.anchorPoint.y * parent.contentSize.height), point);
    self.position = point;
}

@end
