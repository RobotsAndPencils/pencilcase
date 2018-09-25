//
//  NodeHandleDraggingTests.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-11-21.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCStageScene.h"
#import "SKNode+EditorResizing.h"
#import "SKNode+NodeInfo.h"
#import "NodeInfo.h"

@interface SKNode(PCNodeHandleDraggingTestsPrivate)

+ (BOOL)pc_shouldTreatCornerAsOppositeWithScale:(CGFloat)scale initialScale:(CGFloat)initialScale resizeBehaviour:(PCEditorResizeBehaviour)resizeBehaviour;
+ (CGFloat)pc_staticPositionSuchThatCornerOpposite:(BOOL)lesserCorner /*Left or bottom*/ doesNotMoveFromPosition:(CGFloat)position size:(CGFloat)size anchorPoint:(CGFloat)anchorPoint flipped:(BOOL)flipped;
+ (CGFloat)pc_positionSuchThatCornerOpposite:(BOOL)lesserCorner /*Left or bottom*/ doesNotMoveFromStaticPosition:(CGFloat)position size:(CGFloat)size anchorPoint:(CGFloat)anchorPoint flipped:(BOOL)flipped;

@end

SPEC_BEGIN(PCNodeHandleDraggingTests)

describe(@"When calculating if the node should treat the handle as the opposite handle", ^{
    it(@"should return NO if the node resizes by content size and has a positive scale", ^{
        [[theValue([SKNode pc_shouldTreatCornerAsOppositeWithScale:1 initialScale:1 resizeBehaviour:PCEditorResizeBehaviourContentSize]) should] equal:theValue(NO)];
    });
    it(@"should return YES if the node resizes by content size and has a negative scale", ^{
        [[theValue([SKNode pc_shouldTreatCornerAsOppositeWithScale:-1 initialScale:1 resizeBehaviour:PCEditorResizeBehaviourContentSize]) should] equal:theValue(YES)];
    });
    it(@"should return NO if the node is positive and hasn't flipped", ^{
        [[theValue([SKNode pc_shouldTreatCornerAsOppositeWithScale:1 initialScale:1 resizeBehaviour:PCEditorResizeBehaviourScale]) should] equal:theValue(NO)];
    });
    it(@"should return NO if the node has flipped from positive to negative", ^{
        [[theValue([SKNode pc_shouldTreatCornerAsOppositeWithScale:-1 initialScale:1 resizeBehaviour:PCEditorResizeBehaviourScale]) should] equal:theValue(NO)];
    });
    it(@"should return YES if the node is in negative and hasn't flipped", ^{
        [[theValue([SKNode pc_shouldTreatCornerAsOppositeWithScale:-1 initialScale:-1 resizeBehaviour:PCEditorResizeBehaviourScale]) should] equal:theValue(YES)];
    });
    it(@"should return YES if the node has flipped from negative to positive", ^{
        [[theValue([SKNode pc_shouldTreatCornerAsOppositeWithScale:1 initialScale:-1 resizeBehaviour:PCEditorResizeBehaviourScale]) should] equal:theValue(YES)];
    });
});

context(@"When calculating the static point from a node with size 100, position 50", ^{
    __block CGFloat size;
    __block CGFloat position;
    beforeAll(^{
        size = 100;
        position = 50;
    });

    void (^testStaticPointWithAnchorPoint)(CGFloat, CGFloat, CGFloat) = ^(CGFloat anchorPoint, CGFloat lesser, CGFloat greater) {
        context([NSString stringWithFormat:@"anchorPoint is %.1f", anchorPoint], ^{
            it([NSString stringWithFormat:@"should return %.0f when lesserHandle is yes, flipped is NO", lesser],  ^{
                CGFloat value = [SKNode pc_staticPositionSuchThatCornerOpposite:YES doesNotMoveFromPosition:position size:size anchorPoint:anchorPoint flipped:NO];
                [[theValue(value) should] equal:lesser withDelta:0.01];;
            });

            it([NSString stringWithFormat:@"Should return %.0f when lesserHandle is NO, flipped is NO", greater], ^{
                CGFloat value = [SKNode pc_staticPositionSuchThatCornerOpposite:NO doesNotMoveFromPosition:position size:size anchorPoint:anchorPoint flipped:NO];
                [[theValue(value) should] equal:greater withDelta:0.01];
            });

            it([NSString stringWithFormat:@"Should return %.0f when lesserHandle is YES, flipped is YES", greater], ^{
                CGFloat value = [SKNode pc_staticPositionSuchThatCornerOpposite:YES doesNotMoveFromPosition:position size:size anchorPoint:anchorPoint flipped:YES];
                [[theValue(value) should] equal:greater withDelta:0.01];
            });

            it([NSString stringWithFormat:@"Should return %.0f when lesserHandle is NO, flipped is YES", lesser], ^{
                CGFloat value = [SKNode pc_staticPositionSuchThatCornerOpposite:NO doesNotMoveFromPosition:position size:size anchorPoint:anchorPoint flipped:YES];
                [[theValue(value) should] equal:lesser withDelta:0.01];
            });
        });
    };

    testStaticPointWithAnchorPoint(0.5, 100, 0);
    testStaticPointWithAnchorPoint(0, 150, 50);
    testStaticPointWithAnchorPoint(1, 50, -50);
    testStaticPointWithAnchorPoint(0.7, 80, -20);
    testStaticPointWithAnchorPoint(-1, 250, 150);
    testStaticPointWithAnchorPoint(2, -50, -150);
});

context(@"When calculating the end position for a node with new size 200, with a static position of 100", ^{
    __block CGFloat position;
    __block CGFloat size;
    beforeAll(^{
        position = 100;
        size = 200;
    });

    void (^testEndPositionWithAnchorPoint)(CGFloat, CGFloat, CGFloat) = ^(CGFloat anchorPoint, CGFloat lesser, CGFloat greater) {
        it([NSString stringWithFormat:@"should return %.0f when lesserHandle is yes, flipped is NO", lesser],  ^{
            CGFloat value = [SKNode pc_positionSuchThatCornerOpposite:YES doesNotMoveFromStaticPosition:position size:size anchorPoint:anchorPoint flipped:NO];
            [[theValue(value) should] equal:lesser withDelta:0.01];
        });

        it([NSString stringWithFormat:@"Should return %.0f when lesserHandle is NO, flipped is NO", greater], ^{
            CGFloat value = [SKNode pc_positionSuchThatCornerOpposite:NO doesNotMoveFromStaticPosition:position size:size anchorPoint:anchorPoint flipped:NO];
            [[theValue(value) should] equal:greater withDelta:0.01];
        });

        it([NSString stringWithFormat:@"Should return %.0f when lesserHandle is YES, flipped is YES", greater], ^{
            CGFloat value = [SKNode pc_positionSuchThatCornerOpposite:YES doesNotMoveFromStaticPosition:position size:size anchorPoint:anchorPoint flipped:YES];
            [[theValue(value) should] equal:greater withDelta:0.01];
        });

        it([NSString stringWithFormat:@"Should return %.0f when lesserHandle is NO, flipped is YES", lesser], ^{
            CGFloat value = [SKNode pc_positionSuchThatCornerOpposite:NO doesNotMoveFromStaticPosition:position size:size anchorPoint:anchorPoint flipped:YES];
            [[theValue(value) should] equal:lesser withDelta:0.01];
        });
    };

    testEndPositionWithAnchorPoint(0.5f, 0, 200);
    testEndPositionWithAnchorPoint(0, -100, 100);
    testEndPositionWithAnchorPoint(1, 100, 300);
    testEndPositionWithAnchorPoint(0.7, 40, 240);
    testEndPositionWithAnchorPoint(-1, -300, -100);
    testEndPositionWithAnchorPoint(2, 300, 500);
});


describe(@"With a 100*100 node at position 50, 50 with anchor point 0.7, 0.5", ^{
    __block SKSpriteNode *node;
    __block PCStageScene *stageScene;
    beforeEach(^{
        stageScene = [[PCStageScene alloc] init];
        node = [[SKSpriteNode alloc] initWithColor:[NSColor blueColor] size:CGSizeMake(100, 100)];
        node.anchorPoint = CGPointMake(0.7f, 0.5f);
        node.position = CGPointMake(50, 50);
        node.userObject = [[NodeInfo alloc] init];
        [stageScene addChild:node];
    });

    //Custom block for test re-use
    void (^testDragHandle)(CCBCornerId edge, CGPoint mousePosition, BOOL lockAspectRatio, CGFloat expectedXScale, CGFloat expectedYScale, CGPoint expectedPosition) = ^(CCBCornerId edge, CGPoint mousePosition, BOOL lockAspectRatio, CGFloat expectedXScale, CGFloat expectedYScale, CGPoint expectedPosition) {
        context([NSString stringWithFormat:@"User drags handle to %@", NSStringFromPoint(mousePosition)], ^{
            __block CGVector newScale;
            __block CGPoint newPosition;
            beforeEach(^{
                newScale = [node pc_scaleFromMousePosition:mousePosition cornerIndex:edge];
                if (lockAspectRatio) {
                    newScale = [SKNode pc_lockAspectRatioOfScale:newScale cornerIndex:edge];
                }
                newPosition = [node pc_positionWhenScaledToNewScale:newScale cornerIndex:edge];
            });

            it([NSString stringWithFormat:@"has a scale of %.1f, %.1f", expectedXScale, expectedYScale], ^{
                [[theValue(newScale.dx) should] equal:expectedXScale withDelta:0.01];
                [[theValue(newScale.dy) should] equal:expectedYScale withDelta:0.01];
            });

            it([NSString stringWithFormat:@"has a position of %@", NSStringFromPoint(expectedPosition)], ^{
                [[theValue(newPosition.x) should] equal:expectedPosition.x withDelta:0.01];
                [[theValue(newPosition.y) should] equal:expectedPosition.y withDelta:0.01];
            });
        });
    };

    void (^testDragHandleWithSetup)(CGFloat xScale, CGFloat yScale, CGPoint startPosition, CCBCornerId edge, CGPoint mousePosition, BOOL lockAspectRatio, CGFloat expectedXScaleScale, CGFloat expectedYScale, CGPoint expectedPosition) = ^(CGFloat xScale, CGFloat yScale, CGPoint startPosition, CCBCornerId edge, CGPoint mousePosition, BOOL lockAspectRatio, CGFloat expectedXScale, CGFloat expectedYScale, CGPoint expectedPosition) {
        context(@"User continues to drag after flipping a node", ^{
            beforeAll(^{
                node.xScale = xScale;
                node.yScale = yScale;
                node.position = startPosition;
            });
            testDragHandle(edge, mousePosition, lockAspectRatio, expectedXScale, expectedYScale,expectedPosition);
        });
    };

    void (^testAspectRatioLock)(CGVector rawScale, CCBCornerId cornerIndex, CGVector expectedScale) = ^(CGVector rawScale, CCBCornerId cornerIndex, CGVector expectedScale) {
        context(@"User drags with aspect ratio locked", ^{
            __block CGVector calculatedScale;
            beforeAll(^{
                calculatedScale = [SKNode pc_lockAspectRatioOfScale:rawScale cornerIndex:cornerIndex];
            });

            it([NSString stringWithFormat:@"has a scale of %.1f, %.1f", expectedScale.dx, expectedScale.dy], ^{
                [[theValue(expectedScale.dx) should] equal:theValue(calculatedScale.dx)];
                [[theValue(expectedScale.dy) should] equal:theValue(calculatedScale.dy)];
            });
        });
    };

    context(@"Node resizes by scale", ^{
        beforeEach(^{
            [node stub:@selector(editorResizeBehaviour) andReturn:theValue(PCEditorResizeBehaviourScale)];
        });

        context(@"Node has a negative scale", ^{
            beforeEach(^{
                node.transformStartScaleX = node.xScale = -1;
                node.transformStartScaleY = node.yScale = -1;
            });

            context(@"And user 'flips' the node", ^{
                testDragHandle(kCCBEdgeLeft, CGPointMake(140, 100), NO, 0.2, -1, CGPointMake(134, 50));
                testDragHandle(kCCBEdgeRight, CGPointMake(0, 100), NO, 0.2, -1, CGPointMake(14, 50));
                testDragHandle(kCCBEdgeBottom, CGPointMake(50, 120), NO, -1, 0.2, CGPointMake(50, 110));
                testDragHandle(kCCBEdgeTop, CGPointMake(50, -20), NO, -1, 0.2, CGPointMake(50, -10));

                //After testing the flip state, test what happens when they keep dragging
                testDragHandleWithSetup(0.2, -1, CGPointMake(134, 50), kCCBEdgeLeft, CGPointMake(150, 100), NO, 0.3, -1, CGPointMake(141, 50));
                testDragHandleWithSetup(0.2, -1, CGPointMake(14, 50), kCCBEdgeRight, CGPointMake(-10, 100), NO, 0.3, -1, CGPointMake(11, 50));
                testDragHandleWithSetup(-1, 0.2, CGPointMake(50, 110), kCCBEdgeBottom, CGPointMake(50, 130), NO, -1, 0.3, CGPointMake(50, 115));
                testDragHandleWithSetup(-1, 0.2, CGPointMake(50, -10), kCCBEdgeTop, CGPointMake(50, -30), NO, -1, 0.3, CGPointMake(50, -15));
            });

            //Test dragging the left handle further left
            testDragHandle(kCCBEdgeLeft, CGPointMake(0, 50), NO, -1.2, -1, CGPointMake(36, 50));
            //Test dragging the left handle  right
            testDragHandle(kCCBEdgeLeft, CGPointMake(40, 50), NO, -0.8, -1, CGPointMake(64, 50));
            //Test dragging the right handle left
            testDragHandle(kCCBEdgeRight, CGPointMake(100, 50), NO, -0.8, -1, CGPointMake(44, 50));
            //Test dragging the right handle further right
            testDragHandle(kCCBEdgeRight, CGPointMake(140, 50), NO, -1.2, -1, CGPointMake(56, 50));

            //Test dragging the top handle further up
            testDragHandle(kCCBEdgeTop, CGPointMake(50, 120), NO, -1, -1.2, CGPointMake(50, 60));
            //Test dragging the top handle further down
            testDragHandle(kCCBEdgeTop, CGPointMake(50, 80), NO, -1, -0.8, CGPointMake(50, 40));
            //Test dragging the bottom handle further up
            testDragHandle(kCCBEdgeBottom, CGPointMake(50, 20), NO, -1, -0.8, CGPointMake(50, 60));
            //Test dragging the bottom handle further down
            testDragHandle(kCCBEdgeBottom, CGPointMake(50, -20), NO, -1, -1.2, CGPointMake(50, 40));


        });

        context(@"Node has a positive scale", ^{
            beforeEach(^{
                node.transformStartScaleX = node.xScale = 1.0f;
                node.transformStartScaleY = node.yScale = 1.0f;
            });

            //Test dragging with shift held
            testDragHandle(kCCBCornerIdBottomLeft, CGPointMake(-30, -15), YES, 1.1, 1.1, CGPointMake(47, 45));
            testDragHandle(kCCBEdgeLeft, CGPointMake(-30, 50), YES, 1.1, 1.1, CGPointMake(47, 50));
            testDragHandle(kCCBCornerIdTopLeft, CGPointMake(-35, 110), YES, 1.1, 1.1, CGPointMake(47, 55));
            testDragHandle(kCCBEdgeTop, CGPointMake(30, 110), YES, 1.1, 1.1, CGPointMake(52, 55));
            testDragHandle(kCCBCornerIdTopRight, CGPointMake(95, 110), YES, 1.1, 1.1, CGPointMake(57, 55));
            testDragHandle(kCCBEdgeRight, CGPointMake(90, 60), YES, 1.1, 1.1, CGPointMake(57, 50));
            testDragHandle(kCCBCornerIdBottomRight, CGPointMake(90, -200), YES, 1.1, 1.1, CGPointMake(57, 45));
            testDragHandle(kCCBEdgeBottom, CGPointMake(30, -10), YES, 1.1, 1.1, CGPointMake(52, 45));

            //Test flipping the scale by dragging more than the nodes current size. Then test again to make sure position is right after flip.
            testDragHandle(kCCBEdgeLeft, CGPointMake(100, 50), NO, -0.2, 1, CGPointMake(86, 50));
            testDragHandle(kCCBEdgeRight, CGPointMake(-40, 50), NO, -0.2, 1, CGPointMake(-34, 50));
            testDragHandle(kCCBEdgeBottom, CGPointMake(50, 120), NO, 1, -0.2, CGPointMake(50, 110));
            testDragHandle(kCCBEdgeTop, CGPointMake(50, -20), NO, 1, -0.2, CGPointMake(50, -10));

            testDragHandleWithSetup(-0.2, 1, CGPointMake(86, 50), kCCBEdgeLeft, CGPointMake(105, 50), NO, -0.25, 1, CGPointMake(87.5, 50));
            testDragHandleWithSetup(-0.2, 1, CGPointMake(-34, 50), kCCBEdgeRight, CGPointMake(-45, 50), NO, -0.25, 1, CGPointMake(-37.5, 50));
            testDragHandleWithSetup(1, -0.2, CGPointMake(50, 110), kCCBEdgeBottom, CGPointMake(50, 125), NO, 1, -0.25, CGPointMake(50, 112.5));
            testDragHandleWithSetup(1, -0.2, CGPointMake(50, -10), kCCBEdgeTop, CGPointMake(50, -25), NO, 1, -0.25, CGPointMake(50, -12.5f));
        });
    });

    testAspectRatioLock(CGVectorMake(1.2f, 1.0f), kCCBCornerIdBottomLeft, CGVectorMake(1.0f, 1.0f));
    testAspectRatioLock(CGVectorMake(2.4f, 3.1f), kCCBCornerIdBottomRight, CGVectorMake(2.4f, 2.4f));
    testAspectRatioLock(CGVectorMake(0.3f, 0.4f), kCCBCornerIdTopLeft, CGVectorMake(0.3f, 0.3f));
    testAspectRatioLock(CGVectorMake(0.1f, 2.2f), kCCBCornerIdTopRight, CGVectorMake(0.1f, 0.1f));
    testAspectRatioLock(CGVectorMake(2, 1), kCCBEdgeLeft, CGVectorMake(2, 2));
    testAspectRatioLock(CGVectorMake(1, 2), kCCBEdgeRight, CGVectorMake(1, 1));
    testAspectRatioLock(CGVectorMake(2, 1), kCCBEdgeTop, CGVectorMake(1, 1));
    testAspectRatioLock(CGVectorMake(1, 2), kCCBEdgeBottom, CGVectorMake(2, 2));
    //Testing w/ negative values - should change magnitude but keep each sides signs the same
    testAspectRatioLock(CGVectorMake(1.2f, -1.0f), kCCBCornerIdBottomLeft, CGVectorMake(1.0f, -1.0f));
    testAspectRatioLock(CGVectorMake(-2.4f, 3.1f), kCCBCornerIdBottomRight, CGVectorMake(-2.4f, 2.4f));
    testAspectRatioLock(CGVectorMake(0.3f, -0.4f), kCCBCornerIdTopLeft, CGVectorMake(0.3f, -0.3f));
    testAspectRatioLock(CGVectorMake(-0.1f, 2.2f), kCCBCornerIdTopRight, CGVectorMake(-0.1f, 0.1f));
    testAspectRatioLock(CGVectorMake(2, -1), kCCBEdgeLeft, CGVectorMake(2, -2));
    testAspectRatioLock(CGVectorMake(-1, 2), kCCBEdgeRight, CGVectorMake(-1, 1));
    testAspectRatioLock(CGVectorMake(2, -1), kCCBEdgeTop, CGVectorMake(1, -1));
    testAspectRatioLock(CGVectorMake(-1, 2), kCCBEdgeBottom, CGVectorMake(-2, 2));

    context(@"Node scales by content size", ^{
        __block CGSize newSize;
        __block CGPoint newPosition;

        beforeEach(^{
            node.position = CGPointMake(50, 50);
            node.anchorPoint = CGPointMake(0.7f, 0.5f);
            [node stub:@selector(editorResizeBehaviour) andReturn:theValue(PCEditorResizeBehaviourContentSize)];
        });

        void (^testAdjustContentSize)(CGPoint mousePosition, CCBCornerId cornerIndex, BOOL lockAspectRatio, CGSize expectedSize, CGPoint expectedPosition) = ^(CGPoint mousePosition, CCBCornerId cornerIndex, BOOL lockAspectRatio, CGSize expectedSize, CGPoint expectedPosition) {

            context([NSString stringWithFormat:@"with mouse at position %@", NSStringFromPoint(mousePosition)], ^{
                beforeAll(^{
                    newSize = [node pc_sizeFromMousePosition:mousePosition cornerIndex:cornerIndex];
                    if (lockAspectRatio) {
                        newSize = [node pc_lockAspectRatioOfSize:newSize cornerIndex:cornerIndex];
                    }
                    newPosition = [node pc_positionWhenContentSizeSetToSize:newSize cornerIndex:cornerIndex];
                });

                it([NSString stringWithFormat:@"Should have a size of %@", NSStringFromSize(expectedSize)], ^{
                    [[theValue(newSize.width) should] equal:expectedSize.width withDelta:0.01];
                    [[theValue(newSize.height) should] equal:expectedSize.height withDelta:0.01];
                });
                it([NSString stringWithFormat:@"Should have a position of %@", NSStringFromPoint(expectedPosition)], ^{
                    [[theValue(newPosition.x) should] equal:expectedPosition.x withDelta:0.01];
                    [[theValue(newPosition.y) should] equal:expectedPosition.y withDelta:0.01];
                });
            });
        };

        context(@"node has a scale of 1", ^{
            beforeEach(^{
                node.xScale = 1;
                node.yScale = 1;
            });

            testAdjustContentSize(CGPointMake(-40, 0), kCCBEdgeLeft, NO, CGSizeMake(120, 100), CGPointMake(44, 50));
            testAdjustContentSize(CGPointMake(0, 0), kCCBEdgeLeft, NO, CGSizeMake(80, 100), CGPointMake(56, 50));
            testAdjustContentSize(CGPointMake(100, 0), kCCBEdgeLeft, NO, CGSizeMake(-20, 100), CGPointMake(94, 50));

            testAdjustContentSize(CGPointMake(100, 0), kCCBEdgeRight, NO, CGSizeMake(120, 100), CGPointMake(64, 50));
            testAdjustContentSize(CGPointMake(60, 0), kCCBEdgeRight, NO, CGSizeMake(80, 100), CGPointMake(36, 50));
            testAdjustContentSize(CGPointMake(-40, 0), kCCBEdgeRight, NO, CGSizeMake(-20, 100), CGPointMake(-26, 50));

            testAdjustContentSize(CGPointMake(0, 120), kCCBEdgeTop, NO, CGSizeMake(100, 120), CGPointMake(50, 60));
            testAdjustContentSize(CGPointMake(0, 80), kCCBEdgeTop, NO, CGSizeMake(100, 80), CGPointMake(50, 40));
            testAdjustContentSize(CGPointMake(0, -20), kCCBEdgeTop, NO, CGSizeMake(100, -20), CGPointMake(50, -10));

            testAdjustContentSize(CGPointMake(0, -20), kCCBEdgeBottom, NO, CGSizeMake(100, 120), CGPointMake(50, 40));
            testAdjustContentSize(CGPointMake(0, 20), kCCBEdgeBottom, NO, CGSizeMake(100, 80), CGPointMake(50, 60));
            testAdjustContentSize(CGPointMake(0, 120), kCCBEdgeBottom, NO, CGSizeMake(100, -20), CGPointMake(50, 110));

            testAdjustContentSize(CGPointMake(-40, 0), kCCBEdgeLeft, YES, CGSizeMake(120, 120), CGPointMake(44, 50));
            testAdjustContentSize(CGPointMake(100, 0), kCCBEdgeRight, YES, CGSizeMake(120, 120), CGPointMake(64, 50));
            testAdjustContentSize(CGPointMake(0, 120), kCCBEdgeTop, YES, CGSizeMake(120, 120), CGPointMake(54, 60));
            testAdjustContentSize(CGPointMake(0, -20), kCCBEdgeBottom, YES, CGSizeMake(120, 120), CGPointMake(54, 40));
        });

        context(@"but node has a scale > 1", ^{
            beforeEach(^{
                node.xScale = 2;
                node.yScale = 2;
            });

            testAdjustContentSize(CGPointMake(-110, 0), kCCBEdgeLeft, NO, CGSizeMake(220, 200), CGPointMake(44, 50));
            testAdjustContentSize(CGPointMake(130, 0), kCCBEdgeRight, NO, CGSizeMake(220, 200), CGPointMake(64, 50));
            testAdjustContentSize(CGPointMake(0, -70), kCCBEdgeBottom, NO, CGSizeMake(200, 220), CGPointMake(50, 40));
            testAdjustContentSize(CGPointMake(0, 170), kCCBEdgeTop, NO, CGSizeMake(200, 220), CGPointMake(50, 60));
        });

        context(@"but node has a scale < 0", ^{
            beforeEach(^{
                node.xScale = -1;
                node.yScale = -1;
            });

            testAdjustContentSize(CGPointMake(0, 50), kCCBEdgeLeft, NO, CGSizeMake(-120, -100), CGPointMake(36, 50));
            testAdjustContentSize(CGPointMake(40, 50), kCCBEdgeLeft, NO, CGSizeMake(-80, -100), CGPointMake(64, 50));
            testAdjustContentSize(CGPointMake(140, 50), kCCBEdgeLeft, NO, CGSizeMake(20, -100), CGPointMake(126, 50));

            testAdjustContentSize(CGPointMake(100, 50), kCCBEdgeRight, NO, CGSizeMake(-80, -100), CGPointMake(44, 50));
            testAdjustContentSize(CGPointMake(140, 50), kCCBEdgeRight, NO, CGSizeMake(-120, -100), CGPointMake(56, 50));
            testAdjustContentSize(CGPointMake(0, 50), kCCBEdgeRight, NO, CGSizeMake(20, -100), CGPointMake(6, 50));
            
            testAdjustContentSize(CGPointMake(50, 120), kCCBEdgeTop, NO, CGSizeMake(-100, -120), CGPointMake(50, 60));
            testAdjustContentSize(CGPointMake(50, 80), kCCBEdgeTop, NO, CGSizeMake(-100, -80), CGPointMake(50, 40));
            testAdjustContentSize(CGPointMake(50, -20), kCCBEdgeTop, NO, CGSizeMake(-100, 20), CGPointMake(50, -10));

            testAdjustContentSize(CGPointMake(50, 20), kCCBEdgeBottom, NO, CGSizeMake(-100, -80), CGPointMake(50, 60));
            testAdjustContentSize(CGPointMake(50, -20), kCCBEdgeBottom, NO, CGSizeMake(-100, -120), CGPointMake(50, 40));
            testAdjustContentSize(CGPointMake(50, 120), kCCBEdgeBottom, NO, CGSizeMake(-100, 20), CGPointMake(50, 110));
        });
    });
});

SPEC_END

