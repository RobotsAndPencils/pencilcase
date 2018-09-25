//
//  PCNodeAnchorPointTests.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-03-06.
//
//

#import <Kiwi/Kiwi.h>
#import "SKNode+AnchorPoint.h"

SPEC_BEGIN(PCNodeAnchorPointTests)

context(@"When setting the anchor point on a { 100, 100 } node at { 50, 50 } with anchor point { 0.5, 0.5 }", ^{
    __block SKSpriteNode *node;
    __block SKSpriteNode *parentNode;
    beforeEach(^{
        node = [SKSpriteNode spriteNodeWithColor:[NSColor blueColor] size:CGSizeMake(100, 100)];
        node.position = CGPointMake(50, 50);
        node.anchorPoint = CGPointMake(0.5, 0.5);
        //Must be added as a parent for positionAgnosticAnchorPoint to calculate a new position
        parentNode = [SKSpriteNode spriteNodeWithColor:[NSColor redColor] size:CGSizeMake(200, 200)];
        [parentNode addChild:node];
    });
    context(@"With a positive scale", ^{
        beforeEach(^{
            node.xScale = node.yScale = 1;
        });

        context(@"To { 0, 0 }", ^{
            beforeEach(^{
                node.positionAgnosticAnchorPoint = CGPointMake(0, 0);
            });
            it(@"Has a position of { 0, 0 }", ^{
                [[theValue(node.position) should] equal:theValue(CGPointMake(0, 0))];
            });
        });
        context(@"to { 1, 1 }", ^{
            beforeEach(^{
                node.positionAgnosticAnchorPoint = CGPointMake(1, 1);
            });
            it(@"has a position of { 100, 100 }", ^{
                [[theValue(node.position) should] equal:theValue(CGPointMake(100, 100))];
            });
        });
        context(@"to { 0.3, 0.7 }", ^{
            beforeEach(^{
                node.positionAgnosticAnchorPoint = CGPointMake(0.3, 0.7);
            });
            it(@"has a position of { 30, 70 }", ^{
                [[theValue(node.position) should] equal:theValue(CGPointMake(30, 70))];
            });
        });
        context(@"to { -1, -1 }", ^{
            beforeEach(^{
                node.positionAgnosticAnchorPoint = CGPointMake(-1, -1);
            });
            it(@"has a position of { -100, -100 }", ^{
                [[theValue(node.position) should] equal:theValue(CGPointMake(-100, -100))];
            });
        });
    });

    context(@"With a negative scale", ^{
        beforeEach(^{
            node.xScale = node.yScale = -1;
        });
        context(@"To { 0, 0 }", ^{
            beforeEach(^{
                node.positionAgnosticAnchorPoint = CGPointMake(0, 0);
            });
            it(@"Has a position of { 100, 100 }", ^{
                [[theValue(node.position) should] equal:theValue(CGPointMake(100, 100))];
            });
        });
        context(@"to { 1, 1 }", ^{
            beforeEach(^{
                node.positionAgnosticAnchorPoint = CGPointMake(1, 1);
            });
            it(@"has a position of { 0, 0 }", ^{
                [[theValue(node.position) should] equal:theValue(CGPointMake(0, 0))];
            });
        });
        context(@"to { 0.3, 0.7 }", ^{
            beforeEach(^{
                node.positionAgnosticAnchorPoint = CGPointMake(0.3, 0.7);
            });
            it(@"has a position of { 70, 30 }", ^{
                [[theValue(node.position) should] equal:theValue(CGPointMake(70, 30))];
            });
        });
        context(@"to { -1, -1 }", ^{
            beforeEach(^{
                node.positionAgnosticAnchorPoint = CGPointMake(-1, -1);
            });
            it(@"has a position of { 200, 200 }", ^{
                [[theValue(node.position) should] equal:theValue(CGPointMake(200, 200))];
            });
        });
    });
});

SPEC_END
