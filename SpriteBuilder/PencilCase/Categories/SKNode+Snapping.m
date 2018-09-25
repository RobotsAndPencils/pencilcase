//
//  SKNode+PositionHelper.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-06-24.
//
//

#import "SKNode+Snapping.h"
#import "CGPointUtilities.h"
#import "PositionPropertySetter.h"
#import "SKNode+NodeInfo.h"
#import "PCStageScene.h"

@implementation SKNode(Snapping)

- (NSArray *)siblingNodesSortedByDistance {
    NSMutableArray *sourceArray = [self.parent.children mutableCopy];
    [sourceArray removeObject:self];
    if ([self.parent.className isEqualToString:@"PCSKPhysicsNode"]) {
        [sourceArray addObject:[PCStageScene scene].rootNode];
    }
    return [sourceArray sortedArrayUsingComparator:^NSComparisonResult(SKNode *firstNode, SKNode *secondNode) {
        CGFloat distanceToFirstNode = pc_CGPointDistance(self.position, firstNode.position);
        CGFloat distanceToSecondNode = pc_CGPointDistance(self.position, secondNode.position);
        if (distanceToFirstNode > distanceToSecondNode) {
            return NSOrderedDescending;
        } else if (distanceToFirstNode < distanceToSecondNode) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (void)alignToPixels {
    if (![self allowsUserPositioning]) return;
    [PositionPropertySetter setPosition:pc_CGPointIntegral(self.position) forSpriteKitNode:self prop:@"position"];
}

@end
