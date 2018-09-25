//
//  SKNode+Movement.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-09.
//
//

#import "SKNode+Movement.h"
#import "PositionPropertySetter.h"
#import "AppDelegate.h"
#import "SKNode+Snapping.h"
#import "SKNode+NodeInfo.h"
#import "PCStageScene.h"
#import "CGPointUtilities.h"
#import "PCSnapFrame.h"

@implementation SKNode (Movement)

+ (void)pc_alignNodes:(NSArray *)nodes withAlignment:(PCAlignment)alignmentType {
    if (nodes.count == 0) return;

    if (nodes.count == 1) {
        switch (alignmentType)
        {
            case PCAlignmentHorizontalCenter:
            case PCAlignmentVerticalCenter:
            case PCAlignmentAcross:
            case PCAlignmentDown:
                return;
            default:
                break;
        }
    }

    switch (alignmentType)
    {
        case PCAlignmentHorizontalCenter:
        case PCAlignmentVerticalCenter:
            [SKNode pc_alignNodes:nodes toCenterWithAlignmentType:alignmentType];
            [SKNode pc_refreshPositionKeyframesForNodes:nodes];
            [[AppDelegate appDelegate] refreshProperty:@"position"];
            break;
        case PCAlignmentLeft:
        case PCAlignmentRight:
        case PCAlignmentTop:
        case PCAlignmentBottom:
            [SKNode pc_alignNodes:nodes toEdgeWithAlignmentType:alignmentType];
            [SKNode pc_refreshPositionKeyframesForNodes:nodes];
            [[AppDelegate appDelegate] refreshProperty:@"position"];
            break;
        case PCAlignmentAcross:
            [SKNode pc_distributeNodesHorizontally:nodes];
            [SKNode pc_refreshPositionKeyframesForNodes:nodes];
            [[AppDelegate appDelegate] refreshProperty:@"position"];
            break;
        case PCAlignmentDown:
            [SKNode pc_distributeNodesVertically:nodes];
            [SKNode pc_refreshPositionKeyframesForNodes:nodes];
            [[AppDelegate appDelegate] refreshProperty:@"position"];
            break;
        case PCAlignmentSameSize:
        case PCAlignmentSameWidth:
        case PCAlignmentSameHeight:
            // Registering undo with "size" as a common property since we *could* be changing either/both of scale and content size
            [SKNode pc_matchNodes:nodes sizeWithType:alignmentType];
            [[AppDelegate appDelegate] refreshProperty:@"scale"];
            [[AppDelegate appDelegate] refreshProperty:@"contentSize"];

            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"size"];
            break;
        default:
            break;
    }

    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*align"];
}

+ (void)pc_moveNodes:(NSArray *)nodes inDirection:(PCMoveDirection)direction
{
    if (nodes.count == 0) return;

    CGPoint delta = CGPointZero;
    if (direction == PCMoveDirectionLeft) delta = CGPointMake(-10, 0);
    else if (direction == PCMoveDirectionRight) delta = CGPointMake(10, 0);
    else if (direction == PCMoveDirectionUp) delta = CGPointMake(0, 10);
    else if (direction == PCMoveDirectionDown) delta = CGPointMake(0, -10);

    [SKNode pc_moveNodes:nodes withDelta:delta];
}

+ (void)pc_nudgeNodes:(NSArray *)nodes inDirection:(PCMoveDirection)direction {
    if (nodes.count == 0) return;

    CGPoint delta = CGPointZero;
    if (direction == 0) delta = CGPointMake(-1, 0);
    else if (direction == 1) delta = CGPointMake(1, 0);
    else if (direction == 2) delta = CGPointMake(0, 1);
    else if (direction == 3) delta = CGPointMake(0, -1);

    [SKNode pc_moveNodes:nodes withDelta:delta];
}

+ (void)pc_moveNodes:(NSArray *)nodes withDelta:(CGPoint)delta {
    if (nodes.count == 0) return;

    for (SKNode *node in nodes) {
        if (node.locked || ![node allowsUserPositioning]) continue;

        // Get and update absolute position
        CGPoint absolutePosition = node.position;
        absolutePosition = pc_CGPointAdd(absolutePosition, delta);

        // Convert to relative position
        NSPoint newPosition = absolutePosition;

        // Update the selected node
        [PositionPropertySetter setPosition:newPosition forSpriteKitNode:node prop:@"position"];
        [PositionPropertySetter addPositionKeyframeForSpriteKitNode:node];
    }
    
    // Only refresh property and save the undo state once, instead for each selected node
    [[AppDelegate appDelegate] refreshProperty:@"position"];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"position"];
}

#pragma mark - Helpers

+ (void)pc_alignNodes:(NSArray *)nodes toCenterWithAlignmentType:(PCAlignment)alignmentType {
    CGFloat center = 0.0;
    SKNode *firstObject = nodes.firstObject;
    PCSnapFrame *firstNode = [[PCSnapFrame alloc] initWithFrame:firstObject.frame];
    CGFloat leftmostX = firstNode.left;
    CGFloat rightmostX = firstNode.right;
    CGFloat bottommostY = firstNode.bottom;
    CGFloat topmostY = firstNode.top;

    for (SKNode *node in nodes) {
        PCSnapFrame *nodeFrame = [[PCSnapFrame alloc] initWithFrame:node.frame];
        if (alignmentType == PCAlignmentHorizontalCenter) {
            leftmostX = fmin(nodeFrame.left, leftmostX);
            rightmostX = fmax(nodeFrame.right, rightmostX);
        }
        else if (alignmentType == PCAlignmentVerticalCenter) {
            bottommostY = fmin(nodeFrame.bottom, bottommostY);
            topmostY = fmax(nodeFrame.top, topmostY);
        }
    }
    if (alignmentType == PCAlignmentHorizontalCenter) {
        center = leftmostX + (rightmostX - leftmostX) / 2;
    }
    else if (alignmentType == PCAlignmentVerticalCenter) {
        center = bottommostY + (topmostY - bottommostY) / 2;
    }

    // Set the visual center (not necessarily the anchor point) of objects to the center value
    for (SKNode *node in nodes) {
        if (node.locked) continue;

        CGPoint newPosition = node.position;
        if (alignmentType == PCAlignmentHorizontalCenter) {
            newPosition.x = center - CGRectGetWidth(node.frame) * (0.5 - node.anchorPoint.x);
        }
        else if (alignmentType == PCAlignmentVerticalCenter) {
            newPosition.y = center - CGRectGetHeight(node.frame) * (0.5 - node.anchorPoint.y);
        }

        [PositionPropertySetter setPosition:newPosition forSpriteKitNode:node prop:@"position"];
    }
}

+ (void)pc_alignNodes:(NSArray *)nodes toEdgeWithAlignmentType:(PCAlignment)alignmentType {
    if (nodes.count == 0) return;

    CGFloat edgeX = 0, edgeY = 0;
    SKNode *firstNode = [nodes firstObject];
    CGRect containingRect;

    // Find the coordinate of the outermost edge by finding the edge coordinate of the union of all node frames
    if (nodes.count == 1) {
        if (firstNode.locked) return;

        // Get the max values from either the parent or stage
        if ([firstNode.parent isKindOfClass:NSClassFromString(@"PCSKSlideNode")] || [firstNode.parent isKindOfClass:NSClassFromString(@"PCSKPhysicsNode")]) {
            PCStageScene *stageScene = [PCStageScene scene];
            containingRect = CGRectMake(0, 0, stageScene.stageSize.width, stageScene.stageSize.height);
        } else {
            // When aligning with parent we need to use the parent's bounds while taking into account its anchorPoint because that affects the child position
            containingRect = CGRectMake(-(firstNode.parent.contentSize.width * firstNode.parent.anchorPoint.x), -(firstNode.parent.contentSize.height * firstNode.parent.anchorPoint.y), firstNode.parent.contentSize.width, firstNode.parent.contentSize.height);
        }
    } else {
        containingRect = firstNode.frame;
    }
    for (SKNode *node in nodes) {
        if (node.locked) continue;
        containingRect = CGRectUnion(containingRect, node.frame);
    }

    switch (alignmentType) {
        case PCAlignmentLeft:
            edgeX = CGRectGetMinX(containingRect);
            break;
        case PCAlignmentRight:
            edgeX = CGRectGetMaxX(containingRect);
            break;
        case PCAlignmentTop:
            edgeY = CGRectGetMaxY(containingRect);
            break;
        case PCAlignmentBottom:
            edgeY = CGRectGetMinY(containingRect);
            break;
        default:
            break;
    }

    // Align to edge coordinate
    for (SKNode *node in nodes) {
        if (node.locked) continue;
        CGPoint newPosition = node.position;

        switch (alignmentType) {
            case PCAlignmentLeft: {
                newPosition.x = edgeX + CGRectGetWidth(node.frame) * node.anchorPoint.x;
                break;
            }
            case PCAlignmentRight: {
                newPosition.x = edgeX - CGRectGetWidth(node.frame) * (1 - node.anchorPoint.x);
                break;
            }
            case PCAlignmentTop: {
                newPosition.y = edgeY - CGRectGetHeight(node.frame) * (1 - node.anchorPoint.y);
                break;
            }
            case PCAlignmentBottom: {
                newPosition.y = edgeY + CGRectGetHeight(node.frame) * node.anchorPoint.y;
                break;
            }
            default:
                break;
        }

        [PositionPropertySetter setPosition:newPosition forSpriteKitNode:node prop:@"position"];
    }
}

+ (void)pc_distributeNodesHorizontally:(NSArray *)nodes {
    if (nodes.count < 3) return;

    CGFloat x;
    CGFloat cxNode;
    CGFloat xMin = FLT_MAX;
    CGFloat xMax = FLT_MIN;
    CGFloat cxTotal = 0.0;
    CGFloat cxInterval;

    for (SKNode *node in nodes) {
        if (node.locked) continue;
        cxNode = CGRectGetWidth(node.frame);
        x = node.position.x - cxNode * node.anchorPoint.x;

        if (xMin > x) xMin = x;
        if (xMax < x + cxNode) xMax = x + cxNode;

        cxTotal += cxNode;
    }

    cxInterval = (xMax - xMin - cxTotal) / (nodes.count - 1);

    x = xMin;

    NSArray *sortedNodes = [nodes sortedArrayUsingComparator:^NSComparisonResult(SKNode *lhs, SKNode *rhs) {
        NSPoint l = lhs.position;
        NSPoint r = rhs.position;

        CGFloat leftX = l.x - CGRectGetWidth(lhs.frame) * lhs.anchorPoint.x;
        CGFloat rightX = r.x - CGRectGetWidth(rhs.frame) * rhs.anchorPoint.x;

        if (leftX < rightX) return NSOrderedAscending;
        if (leftX > rightX) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    for (SKNode *node in sortedNodes) {
        if (node.locked) continue;

        CGPoint newPosition = node.position;

        cxNode = CGRectGetWidth(node.frame);

        newPosition.x = x + cxNode * node.anchorPoint.x;

        x = x + cxNode + cxInterval;

        [PositionPropertySetter setPosition:newPosition forSpriteKitNode:node prop:@"position"];
    }
}


+ (void)pc_distributeNodesVertically:(NSArray *)nodes {
    if (nodes.count < 3) return;

    CGFloat y;
    CGFloat cyNode;
    CGFloat yMin = FLT_MAX;
    CGFloat yMax = FLT_MIN;
    CGFloat cyTotal = 0;
    CGFloat cyInterval;

    for (SKNode *node in nodes) {
        if (node.locked) continue;
        cyNode = CGRectGetHeight(node.frame);
        y = node.position.y - cyNode * node.anchorPoint.y;

        if (yMin > y) yMin = y;
        if (yMax < y + cyNode) yMax = y + cyNode;
        cyTotal += cyNode;
    }

    cyInterval = (yMax - yMin - cyTotal) / (nodes.count - 1);

    y = yMin;

    NSArray *sortedNodes = [nodes sortedArrayUsingComparator:^NSComparisonResult(SKNode *lhs, SKNode *rhs) {
        NSPoint l = lhs.position;
        NSPoint r = rhs.position;

        CGFloat leftY = l.y - CGRectGetHeight(lhs.frame) * lhs.anchorPoint.y;
        CGFloat rightY = r.y - CGRectGetHeight(rhs.frame) * rhs.anchorPoint.y;

        if (leftY < rightY) return NSOrderedAscending;
        if (leftY > rightY) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    for (SKNode *node in sortedNodes) {
        if (node.locked) continue;

        CGPoint newPosition = node.position;

        cyNode = CGRectGetHeight(node.frame);

        newPosition.y = y + cyNode * node.anchorPoint.y;

        y = y + cyNode + cyInterval;

        [PositionPropertySetter setPosition:newPosition forSpriteKitNode:node prop:@"position"];
    }
}

+ (void)pc_matchNodes:(NSArray *)nodes sizeWithType:(int)matchSizeType {
    SKNode *targetNode;

    if (nodes.count == 1) {
        // Set the width to either the stage or parent
        SKNode *node = [nodes firstObject];
        if (![node allowsUserSizing]) return;
        targetNode = [node parent];
        if ([targetNode isKindOfClass:NSClassFromString(@"PCSKPhysicsNode")] || [targetNode isEqual:[PCStageScene scene].rootNode]) {
            // Just a placeholder node with the same size as the stage, we don't need it after the lifetime of this method call
            targetNode = [SKSpriteNode spriteNodeWithColor:[NSColor clearColor] size:[PCStageScene scene].stageSize];
        }
    }
    else {
        // If more than one node is selected, set the new width/height/size to the first selected node's dimension(s)
        targetNode = [nodes firstObject];
    }

    for (SKNode *node in nodes) {
        switch ([node editorResizeBehaviour]) {
            case PCEditorResizeBehaviourScale: {
                CGFloat newScaleX = node.scaleX, newScaleY = node.scaleY;

                switch (matchSizeType) {
                    case PCAlignmentSameWidth:
                        newScaleX = targetNode.size.width / node.contentSize.width;
                        newScaleY = node.scaleY;
                        break;
                    case PCAlignmentSameHeight:
                        newScaleX = node.scaleX;
                        newScaleY = targetNode.size.height / node.contentSize.height;
                        break;
                    case PCAlignmentSameSize:
                        newScaleX = targetNode.size.width / node.contentSize.width;
                        newScaleY = targetNode.size.height / node.contentSize.height;
                        break;
                    default:
                        break;
                }

                [PositionPropertySetter setScaledX:newScaleX Y:newScaleY forSpriteKitNode:node prop:@"scale"];
            }
            case PCEditorResizeBehaviourContentSize: {
                CGFloat newContentSizeWidth = node.contentSize.width, newContentSizeHeight = node.contentSize.height;

                switch (matchSizeType) {
                    case PCAlignmentSameWidth:
                        newContentSizeWidth = targetNode.size.width / node.scaleX;
                        newContentSizeHeight = node.contentSize.height;
                        break;
                    case PCAlignmentSameHeight:
                        newContentSizeWidth = node.contentSize.width;
                        newContentSizeHeight = targetNode.size.height / node.scaleY;
                        break;
                    case PCAlignmentSameSize:
                        newContentSizeWidth = targetNode.size.width / node.scaleX;
                        newContentSizeHeight = targetNode.size.height / node.scaleY;
                        break;
                    default:
                        break;
                }

                [PositionPropertySetter setSize:CGSizeMake(newContentSizeWidth, newContentSizeHeight) forSpriteKitNode:node prop:@"contentSize"];
            }
        }
    }
}

+ (void)pc_refreshPositionKeyframesForNodes:(NSArray *)nodes {
    // After aligning the nodes we'll want to update any keyframes
    // This has been brought outside of the align method because it should work independent of the concept of keyframes
    for (SKNode *node in nodes) {
        [PositionPropertySetter addPositionKeyframeForSpriteKitNode:node];
    }
}

+ (void)pc_alignNodesToPixels:(NSArray *)nodes {
    for (SKNode *node in nodes) {
        [node alignToPixels];
    }
}



@end
