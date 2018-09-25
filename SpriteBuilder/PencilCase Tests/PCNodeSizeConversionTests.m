//
//  PCNodeSizeConversionTests.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

#import <Kiwi/Kiwi.h>
#import "SKNode+CoordinateConversion.h"

SPEC_BEGIN(PCNodeSizeConversionTests)

context(@"When converting the size {100, 100} from a node with scale {2, 4}", ^{
    __block SKScene *scene;
    __block SKNode *node;
    __block SKNode *parentNode;
    __block CGSize size;
    beforeEach(^{
        scene = [[SKScene alloc] init];

        parentNode = [SKNode node];
        [scene addChild:parentNode];

        node = [SKNode node];
        node.xScale = 2;
        node.yScale = 4;
        [parentNode addChild:node];

        size = CGSizeMake(100, 100);
    });

    context(@"To a node above it in the node tree", ^{
        it(@"Should return a size of {200, 400}", ^{
            [[theValue([node pc_convertSize:size toNode:parentNode]) should] equal:theValue(CGSizeMake(200, 400))];
        });
    });

    context(@"To a node below it in the node tree with scale {5, 5}", ^{
        __block SKNode *childNode;
        beforeEach(^{
            childNode = [SKNode node];
            childNode.xScale = 5;
            childNode.yScale = 5;
            [node addChild:childNode];
        });

        it(@"Should return a size of {20, 20}", ^{
            [[theValue([node pc_convertSize:size toNode:childNode]) should] equal:theValue(CGSizeMake(20, 20))];
        });
    });

    context(@"To a sibling node with a scale of {4, 8}", ^{
        __block SKNode *siblingNode;
        beforeEach(^{
            siblingNode = [SKNode node];
            siblingNode.xScale = 4;
            siblingNode.yScale = 8;
            [parentNode addChild:siblingNode];
        });

        it(@"Should return a size of {50, 50}", ^{
            [[theValue([node pc_convertSize:size toNode:siblingNode]) should] equal:theValue(CGSizeMake(50, 50))];
        });
    });
});

SPEC_END
