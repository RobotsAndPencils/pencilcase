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

// Project
#import "CGPointUtilities.h"
#import "CGVectorUtilities.h"
#import "PositionPropertySetter.h"
#import "PCMathUtilities.h"
#import "PCOverlayNode.h"

@implementation SKNode (CoordinateConversion)

#pragma mark Coordinate space conversion

- (void)pc_translateFromParent:(SKNode *)parent toParent:(SKNode *)insertionNode {
    CGPoint worldPosition = [parent pc_convertToWorldSpace:self.position];
    CGPoint dropPosition = [insertionNode convertPoint:worldPosition fromNode:insertionNode.scene];
    [PositionPropertySetter setPosition:dropPosition forSpriteKitNode:self prop:@"position"];
    CGFloat newScaleX = self.xScale * parent.xScale / insertionNode.xScale;
    CGFloat newScaleY = self.yScale * parent.yScale / insertionNode.yScale;
    [PositionPropertySetter setScaledX:newScaleX Y:newScaleY forSpriteKitNode:self prop:@"scale"];

    CGFloat worldRotation = [parent pc_convertRotationInDegreesToWorldSpace:self.rotation];
    CGFloat nodeDropRotation = [insertionNode pc_convertRotationInDegreesToNodeSpace:worldRotation];
    self.rotation = nodeDropRotation;
}

#pragma mark Point conversion

- (CGPoint)pc_convertToNodeSpace:(CGPoint)worldPoint {
    if (!self.scene) return CGPointZero;

    CGPoint pointInNodeSpace = [self.scene convertPoint:worldPoint toNode:self];
    return pointInNodeSpace;
}

- (CGPoint)pc_convertToWorldSpace:(CGPoint)nodePoint {
    if (!self.scene) return CGPointZero;

    CGPoint pointInWorldSpace = [self convertPoint:nodePoint toNode:self.scene];
    return pointInWorldSpace;
}

#pragma mark Rotation conversion

- (CGFloat)pc_convertRotationInDegreesToWorldSpace:(CGFloat)rotation {
    CGFloat compoundRotation = rotation;
    SKNode *node = self;
    do {
        compoundRotation *= pc_sign(node.xScale * node.yScale);
        compoundRotation += node.rotation;
        node = node.parent;
    } while (node);
    return compoundRotation;
}

- (CGFloat)pc_convertRotationInDegreesToNodeSpace:(CGFloat)rotation {
    CGFloat compoundRotation = rotation;
    SKNode *node = self;
    do {
        compoundRotation *= pc_sign(node.xScale * node.yScale);
        compoundRotation -= node.rotation;
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
        scale = pc_CGVectorDivide(scale, CGVectorMake(node.scaleX, node.scaleY));
        node = node.parent;
    } while (node.parent);
    
    return scale;
}

- (CGVector)pc_convertScaleToWorldSpace:(CGVector)nodeScale {
    CGVector scale = nodeScale;
    SKNode *node = self;
    
    do {
        scale = pc_CGVectorMultiply(scale, CGVectorMake(node.scaleX, node.scaleY));
        node = node.parent;
    } while (node.parent);
    
    return scale;
}

#pragma mark Transforms

- (CGAffineTransform)pc_nodeToParentTransform {
    CGAffineTransform scale = CGAffineTransformMakeScale(self.xScale, self.yScale);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(self.zRotation);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(self.position.x, self.position.y);
    return CGAffineTransformConcat(CGAffineTransformConcat(scale, rotation), translation);
}

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

- (CGAffineTransform)pc_nodeToTrackingParentTransform {
    CGAffineTransform anchorPointAdjustment = CGAffineTransformMakeTranslation(self.parent.contentSize.width * self.parent.anchorPoint.x,
                                                                               self.parent.contentSize.height * self.parent.anchorPoint.y);
    return CGAffineTransformConcat([self pc_nodeToParentTransform], anchorPointAdjustment);
}

#pragma mark - Convenience

- (void)pc_centerInParent {
    SKNode *parent = self.parent;
    CGPoint point = CGPointMake(parent.anchorPoint.x * parent.contentSize.width, parent.anchorPoint.y * parent.contentSize.height);
    point = pc_CGPointSubtract(CGPointMake(self.anchorPoint.x * parent.contentSize.width, self.anchorPoint.y * parent.contentSize.height), point);
    self.position = point;
}

- (void)pc_aspectFitInParent {
    self.xScale = self.yScale = MIN(MIN(1, self.parent.contentSize.width / self.contentSize.width),
                                    MIN(1, self.parent.contentSize.height / self.contentSize.height));
}

- (void)pc_aspectFillParent {
    self.xScale = self.yScale = MIN(self.parent.contentSize.width / self.contentSize.width,
                                    self.parent.contentSize.height / self.contentSize.height);
}

@end
