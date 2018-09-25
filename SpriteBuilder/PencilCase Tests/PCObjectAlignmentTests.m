//
//  PCObjectAlignmentTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-07-25.
//
//

#import <SpriteKit/SpriteKit.h>
#import <XCTest/XCTest.h>
#import "PCStageScene.h"
#import "AppDelegate.h" // Just included for alignment enums
#import <tgmath.h>
#import "SKNode+Movement.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(AlignSpec)

describe(@"Align node to left edge", ^{
    __block SKSpriteNode *leftNode, *firstMiddleNode, *secondMiddleNode, *rightNode;
    __block NSArray *objects;
    beforeAll(^{
        leftNode =[SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        leftNode.position = CGPointMake(50, 50);

        firstMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        firstMiddleNode.position = CGPointMake(55, 50);
        firstMiddleNode.zRotation = M_PI_4;

        secondMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        secondMiddleNode.position = CGPointMake(60, 50);

        rightNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        rightNode.position = CGPointMake(100, 50);

        objects = @[leftNode, firstMiddleNode, secondMiddleNode, rightNode];
    });

    context(@"When left aligning nodes", ^{
        it(@"Nodes should all have same minimum x value", ^{
            [SKNode pc_alignNodes:objects toEdgeWithAlignmentType:PCAlignmentLeft];
            for (SKNode *node in objects) {
                [[theValue(CGRectGetMinX(node.frame)) should] equal:theValue(CGRectGetMinX(firstMiddleNode.frame))];
            }
        });
    });
});

SPEC_END

@interface PCObjectAlignmentTests : XCTestCase

@end

@implementation PCObjectAlignmentTests

- (void)testAlignNodesToLeftEdge {
    SKSpriteNode *leftNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    leftNode.position = CGPointMake(50, 50);

    SKSpriteNode *firstMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    firstMiddleNode.position = CGPointMake(55, 50);
    firstMiddleNode.zRotation = M_PI_4;

    SKSpriteNode *secondMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    secondMiddleNode.position = CGPointMake(60, 50);

    SKSpriteNode *rightNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    rightNode.position = CGPointMake(100, 50);

    NSArray *objects = @[ leftNode, firstMiddleNode, secondMiddleNode, rightNode ];

    [SKNode pc_alignNodes:objects toEdgeWithAlignmentType:PCAlignmentLeft];

    for (SKNode *node in objects) {
        XCTAssert(CGRectGetMinX(node.frame) == CGRectGetMinX(firstMiddleNode.frame), @"Nodes were not left aligned properly");
    }
}

- (void)testAlignNodesToTopEdge {
    SKSpriteNode *leftNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    leftNode.position = CGPointMake(50, 50);

    SKSpriteNode *firstMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    firstMiddleNode.position = CGPointMake(55, 50);
    firstMiddleNode.zRotation = M_PI_4;

    SKSpriteNode *secondMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    secondMiddleNode.position = CGPointMake(60, 0);
    secondMiddleNode.zRotation = M_PI_2;

    SKSpriteNode *rightNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    rightNode.position = CGPointMake(100, 25);

    NSArray *objects = @[ leftNode, firstMiddleNode, secondMiddleNode, rightNode ];

    [SKNode pc_alignNodes:objects toEdgeWithAlignmentType:PCAlignmentTop];

    for (SKNode *node in objects) {
        XCTAssertEqualWithAccuracy(CGRectGetMaxY(node.frame), CGRectGetMaxY(firstMiddleNode.frame), 0.001, @"Nodes were not top aligned properly");
    }
}

- (void)testAlignNodeToParentLeftEdge {
    SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    childNode.position = CGPointMake(50, 50);
    
    SKSpriteNode *parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    parentNode.position = CGPointMake(55, 50);
    [parentNode addChild:childNode];
    
    NSArray *objects = @[ childNode ];
    
    [SKNode pc_alignNodes:objects toEdgeWithAlignmentType:PCAlignmentLeft];
    
    for (SKNode *node in objects) {
        XCTAssert(CGRectGetMinX(node.frame) == -parentNode.anchorPoint.x * childNode.size.width, @"Nodes were not left aligned properly");
    }
}

- (void)testAlignNodeToParentTopEdge {
    SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    childNode.position = CGPointMake(50, 50);
    
    SKSpriteNode *parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    parentNode.position = CGPointMake(55, 50);
    [parentNode addChild:childNode];
    
    NSArray *objects = @[ childNode ];
    
    [SKNode pc_alignNodes:objects toEdgeWithAlignmentType:PCAlignmentTop];
    
    for (SKNode *node in objects) {
        XCTAssert(CGRectGetMaxY(node.frame) == CGRectGetHeight(parentNode.frame), @"Nodes were not left aligned properly");
    }
}

- (void)testAlignNodesToHorizontalCenter {
    SKSpriteNode *leftNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    leftNode.position = CGPointMake(50, 50);
    
    SKSpriteNode *firstMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    firstMiddleNode.position = CGPointMake(55, 50);
    
    SKSpriteNode *secondMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    secondMiddleNode.position = CGPointMake(60, 50);
    
    SKSpriteNode *rightNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    rightNode.position = CGPointMake(100, 50);
    
    NSArray *objects = @[ leftNode, firstMiddleNode, secondMiddleNode, rightNode ];
    
    [SKNode pc_alignNodes:objects toCenterWithAlignmentType:PCAlignmentHorizontalCenter];
    
    for (SKNode *node in objects) {
        XCTAssert(CGRectGetMidX(node.frame) == 75, @"Nodes were not left aligned properly");
    }
}

- (void)testAlignNodesToVerticalCenter {
    SKSpriteNode *leftNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    leftNode.position = CGPointMake(50, 50);
    
    SKSpriteNode *firstMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    firstMiddleNode.position = CGPointMake(55, 50);
    
    SKSpriteNode *secondMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    secondMiddleNode.position = CGPointMake(60, 0);
    
    SKSpriteNode *rightNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    rightNode.position = CGPointMake(100, 25);
    
    NSArray *objects = @[ leftNode, firstMiddleNode, secondMiddleNode, rightNode ];
    
    [SKNode pc_alignNodes:objects toCenterWithAlignmentType:PCAlignmentVerticalCenter];
    
    for (SKNode *node in objects) {
        XCTAssert(CGRectGetMidY(node.frame) == 25, @"Nodes were not top aligned properly");
    }
}

- (void)testAlignNodeToParentHorizontalCenter {
    SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    childNode.position = CGPointMake(50, 50);
    
    SKSpriteNode *parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    parentNode.position = CGPointMake(55, 50);
    [parentNode addChild:childNode];
    
    NSArray *objects = @[ childNode ];
    
    [SKNode pc_alignNodes:objects toCenterWithAlignmentType:PCAlignmentHorizontalCenter];
    
    for (SKNode *node in objects) {
        XCTAssert(CGRectGetMidX(node.frame) == CGRectGetWidth(parentNode.frame) / 2, @"Nodes were not left aligned properly");
    }
}

- (void)testAlignNodeToParentVerticalCenter {
    SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    childNode.position = CGPointMake(50, 50);
    
    SKSpriteNode *parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    parentNode.position = CGPointMake(55, 50);
    [parentNode addChild:childNode];
    
    NSArray *objects = @[ childNode ];
    
    [SKNode pc_alignNodes:objects toCenterWithAlignmentType:PCAlignmentVerticalCenter];
    
    for (SKNode *node in objects) {
        XCTAssert(CGRectGetMidY(node.frame) == CGRectGetMidY(parentNode.frame), @"Nodes were not left aligned properly");
    }
}

- (void)testDistributeNodesHorizontally {
    SKSpriteNode *leftNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    leftNode.position = CGPointMake(50, 50);
    
    SKSpriteNode *firstMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    firstMiddleNode.position = CGPointMake(55, 50);
    
    SKSpriteNode *secondMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    secondMiddleNode.position = CGPointMake(60, 50);
    
    SKSpriteNode *rightNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    rightNode.position = CGPointMake(100, 50);
    
    // Deliberately unordered in order to make sure that the sorting works
    NSArray *objects = @[ rightNode, leftNode, secondMiddleNode, firstMiddleNode ];

    [SKNode pc_distributeNodesHorizontally:objects];
    
    XCTAssertEqualWithAccuracy(firstMiddleNode.position.x, 66.6667, 0.1, @"Nodes were not horizontally distributed properly.");
    XCTAssertEqualWithAccuracy(secondMiddleNode.position.x, 83.3333, 0.1, @"Nodes were not horizontally distributed properly.");
}

- (void)testDistributeNodesVertically {
    SKSpriteNode *bottomNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    bottomNode.position = CGPointMake(50, 50);
    
    SKSpriteNode *firstMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    firstMiddleNode.position = CGPointMake(50, 55);
    
    SKSpriteNode *secondMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    secondMiddleNode.position = CGPointMake(50, 60);
    
    SKSpriteNode *topNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    topNode.position = CGPointMake(50, 100);
    
    // Deliberately unordered in order to make sure that the sorting works
    NSArray *objects = @[ topNode, bottomNode, secondMiddleNode, firstMiddleNode ];

    [SKNode pc_distributeNodesVertically:objects];
    
    XCTAssertEqualWithAccuracy(firstMiddleNode.position.y, 66.6667, 0.1, @"Nodes were not vertically distributed properly.");
    XCTAssertEqualWithAccuracy(secondMiddleNode.position.y, 83.3333, 0.1, @"Nodes were not vertically distributed properly.");
}

- (void)testAlignNodesToPixels {
    SKSpriteNode *bottomNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    bottomNode.position = CGPointMake(50.1, 50.5);
    
    SKSpriteNode *firstMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    firstMiddleNode.position = CGPointMake(50.3, 55.6);
    
    SKSpriteNode *secondMiddleNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    secondMiddleNode.position = CGPointMake(50.7, 60.6);
    
    SKSpriteNode *topNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    topNode.position = CGPointMake(50.6, 100.0);
    
    // Deliberately unordered in order to make sure that the sorting works
    NSArray *objects = @[ topNode, bottomNode, secondMiddleNode, firstMiddleNode ];
    
    [SKNode pc_alignNodesToPixels:objects];
    
    for (SKSpriteNode *node in objects) {
        XCTAssert(fmod(node.position.x, 1) == 0 && fmod(node.position.y, 1) == 0, @"Nodes were not aligned to pixels properly.");
    }
}

@end
