//
//  PCObjectMatchSizeTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-07-25.
//
//

#import <SpriteKit/SpriteKit.h>
#import <XCTest/XCTest.h>
#import "PCStageScene.h"
#import "AppDelegate.h" // Only for the match size enum values
#import "SKNode+Movement.h"

@interface PCObjectMatchSizeTests : XCTestCase

@end

@implementation PCObjectMatchSizeTests

- (void)testMatchObjectWidthToParent {
    SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    SKSpriteNode *parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(500, 500)];
    [parentNode addChild:childNode];
    
    NSArray *objects = @[ childNode ];
    
    [SKNode pc_matchNodes:objects sizeWithType:PCAlignmentSameWidth];
    
    XCTAssert(childNode.size.width == parentNode.size.width, @"Node widths were not matched properly.");
}

- (void)testMatchObjectHeightToParent {
    SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    SKSpriteNode *parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(500, 500)];
    [parentNode addChild:childNode];
    
    NSArray *objects = @[ childNode ];
    
    [SKNode pc_matchNodes:objects sizeWithType:PCAlignmentSameHeight];
    
    XCTAssert(childNode.size.height == parentNode.size.height, @"Node heights were not matched properly.");
}

- (void)testMatchObjectSizeToParent {
    SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    SKSpriteNode *parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(500, 500)];
    [parentNode addChild:childNode];
    
    NSArray *objects = @[ childNode ];
    
    [SKNode pc_matchNodes:objects sizeWithType:PCAlignmentSameSize];
    
    XCTAssert(CGSizeEqualToSize(childNode.size, parentNode.size), @"Node sizes were not matched properly.");
}

- (void)testMatchObjectWidths {
    SKSpriteNode *node1 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    SKSpriteNode *node2 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(500, 500)];
    SKSpriteNode *node3 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(200, 200)];
    
    NSArray *objects = @[ node2, node1, node3 ];
    
    [SKNode pc_matchNodes:objects sizeWithType:PCAlignmentSameWidth];
    
    SKSpriteNode *firstNode = [objects firstObject];
    for (SKSpriteNode *node in objects) {
        XCTAssert(node.size.width == firstNode.size.width, @"Node widths were not matched properly.");
    }
}

- (void)testMatchObjectHeights {
    SKSpriteNode *node1 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    SKSpriteNode *node2 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(500, 500)];
    SKSpriteNode *node3 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(200, 200)];
    
    NSArray *objects = @[ node2, node1, node3 ];
    
    [SKNode pc_matchNodes:objects sizeWithType:PCAlignmentSameHeight];
    
    SKSpriteNode *firstNode = [objects firstObject];
    for (SKSpriteNode *node in objects) {
        XCTAssert(node.size.height == firstNode.size.height, @"Node heights were not matched properly.");
    }
}

- (void)testMatchObjectSizes {
    SKSpriteNode *node1 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
    SKSpriteNode *node2 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(500, 500)];
    SKSpriteNode *node3 = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(200, 200)];
    
    NSArray *objects = @[ node2, node1, node3 ];
    
    [SKNode pc_matchNodes:objects sizeWithType:PCAlignmentSameSize];
    
    SKSpriteNode *firstNode = [objects firstObject];
    for (SKSpriteNode *node in objects) {
        XCTAssert(CGSizeEqualToSize(node.size, firstNode.size), @"Node sizes were not matched properly.");
    }
}

@end
