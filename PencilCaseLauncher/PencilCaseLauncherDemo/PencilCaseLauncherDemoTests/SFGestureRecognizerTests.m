//
//  SFGestureRecognizerTests.m
//  PencilCaseLauncherDemo
//
//  Created by Stephen Gazzard on 2015-02-27.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

@import SpriteKit;

#import <Kiwi/Kiwi.h>
#import "SKNode+SFGestureRecognizers.h"

SPEC_BEGIN(SFGestureRecognizerTests)

context(@"When calculating nodes touch rect on a { 100, 100 } node", ^{
    __block SKSpriteNode *node;
    beforeEach(^{
        node = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(100, 100)];
    });

    void(^testNodeRectWithScale)(CGFloat) = ^(CGFloat scale) {
        describe([NSString stringWithFormat:@"And the node has a scale of %.0f", scale], ^{
            beforeEach(^{
                node.xScale = node.yScale = scale;
            });

            describe(@"And a { 0.5, 0.5 } anchor point", ^{
                beforeEach(^{
                    node.anchorPoint = CGPointMake(0.5f, 0.5f);
                });
                it(@"Has a touch region of { -50, -50, 100, 100 }",^{
                    [[theValue(node.sf_touchRect) should] equal:theValue(CGRectMake(-50, -50, 100, 100))];
                });
            });
            describe(@"And a { 1, 1 } anchor point", ^{
                beforeEach(^{
                    node.anchorPoint = CGPointMake(1, 1);
                });
                it(@"Has a touch region of { -100, -100, 100, 100 }",^{
                    [[theValue(node.sf_touchRect) should] equal:theValue(CGRectMake(-100, -100, 100, 100))];
                });
            });
            describe(@"And a { 0, 0 } anchor point", ^{
                beforeEach(^{
                    node.anchorPoint = CGPointMake(0, 0);
                });
                it(@"Has a touch region of { 0, 0, 100, 100 }",^{
                    //Actual result yields -0, -0 for position, which is fine, but this is the only way to test it.
                    CGRect touchRect = node.sf_touchRect;
                    [[theValue(touchRect.origin.x) should] equal:0 withDelta:0.01];
                    [[theValue(touchRect.origin.y) should] equal:0 withDelta:0.01];
                    [[theValue(touchRect.size.width) should] equal:100 withDelta:0.01];
                    [[theValue(touchRect.size.height) should] equal:100 withDelta:0.01];
                });
            });
            describe(@"And a { -1, -1 } anchorPoint", ^{
                beforeEach(^{
                    node.anchorPoint = CGPointMake(-1, -1);
                });
                it(@"Has a touch region of { 100, 100, 100, 100 }",^{
                    [[theValue(node.sf_touchRect) should] equal:theValue(CGRectMake(100, 100, 100, 100))];
                });
            });
            describe(@"And a { 2, 2 } anchorPoint", ^{
                beforeEach(^{
                    node.anchorPoint = CGPointMake(2, 2);
                });
                it(@"Has a touch region of { -200, -200, 100, 100 }",^{
                    [[theValue(node.sf_touchRect) should] equal:theValue(CGRectMake(-200, -200, 100, 100))];
                });
            });
        });
    };

    testNodeRectWithScale(1);
    testNodeRectWithScale(-1);
    testNodeRectWithScale(2);
    testNodeRectWithScale(-2);
    testNodeRectWithScale(0.0001);

    describe(@"And the node has a scale of 0", ^{
        beforeEach(^{
            node.yScale = node.xScale = 0;
        });
        it(@"Has a touch region of { 0, 0, 0, 0 }",^{
            //Actual result yields -0, -0 for position, which is fine, but this is the only way to test it.
            CGRect touchRect = node.sf_touchRect;
            [[theValue(touchRect.origin.x) should] equal:0 withDelta:0.01];
            [[theValue(touchRect.origin.y) should] equal:0 withDelta:0.01];
            [[theValue(touchRect.size.width) should] equal:0 withDelta:0.01];
            [[theValue(touchRect.size.height) should] equal:0 withDelta:0.01];
        });
    });
});

SPEC_END
