//
//  SKCropNode+Nesting.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-12.
//
//

#import "SKCropNode+Nesting.h"
#import "SKNode+CocosCompatibility.h"
#import "CGPointUtilities.h"
#import "SKNode+CoordinateConversion.h"

@implementation SKCropNode(Nesting)

- (SKNode *)constrainMaskToParentCropNodes:(SKNode *)maskNode inScene:(SKScene *)scene {
    if (!scene.view) return maskNode;

    SKCropNode *tempCropNode = [SKCropNode node];
    tempCropNode.maskNode = [maskNode copy];
    [tempCropNode addChild:[maskNode copy]];

    [self addChild:tempCropNode];
    
    CGFloat cumulativeRotation = -self.zRotation;
    CGFloat cumulativeScaleX = 1 / self.xScale;
    CGFloat cumulativeScaleY = 1 / self.yScale;
    
    for (SKNode *parent = self.parent; parent; parent = parent.parent) {
        if ([parent isKindOfClass:[SKCropNode class]]) {
            SKCropNode *cropParent = (SKCropNode *)parent;
            if (!cropParent.maskNode) break;

            SKNode *maskNodeCopy = [cropParent.maskNode copy];
            maskNodeCopy.zRotation = cumulativeRotation;
            maskNodeCopy.position = CGPointApplyAffineTransform(CGPointZero, CGAffineTransformInvert([self pc_nodeToAncestorSpaceTransform:cropParent]));
            maskNodeCopy.xScale = cropParent.maskNode.xScale * cumulativeScaleX;
            maskNodeCopy.yScale = cropParent.maskNode.yScale * cumulativeScaleY;
            maskNodeCopy.anchorPoint = CGPointZero;

            tempCropNode.maskNode = maskNodeCopy;
            tempCropNode.xScale /= cumulativeScaleX;
            tempCropNode.yScale /= cumulativeScaleY;

            SKTexture *texture = [scene.view textureFromNode:tempCropNode];
            //Frustrating - in some conditions, the above seems to be returning an @1x texture on an @2x device, causing
            //the mask node to be completely borked. So instead of querying the system for what the scale factor is, we have
            //to get it from the texture.
            CGFloat realTextureWidth = texture.size.width * cumulativeScaleX;
            CGFloat textureScale = (realTextureWidth / maskNode.contentSize.width);
            CGFloat retinaScaleFactor = 1 / textureScale;

            tempCropNode.maskNode = [SKSpriteNode spriteNodeWithTexture:texture];
            tempCropNode.maskNode.xScale = retinaScaleFactor * cumulativeScaleX;
            tempCropNode.maskNode.yScale = retinaScaleFactor * cumulativeScaleY;
            tempCropNode.maskNode.position = CGPointZero;
            tempCropNode.maskNode.rotation = 0;
            tempCropNode.maskNode.anchorPoint = CGPointZero;
            break;
        } else {
            cumulativeRotation -= parent.zRotation;
            cumulativeScaleX /= parent.xScale;
            cumulativeScaleY /= parent.yScale;
        }
    }
    
    SKNode *result = tempCropNode.maskNode;
    [tempCropNode removeFromParent];
    return result;
}

@end
