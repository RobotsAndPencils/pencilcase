//
//  PCSnapNode.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-06-24.
//
//

#import "PCSnapNode.h"
#import "AppDelegate.h"
#import "SKNode+Snapping.h"
#import "PCGuidesNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+NodeInfo.h"

@interface PCSnapNode ()

@property (strong, nonatomic) NSMutableArray *snapLines;

@end

@implementation PCSnapNode

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _snapLines = [NSMutableArray array];

    return self;
}

#pragma mark - Snap logic

- (void)addVerticalSnapLineAtX:(CGFloat)x {
    CGFloat height = [PCStageScene scene].winSize.height;
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[NSColor selectedMenuItemColor] size:CGSizeMake(1, height)];
    sprite.position = CGPointMake(x, 0);
    sprite.anchorPoint = CGPointMake(0.5, 0);
    [self addChild:sprite];
    [self.snapLines addObject:sprite];
}

- (void)addHorizontalSnapLineAtY:(CGFloat)y {
    CGFloat width = [PCStageScene scene].winSize.width;
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[NSColor selectedMenuItemColor] size:CGSizeMake(width, 1)];
    sprite.position = CGPointMake(0, y);
    sprite.anchorPoint = CGPointMake(0, 0.5);
    [self addChild:sprite];
    [self.snapLines addObject:sprite];
}

- (void)snapNodesAndFindSnappedLinesWithCornerId:(CCBCornerId)cornerId lockAspectRatio:(BOOL)lockAspectRatio {

    [self removeSnapLines];

    AppDelegate *appDelegate = [AppDelegate appDelegate];
    if (appDelegate.selectedSpriteKitNodes.count != 1) return;

    SKSpriteNode *node = appDelegate.selectedSpriteKitNodes.firstObject;
    PCSnapFrame *worldNodeFrame = [[PCSnapFrame alloc] initWithNode:node];
    CGFloat worldRotation = [node.parent pc_convertRotationInDegreesToWorldSpace:node.rotation];

    PCTransformEdgeHandle handle = [worldNodeFrame transformEdgeHandleFromCornerId:cornerId];

    if (self.snappingToObjectsEnabled) {
        NSMutableArray *siblingNodes = [[node siblingNodesSortedByDistance] mutableCopy];
        [siblingNodes addObject:node.parent];
        [siblingNodes addObject:[PCStageScene scene].rootNode];
        for (SKNode *siblingNode in siblingNodes) {
            PCSnapFrame *worldSiblingFrame = [[PCSnapFrame alloc] initWithNode:siblingNode];
            if (worldRotation == 0 && [worldNodeFrame snapEdgesToFrame:worldSiblingFrame withHandle:handle lockAspectRatio:lockAspectRatio]) {
                [self drawSnapLinesBetweenNode:worldNodeFrame andSibling:worldSiblingFrame withHandle:handle];
            } else if ([worldNodeFrame snapNodeToFrame:worldSiblingFrame withHandle:handle]) {
                [self drawSnapLinesBetweenNode:worldNodeFrame andSibling:worldSiblingFrame withHandle:handle];
            }
        }
    }

    if (self.snappingToGuidesEnabled) {
        NSMutableArray *guideFrames = [self snapFramesFromGuides];
        for (PCSnapFrame *guide in guideFrames) {
            [worldNodeFrame snapNodeToFrame:guide withHandle:handle];
            [worldNodeFrame snapEdgesToFrame:guide withHandle:handle lockAspectRatio:lockAspectRatio];
        }
    }
}

- (NSMutableArray *)snapFramesFromGuides {
    NSMutableArray *guideFrames = [[NSMutableArray alloc] init];
    for (PCGuide *guide in [PCStageScene scene].guideLayer.guides) {
        [guideFrames addObject:[[PCSnapFrame alloc] initWithGuide:guide]];
    }
    return guideFrames;
}

- (void)drawSnapLinesBetweenNode:(PCSnapFrame *)rootNode andSibling:(PCSnapFrame *)rootSiblingNode withHandle:(PCTransformEdgeHandle)handle {
    PCSnapPoints snapPoints = [rootNode snapPointsWithNode:rootSiblingNode snapHandle:handle snapSensitivity:PCDefaultDragSnapSensitivity];
    if (!rootSiblingNode.node.parent) return;

    SKNode *root = [PCStageScene scene].rootNode;

    if (snapPoints & PCSnapPointToLeftEdgeMask) {
        [self addVerticalSnapLineAtX:[root convertPoint:CGPointMake(rootSiblingNode.left, 0) toNode:self.parent].x];
    }
    if (snapPoints & PCSnapPointToMiddleXMask) {
        [self addVerticalSnapLineAtX:[root convertPoint:CGPointMake(rootSiblingNode.centerX, 0) toNode:self.parent].x];
    }
    if (snapPoints & PCSnapPointToRightEdgeMask) {
        [self addVerticalSnapLineAtX:[root convertPoint:CGPointMake(rootSiblingNode.right, 0) toNode:self.parent].x];
    }

    if (snapPoints & PCSnapPointToBottomEdgeMask) {
        [self addHorizontalSnapLineAtY:[root convertPoint:CGPointMake(0, rootSiblingNode.bottom) toNode:self.parent].y];
    }
    if (snapPoints & PCSnapPointToMiddleYMask) {
        [self addHorizontalSnapLineAtY:[root convertPoint:CGPointMake(0, rootSiblingNode.centerY) toNode:self.parent].y];
    }
    if (snapPoints & PCSnapPointToTopEdgeMask) {
        [self addHorizontalSnapLineAtY:[root convertPoint:CGPointMake(0, rootSiblingNode.top) toNode:self.parent].y];
    }
}

- (void)removeSnapLines {
    [self.snapLines makeObjectsPerformSelector:@selector(removeFromParent)];
    [self.snapLines removeAllObjects];
}

#pragma mark - Mouse input

- (void)mouseDraggedWithCornerId:(CCBCornerId)cornerId lockAspectRatio:(BOOL)lockAspectRatio {
    if (self.snappingToGuidesEnabled || self.snappingToObjectsEnabled) {
        [self snapNodesAndFindSnappedLinesWithCornerId:cornerId lockAspectRatio:lockAspectRatio];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self removeSnapLines];
}

- (void)setSnappingToObjectsEnabled:(BOOL)snappingToObjectsEnabled {
    if (_snappingToObjectsEnabled != snappingToObjectsEnabled) {
        _snappingToObjectsEnabled = snappingToObjectsEnabled;
        if (!_snappingToObjectsEnabled) {
            [self removeSnapLines];
        }
    }
}

@end
