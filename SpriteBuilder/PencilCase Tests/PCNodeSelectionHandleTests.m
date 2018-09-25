//
//  PCNodeSelectionHandleTests.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-09.
//
//

#import <Kiwi/Kiwi.h>
#import "SKNode+Selection.h"
#import "SKNode+CocosCompatibility.h"

@interface SKNode(SelectionTests)

- (void)calculateLocalCornerPointsFromAnchorPoint:(CGPoint *)points;

@end

SPEC_BEGIN(PCNodeSelectionHandleTests)

describe(@"When calculating local space selection handles", ^{
    __block SKSpriteNode *node;
    beforeEach(^{
        node = [SKSpriteNode node];
    });

    context(@"And the node has a positive scale", ^{
        beforeEach(^{
            node.xScale = 1;
            node.yScale = 2;
        });

        context(@"With the default anchor point {0.5, 0.5}", ^{
            __block CGPoint *corners;
            beforeEach(^{
                node.anchorPoint = CGPointMake(0.5, 0.5);
                corners = malloc(8 * sizeof(CGPoint)); //can't access arrays in a block, hurray!
                [node calculateLocalCornerPointsFromAnchorPoint:corners];
            });

            afterEach(^{
                free(corners);
            });

            it(@"Has a top left corner of {-0.5, 0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopLeft].x) should] equal:-0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopLeft].y) should] equal:0.5 withDelta:0.01];
            });
            it(@"Has a top right corner of {0.5, 0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopRight].x) should] equal:0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopRight].y) should] equal:0.5 withDelta:0.01];
            });
            it(@"Has a bottom left corner of {-0.5, -0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].x) should] equal:-0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].y) should] equal:-0.5 withDelta:0.01];
            });
            it(@"Has a bottom right corner of {0.5, -0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomRight].x) should] equal:0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomRight].y) should] equal:-0.5 withDelta:0.01];
            });

            it(@"Has a left edge of {-0.5, 0}", ^{
                [[theValue(corners[PCTransformEdgeHandleLeft].x) should] equal:-0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleLeft].y) should] equal:0 withDelta:0.01];
            });
            it(@"Has a right edge of {0.5, 0}", ^{
                [[theValue(corners[PCTransformEdgeHandleRight].x) should] equal:0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleRight].y) should] equal:0 withDelta:0.01];
            });
            it(@"Has a top edge of {0, 0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTop].x) should] equal:0 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTop].y) should] equal:0.5 withDelta:0.01];
            });
            it(@"Has a bottom edge of {0, -0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottom].x) should] equal:0 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottom].y) should] equal:-0.5 withDelta:0.01];
            });
        });

        context(@"With an unusual positive anchor point {0.7, 0.3}", ^{
            __block CGPoint *corners;
            beforeEach(^{
                node.anchorPoint = CGPointMake(0.7, 0.3);
                corners = malloc(8 * sizeof(CGPoint));
                [node calculateLocalCornerPointsFromAnchorPoint:corners];
            });

            afterEach(^{
                free(corners);
            });

            it(@"Has a top left corner of {-0.7, 0.7}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopLeft].x) should] equal:-0.7 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopLeft].y) should] equal:0.7 withDelta:0.01];
            });
            it(@"Has a top right corner of {0.3, 0.7}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopRight].x) should] equal:0.3 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopRight].y) should] equal:0.7 withDelta:0.01];
            });
            it(@"Has a bottom left corner of {-0.7, -0.3}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].x) should] equal:-0.7 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].y) should] equal:-0.3 withDelta:0.01];

            });
            it(@"Has a bottom right corner of {0.3, -0.3}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomRight].x) should] equal:0.3 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomRight].y) should] equal:-0.3 withDelta:0.01];
            });

            it(@"Has a left edge of {-0.7, 0.2}", ^{
                [[theValue(corners[PCTransformEdgeHandleLeft].x) should] equal:-0.7 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleLeft].y) should] equal:0.2 withDelta:0.01];
            });
            it(@"Has a right edge of {0.3, 0.2}", ^{
                [[theValue(corners[PCTransformEdgeHandleRight].x) should] equal:0.3 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleRight].y) should] equal:0.2 withDelta:0.01];
            });
            it(@"Has a top edge of {-0.2, 0.7}", ^{
                [[theValue(corners[PCTransformEdgeHandleTop].x) should] equal:-0.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTop].y) should] equal:0.7 withDelta:0.01];
            });
            it(@"Has a bottom edge of {-0.2, -0.3}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottom].x) should] equal:-0.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottom].y) should] equal:-0.3 withDelta:0.01];
            });
        });

        context(@"With a negative anchor point {-0.4, -1}", ^{
            __block CGPoint *corners;
            beforeEach(^{
                node.anchorPoint = CGPointMake(-0.4, -1);
                corners = malloc(8 * sizeof(CGPoint));
                [node calculateLocalCornerPointsFromAnchorPoint:corners];
            });

            afterEach(^{
                free(corners);
            });

            it(@"Has a top left corner of {0.4, 2}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopLeft].x) should] equal:0.4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopLeft].y) should] equal:2 withDelta:0.01];
            });
            it(@"Has a top right corner of {1.4, 2}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopRight].x) should] equal:1.4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopRight].y) should] equal:2 withDelta:0.01];
            });
            it(@"Has a bottom left corner of {0.4, 1}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].x) should] equal:0.4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].y) should] equal:1 withDelta:0.01];
            });
            it(@"Has a bottom right corner of {1.4, 1}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomRight].x) should] equal:1.4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomRight].y) should] equal:1 withDelta:0.01];
            });

            it(@"Has a left edge of {0.4, 1.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleLeft].x) should] equal:0.4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleLeft].y) should] equal:1.5 withDelta:0.01];
            });
            it(@"Has a right edge of {1.4, 1.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleRight].x) should] equal:1.4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleRight].y) should] equal:1.5 withDelta:0.01];
            });
            it(@"Has a top edge of {0.9, 2}", ^{
                [[theValue(corners[PCTransformEdgeHandleTop].x) should] equal:0.9 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTop].y) should] equal:2 withDelta:0.01];
            });
            it(@"Has a bottom edge of {0.9, 1}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottom].x) should] equal:0.9 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottom].y) should] equal:1 withDelta:0.01];
            });
        });

        context(@"With an oversized anchorPoint {5, 5}", ^{
            __block CGPoint *corners;
            beforeEach(^{
                node.anchorPoint = CGPointMake(5, 5);
                corners = malloc(8 * sizeof(CGPoint));
                [node calculateLocalCornerPointsFromAnchorPoint:corners];
            });

            afterEach(^{
                free(corners);
            });

            it(@"Has a top left corner of {-5, -4}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopLeft].x) should] equal:-5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopLeft].y) should] equal:-4 withDelta:0.01];
            });
            it(@"Has a top right corner of {-4, -4}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopRight].x) should] equal:-4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopRight].y) should] equal:-4 withDelta:0.01];
            });
            it(@"Has a bottom left corner of {-5, -5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].x) should] equal:-5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].y) should] equal:-5 withDelta:0.01];
            });
            it(@"Has a bottom right corner of {-4, -5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomRight].x) should] equal:-4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomRight].y) should] equal:-5 withDelta:0.01];
            });

            it(@"Has a left edge of {-5, -4.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleLeft].x) should] equal:-5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleLeft].y) should] equal:-4.5 withDelta:0.01];
            });
            it(@"Has a right edge of {-4, -4.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleRight].x) should] equal:-4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleRight].y) should] equal:-4.5 withDelta:0.01];
            });
            it(@"Has a top edge of {-4.5, -4}", ^{
                [[theValue(corners[PCTransformEdgeHandleTop].x) should] equal:-4.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTop].y) should] equal:-4 withDelta:0.01];
            });
            it(@"Has a bottom edge of {-4.5, -5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottom].x) should] equal:-4.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottom].y) should] equal:-5 withDelta:0.01];
            });
        });
    });

    context(@"And the node has a negative scale", ^{
        beforeEach(^{
            node.xScale = -1;
            node.yScale = -1;
        });

        context(@"With the standard anchor point {0.5, 0.5}", ^{
            __block CGPoint *corners;
            beforeEach(^{
                node.anchorPoint = CGPointMake(0.5, 0.5);
                corners = malloc(8 * sizeof(CGPoint)); //can't access arrays in a block, hurray!
                [node calculateLocalCornerPointsFromAnchorPoint:corners];
            });

            afterEach(^{
                free(corners);
            });

            it(@"Has a top left corner of {-0.5, 0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopLeft].x) should] equal:-0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopLeft].y) should] equal:0.5 withDelta:0.01];
            });
            it(@"Has a top right corner of {0.5, 0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopRight].x) should] equal:0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopRight].y) should] equal:0.5 withDelta:0.01];
            });
            it(@"Has a bottom left corner of {-0.5, -0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].x) should] equal:-0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].y) should] equal:-0.5 withDelta:0.01];
            });
            it(@"Has a bottom right corner of {0.5, -0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomRight].x) should] equal:0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomRight].y) should] equal:-0.5 withDelta:0.01];
            });

            it(@"Has a left edge of {-0.5, 0}", ^{
                [[theValue(corners[PCTransformEdgeHandleLeft].x) should] equal:-0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleLeft].y) should] equal:0 withDelta:0.01];
            });
            it(@"Has a right edge of {0.5, 0}", ^{
                [[theValue(corners[PCTransformEdgeHandleRight].x) should] equal:0.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleRight].y) should] equal:0 withDelta:0.01];
            });
            it(@"Has a top edge of {0, 0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTop].x) should] equal:0 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTop].y) should] equal:0.5 withDelta:0.01];
            });
            it(@"Has a bottom edge of {0, -0.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottom].x) should] equal:0 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottom].y) should] equal:-0.5 withDelta:0.01];
            });
        });

        context(@"With an unusual anchor point {0.7, 0.3}", ^{
            __block CGPoint *corners;
            beforeEach(^{
                node.anchorPoint = CGPointMake(0.7, 0.3);
                corners = malloc(8 * sizeof(CGPoint)); //can't access arrays in a block, hurray!
                [node calculateLocalCornerPointsFromAnchorPoint:corners];
            });

            afterEach(^{
                free(corners);
            });

            it(@"Has a top left corner of {-0.3, 0.3}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopLeft].x) should] equal:-0.3 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopLeft].y) should] equal:0.3 withDelta:0.01];
            });
            it(@"Has a top right corner of {0.7, 0.3}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopRight].x) should] equal:0.7 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopRight].y) should] equal:0.3 withDelta:0.01];
            });
            it(@"Has a bottom left corner of {-0.3, -0.7}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].x) should] equal:-0.3 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].y) should] equal:-0.7 withDelta:0.01];
            });
            it(@"Has a bottom right corner of {0.7, -0.7}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomRight].x) should] equal:0.7 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomRight].y) should] equal:-0.7 withDelta:0.01];
            });

            it(@"Has a left edge of {-0.3, -0.2}", ^{
                [[theValue(corners[PCTransformEdgeHandleLeft].x) should] equal:-0.3 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleLeft].y) should] equal:-0.2 withDelta:0.01];
            });
            it(@"Has a right edge of {0.7, -0.2}", ^{
                [[theValue(corners[PCTransformEdgeHandleRight].x) should] equal:0.7 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleRight].y) should] equal:-0.2 withDelta:0.01];
            });
            it(@"Has a top edge of {0.2, 0.3}", ^{
                [[theValue(corners[PCTransformEdgeHandleTop].x) should] equal:0.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTop].y) should] equal:0.3 withDelta:0.01];
            });
            it(@"Has a bottom edge of {0.2, -0.7}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottom].x) should] equal:0.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottom].y) should] equal:-0.7 withDelta:0.01];
            });
        });

        context(@"With a negative anchor point {-0.2, -1}", ^{
            __block CGPoint *corners;
            beforeEach(^{
                node.anchorPoint = CGPointMake(-0.2, -1);
                corners = malloc(8 * sizeof(CGPoint)); //can't access arrays in a block, hurray!
                [node calculateLocalCornerPointsFromAnchorPoint:corners];
            });

            afterEach(^{
                free(corners);
            });

            it(@"Has a top left corner of {-1.2, -1}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopLeft].x) should] equal:-1.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopLeft].y) should] equal:-1 withDelta:0.01];
            });
            it(@"Has a top right corner of {-0.2, -1}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopRight].x) should] equal:-0.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopRight].y) should] equal:-1 withDelta:0.01];
            });
            it(@"Has a bottom left corner of {-1.2, -2}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].x) should] equal:-1.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].y) should] equal:-2 withDelta:0.01];
            });
            it(@"Has a bottom right corner of {-0.2, -2}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomRight].x) should] equal:-0.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomRight].y) should] equal:-2 withDelta:0.01];
            });

            it(@"Has a left edge of {-1.2, -1.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleLeft].x) should] equal:-1.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleLeft].y) should] equal:-1.5 withDelta:0.01];
            });
            it(@"Has a right edge of {-0.2, -1.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleRight].x) should] equal:-0.2 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleRight].y) should] equal:-1.5 withDelta:0.01];
            });
            it(@"Has a top edge of {-0.7, -1}", ^{
                [[theValue(corners[PCTransformEdgeHandleTop].x) should] equal:-0.7 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTop].y) should] equal:-1 withDelta:0.01];
            });
            it(@"Has a bottom edge of {-0.7, -2}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottom].x) should] equal:-0.7 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottom].y) should] equal:-2 withDelta:0.01];
            });
        });

        context(@"With an unusually large anchor point {5, 5}", ^{
            __block CGPoint *corners;
            beforeEach(^{
                node.anchorPoint = CGPointMake(5, 5);
                corners = malloc(8 * sizeof(CGPoint)); //can't access arrays in a block, hurray!
                [node calculateLocalCornerPointsFromAnchorPoint:corners];
            });

            afterEach(^{
                free(corners);
            });

            it(@"Has a top left corner of {4, 5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopLeft].x) should] equal:4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopLeft].y) should] equal:5 withDelta:0.01];
            });
            it(@"Has a top right corner of {5, 5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTopRight].x) should] equal:5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTopRight].y) should] equal:5 withDelta:0.01];
            });
            it(@"Has a bottom left corner of {4, 4}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].x) should] equal:4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomLeft].y) should] equal:4 withDelta:0.01];
            });
            it(@"Has a bottom right corner of {5, 4}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottomRight].x) should] equal:5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottomRight].y) should] equal:4 withDelta:0.01];
            });

            it(@"Has a left edge of {4, 4.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleLeft].x) should] equal:4 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleLeft].y) should] equal:4.5 withDelta:0.01];
            });
            it(@"Has a right edge of {5, 4.5}", ^{
                [[theValue(corners[PCTransformEdgeHandleRight].x) should] equal:5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleRight].y) should] equal:4.5 withDelta:0.01];
            });
            it(@"Has a top edge of {4.5, 5}", ^{
                [[theValue(corners[PCTransformEdgeHandleTop].x) should] equal:4.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleTop].y) should] equal:5 withDelta:0.01];
            });
            it(@"Has a bottom edge of {4.5, 4}", ^{
                [[theValue(corners[PCTransformEdgeHandleBottom].x) should] equal:4.5 withDelta:0.01];
                [[theValue(corners[PCTransformEdgeHandleBottom].y) should] equal:4 withDelta:0.01];
            });
        });
    });
});

SPEC_END
