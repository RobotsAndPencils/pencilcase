//
//  PCNodeIntegralFrameTests.m
//  SpriteBuilder
//
//  Created by Michael Beauregard on 15-04-17.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "Kiwi.h"
#import "Constants.h"
#import "SKNode+EditorResizing.h"
#import "PCStageScene.h"
#import "SKNode+CocosCompatibility.h"

@interface PCContentResizeNode : SKSpriteNode
@end
@implementation PCContentResizeNode

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}
@end

SPEC_BEGIN(PCNodeIntegralFrameTests)

    __block SKSpriteNode *rootNode;

    beforeEach(^{
        rootNode = [SKSpriteNode spriteNodeWithColor:[NSColor whiteColor] size:CGSizeMake(100, 100)];
        [[PCStageScene scene] replaceRootNodeWith:rootNode];
    });

    describe(@"With scale-resize node", ^{
        __block SKNode *node;

        beforeEach(^{
            node = [SKSpriteNode node];
            node.anchorPoint = CGPointMake(0.5, 0.5);
            node.xScale = 1;
            node.yScale = 1;
            node.position = CGPointMake(10.1, 10.1);

            [rootNode addChild:node];
        });

        describe(@"with odd content size and anchored at (0.5,0.5)", ^{
            beforeEach(^{
                node.contentSize = CGSizeMake(9, 9);
                node.anchorPoint = CGPointMake(0.5, 0.5);
            });

            it(@"frame should not be aligned", ^{
                [[theValue(node.frame.origin.x) should] equal:5.6 withDelta:0.01];
                [[theValue(node.frame.origin.y) should] equal:5.6 withDelta:0.01];
            });

            describe(@"pc_makeFrameIntegral", ^{
                beforeEach(^{
                    [node pc_makeFrameIntegral];
                });

                it(@"frame should be aligned to whole pixels", ^{
                    [[theValue(node.frame.origin.x) should] equal:6 withDelta:0.01];
                    [[theValue(node.frame.origin.y) should] equal:6 withDelta:0.01];
                });
            });
        });

        describe(@"with subpixel position anchored at (0,0)", ^{
            beforeEach(^{
                node.position = CGPointMake(9.2, 9.2);
                node.anchorPoint = CGPointMake(0, 0);
            });

            it(@"frame should not be aligned", ^{
                [[theValue(node.frame.origin.x) should] equal:9.2 withDelta:0.01];
                [[theValue(node.frame.origin.y) should] equal:9.2 withDelta:0.01];
            });

            describe(@"pc_makeFrameIntegral", ^{
                beforeEach(^{
                    [node pc_makeFrameIntegral];
                });

                it(@"frame should be aligned to whole pixels", ^{
                    [[theValue(node.frame.origin.x) should] equal:9 withDelta:0.01];
                    [[theValue(node.frame.origin.y) should] equal:9 withDelta:0.01];
                });
            });

            describe(@"has rotated inverted parent", ^{
                __block SKSpriteNode *parentNode;

                beforeEach(^{
                    [node removeFromParent];

                    parentNode = [SKSpriteNode node];
                    parentNode.anchorPoint = CGPointMake(0.5, 0.5);
                    parentNode.xScale = -1;
                    parentNode.yScale = 1;
                    parentNode.position = CGPointMake(50, 50);
                    parentNode.rotation = 90;
                    [parentNode addChild:node];

                    [rootNode addChild:parentNode];
                });

                it(@"frame should not be aligned", ^{
                    [[theValue(node.frame.origin.x) should] equal:9.2 withDelta:0.01];
                    [[theValue(node.frame.origin.y) should] equal:9.2 withDelta:0.01];
                });

                describe(@"pc_makeFrameIntegral", ^{
                    beforeEach(^{
                        [node pc_makeFrameIntegral];
                    });

                    it(@"frame should be aligned to whole pixels", ^{
                        [[theValue(node.frame.origin.x) should] equal:9 withDelta:0.01];
                        [[theValue(node.frame.origin.y) should] equal:9 withDelta:0.01];
                    });
                });
            });
        });
    });

    describe(@"With content-resize node", ^{
        __block SKNode *node;

        beforeEach(^{
            node = [PCContentResizeNode node];
            node.anchorPoint = CGPointMake(0.5, 0.5);
            node.xScale = 1;
            node.yScale = 1;
            node.position = CGPointMake(10.1, 10.1);

            [rootNode addChild:node];
        });

        describe(@"with odd content size and anchored at (0.5,0.5)", ^{
            beforeEach(^{
                node.contentSize = CGSizeMake(9, 9);
                node.anchorPoint = CGPointMake(0.5, 0.5);
            });

            it(@"frame should not be aligned", ^{
                [[theValue(node.frame.origin.x) should] equal:5.6 withDelta:0.01];
                [[theValue(node.frame.origin.y) should] equal:5.6 withDelta:0.01];
            });

            describe(@"pc_makeFrameIntegral", ^{
                beforeEach(^{
                    [node pc_makeFrameIntegral];
                });

                it(@"frame should be aligned to whole pixels", ^{
                    [[theValue(node.frame.origin.x) should] equal:6 withDelta:0.01];
                    [[theValue(node.frame.origin.y) should] equal:6 withDelta:0.01];
                });
            });
        });

        describe(@"with subpixel position anchored at (0,0)", ^{
            beforeEach(^{
                node.position = CGPointMake(9.2, 9.2);
                node.anchorPoint = CGPointMake(0, 0);
            });

            it(@"frame should not be aligned", ^{
                [[theValue(node.frame.origin.x) should] equal:9.2 withDelta:0.01];
                [[theValue(node.frame.origin.y) should] equal:9.2 withDelta:0.01];
            });

            describe(@"pc_makeFrameIntegral", ^{
                beforeEach(^{
                    [node pc_makeFrameIntegral];
                });

                it(@"frame should be aligned to whole pixels", ^{
                    [[theValue(node.frame.origin.x) should] equal:9 withDelta:0.01];
                    [[theValue(node.frame.origin.y) should] equal:9 withDelta:0.01];
                });
            });

            describe(@"has rotated inverted parent", ^{
                __block SKSpriteNode *parentNode;

                beforeEach(^{
                    [node removeFromParent];

                    parentNode = [SKSpriteNode node];
                    parentNode.anchorPoint = CGPointMake(0.5, 0.5);
                    parentNode.xScale = -1;
                    parentNode.yScale = 1;
                    parentNode.position = CGPointMake(50, 50);
                    parentNode.rotation = 90;
                    [parentNode addChild:node];

                    [rootNode addChild:parentNode];
                });

                it(@"frame should not be aligned", ^{
                    [[theValue(node.frame.origin.x) should] equal:9.2 withDelta:0.01];
                    [[theValue(node.frame.origin.y) should] equal:9.2 withDelta:0.01];
                });

                describe(@"pc_makeFrameIntegral", ^{
                    beforeEach(^{
                        [node pc_makeFrameIntegral];
                    });

                    it(@"frame should be aligned to whole pixels", ^{
                        [[theValue(node.frame.origin.x) should] equal:9 withDelta:0.01];
                        [[theValue(node.frame.origin.y) should] equal:9 withDelta:0.01];
                    });
                });
            });
        });
    });

SPEC_END





