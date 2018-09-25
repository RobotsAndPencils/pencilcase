//
//  PCNodeSnappingTests.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-12-01.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>

#import "PCStageScene.h"
#import "PCSnapFrame.h"
#import "SKNode+EditorResizing.h"

@interface PCNodeSnappingTests : XCTestCase

@end

SPEC_BEGIN(SnapSpec)

describe(@"Snapping Nodes", ^{
    __block PCSnapFrame *topFrame, *bottomFrame, *rightFrame, *leftFrame, *onFrame;
    __block SKSpriteNode *rotatednode, *parentNode, *defaultNode, *midAnchorNode, *topRightAnchorNode;
    __block PCSnapFrame *snapFrame;
    __block PCSnapFrame *rotatedSnapFrame;
    
    beforeEach(^{
        leftFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(-104, 0, 100, 100)];
        rightFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(104, 0, 100, 100)];
        topFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(0, 104, 100, 100)];
        bottomFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(0, -104, 100, 100)];
        snapFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        onFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        
        parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        parentNode.anchorPoint = CGPointMake(0, 0);
        parentNode.position = CGPointMake(0, 0);
        
        rotatednode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        rotatednode.anchorPoint = CGPointMake(0, 0);
        rotatednode.position = CGPointMake(0, 0);
        rotatednode.zRotation = 45;
        
        defaultNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        defaultNode.anchorPoint = CGPointMake(0, 0);

        midAnchorNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        midAnchorNode.position = CGPointMake(50, 50);
        midAnchorNode.anchorPoint = CGPointMake(0.5, 0.5);

        topRightAnchorNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        topRightAnchorNode.position = CGPointMake(100, 100);
        topRightAnchorNode.anchorPoint = CGPointMake(1, 1);

        SKSpriteNode *rootNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(200, 200)];
        [rootNode addChild:parentNode];
        [rootNode addChild:defaultNode];
        [rootNode addChild:midAnchorNode];
        [rootNode addChild:topRightAnchorNode];

        [[PCStageScene scene] replaceRootNodeWith:rootNode];
    });
    
    context(@"When snapping top to bottom", ^{
        beforeAll(^{
            [snapFrame snapNodeToFrame:topFrame withHandle:PCTransformEdgeHandleNone];
        });
    
        it(@"snap frame top should be top frame bottom", ^{
            [[theValue(snapFrame.top) should] equal:topFrame.bottom withDelta:0.001];
        });
    });
    
    
    context(@"When snapping bottom to top", ^{
        beforeAll(^{
            [snapFrame snapNodeToFrame:bottomFrame withHandle:PCTransformEdgeHandleNone];
        });
        
        it(@"snap frame top should be top frame bottom", ^{
            [[theValue(snapFrame.bottom) should] equal:bottomFrame.top withDelta:0.001];
        });
    });
    
    context(@"When snapping right to left", ^{
        beforeAll(^{
            [snapFrame snapNodeToFrame:rightFrame withHandle:PCTransformEdgeHandleNone];
        });
        
        it(@"snap frame top should be top frame bottom", ^{
            [[theValue(snapFrame.right) should] equal:rightFrame.left withDelta:0.001];
        });
    });

    context(@"When snapping left to right", ^{
        beforeAll(^{
            [snapFrame snapNodeToFrame:leftFrame withHandle:PCTransformEdgeHandleNone];
        });
        
        it(@"snap frame top should be top frame bottom", ^{
            [[theValue(snapFrame.left) should] equal:leftFrame.right withDelta:0.001];
        });
    });
    
    context(@"When snapping top to top", ^{
        beforeAll(^{
            onFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(0, 4, 100, 100)];
            [snapFrame snapNodeToFrame:onFrame withHandle:PCTransformEdgeHandleNone];
        });
        
        it(@"snap frame top should be top of the on frame", ^{
            [[theValue(snapFrame.top) should] equal:onFrame.top withDelta:0.001];
        });
    });
    
    context(@"When snapping bottom to bottom", ^{
        beforeAll(^{
            onFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(0, -4, 100, 100)];
            [snapFrame snapNodeToFrame:onFrame withHandle:PCTransformEdgeHandleNone];
        });
        
        it(@"snap frame bottom should be bottom of the on frame", ^{
            [[theValue(snapFrame.bottom) should] equal:onFrame.bottom withDelta:0.001];
        });
    });
    
    context(@"When snapping right to right", ^{
        beforeAll(^{
            onFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(4, 0, 100, 100)];
            [snapFrame snapNodeToFrame:onFrame withHandle:PCTransformEdgeHandleNone];
        });
        
        it(@"snap frame right should be right of the on frame", ^{
            [[theValue(snapFrame.right) should] equal:onFrame.right withDelta:0.001];
        });
    });
    
    context(@"When snapping left to left", ^{
        beforeAll(^{
            onFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(-4, 0, 100, 100)];
            [snapFrame snapNodeToFrame:onFrame withHandle:PCTransformEdgeHandleNone];
        });
        
        it(@"snap frame left should be left of the on frame", ^{
            [[theValue(snapFrame.left) should] equal:onFrame.left withDelta:0.001];
        });
    });
    
    context(@"When snapping center to center", ^{
        beforeAll(^{
            [snapFrame snapNodeToFrame:onFrame withHandle:PCTransformEdgeHandleNone];
        });
        
        it(@"snap frame center should be center of the on frame", ^{
            [[theValue(snapFrame.centerX) should] equal:onFrame.centerX withDelta:0.001];
            [[theValue(snapFrame.centerY) should] equal:onFrame.centerY withDelta:0.001];
        });
    });

    context(@"When snapping outside of the threshold", ^{
        beforeAll(^{
            rightFrame = [[PCSnapFrame alloc] initWithFrame:CGRectMake(105, 0, 100, 100)];
            [snapFrame snapNodeToFrame:rightFrame withHandle:PCTransformEdgeHandleNone];
        });

        it(@"the snap frame should remain unchanged ", ^{
            [[theValue(snapFrame.right) should] equal:100 withDelta:0.001];
        });
    });

    context(@"When creating min bounds for a rotated node", ^{
        beforeAll(^{
            [parentNode addChild:rotatednode];
            rotatedSnapFrame = [[PCSnapFrame alloc] initWithNode:rotatednode];
        });

        it(@"the size of the frame should be correct", ^{
            [[theValue(rotatedSnapFrame.frame.size.width) should] equal:137.6 withDelta:0.1];
        });
    });
    
    context(@"When snapping Right Edge to Left Edge", ^{
        beforeAll(^{
            snapFrame.node = defaultNode;
            [snapFrame snapEdgesToFrame:rightFrame withHandle:PCTransformEdgeHandleRight lockAspectRatio:NO];
        });
        
        it(@"snap frame width should be larger", ^{
            [[theValue(snapFrame.node.xScale) should] equal:1.04 withDelta:0.001];
        });
    });
    
    context(@"When snapping Left Edge to Right Edge", ^{
        beforeAll(^{
            snapFrame.node = defaultNode;
            [snapFrame snapEdgesToFrame:leftFrame withHandle:PCTransformEdgeHandleLeft lockAspectRatio:NO];
        });
        
        it(@"snap frame width should be larger", ^{
            [[theValue(snapFrame.node.xScale) should] equal:1.04 withDelta:0.001];
        });
    });
    
    context(@"When snapping Top Edge to Bottom Edge", ^{
        beforeAll(^{
            snapFrame.node = defaultNode;
            [snapFrame snapEdgesToFrame:topFrame withHandle:PCTransformEdgeHandleTop lockAspectRatio:NO];
        });
        
        it(@"snap frame height should be larger", ^{
            [[theValue(snapFrame.node.yScale) should] equal:1.04 withDelta:0.001];
        });
    });
    
    context(@"When snapping Bottom Edge to Top Edge", ^{
        beforeAll(^{
            snapFrame.node = defaultNode;
            [snapFrame snapEdgesToFrame:bottomFrame withHandle:PCTransformEdgeHandleBottom lockAspectRatio:NO];
        });
        
        it(@"snap frame height should be larger", ^{
            [[theValue(snapFrame.node.yScale) should] equal:1.04 withDelta:0.001];
        });
    });
    
    context(@"When snapping Right Edge to Left Edge With A Mid Anchor Point", ^{
        beforeAll(^{
            snapFrame.node = midAnchorNode;
            [snapFrame snapEdgesToFrame:leftFrame withHandle:PCTransformEdgeHandleLeft lockAspectRatio:NO];
        });
        
        it(@"snap frame width should be larger", ^{
            [[theValue(snapFrame.node.xScale) should] equal:1.04 withDelta:0.001];
        });
    });
    
    context(@"When snapping Top Edge to Bottom Edge With A Mid Anchor Point", ^{
        beforeAll(^{
            snapFrame.node = midAnchorNode;
            [snapFrame snapEdgesToFrame:topFrame withHandle:PCTransformEdgeHandleTop lockAspectRatio:NO];
        });
        
        it(@"snap frame height should be larger", ^{
            [[theValue(snapFrame.node.yScale) should] equal:1.04 withDelta:0.001];
        });
    });
    
    context(@"When snapping Right Edge to Left Edge With A TopRight Anchor Point", ^{
        beforeAll(^{
            snapFrame.node = topRightAnchorNode;
            [snapFrame snapEdgesToFrame:leftFrame withHandle:PCTransformEdgeHandleLeft lockAspectRatio:NO];
        });
        
        it(@"snap frame width should be larger", ^{
            [[theValue(snapFrame.node.xScale) should] equal:1.04 withDelta:0.001];
        });
    });
    
    context(@"When snapping Top Edge to Bottom Edge With A TopRight Anchor Point", ^{
        beforeAll(^{
            snapFrame.node = topRightAnchorNode;
            [snapFrame snapEdgesToFrame:topFrame withHandle:PCTransformEdgeHandleTop lockAspectRatio:NO];
        });
        
        it(@"snap frame height should be larger", ^{
            [[theValue(snapFrame.node.yScale) should] equal:1.04 withDelta:0.001];
        });
    });
});

SPEC_END
