//
//  UIGestureRecognizerJSEventsTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 14-12-30.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>

#import "PCPinchDirectionGestureRecognizer.h"
#import "PCJSContext.h"

@class SKView;

@interface UIGestureRecognizer (JSEventsTests)
+ (NSString *)pc_jsRecognizerName;
+ (BOOL)pc_continuous;
- (NSString *)pc_eventNameForState:(UIGestureRecognizerState)state;
- (NSArray *)pc_arguments;
- (void)pc_handleTouchEventWithRecognizer:(UIGestureRecognizer *)recognizer;
- (SKView *)pc_skView;
@end

SPEC_BEGIN(UIGestureRecognizerJSEventsTests)

describe(@"UIGestureRecognizer+JSEvents", ^{
    describe(@"pc_jsRecognizerName", ^{
        specify(^{
            [[[UITapGestureRecognizer pc_jsRecognizerName] should] equal:@"tap"];
        });

        specify(^{
            [[[UISwipeGestureRecognizer pc_jsRecognizerName] should] equal:@"swipe"];
        });

        specify(^{
            [[[UILongPressGestureRecognizer pc_jsRecognizerName] should] equal:@"longPress"];
        });

        specify(^{
            [[[UIPanGestureRecognizer pc_jsRecognizerName] should] equal:@"pan"];
        });

        specify(^{
            [[[PCPinchDirectionGestureRecognizer pc_jsRecognizerName] should] equal:@"pinch"];
        });

        specify(^{
            [[[UIRotationGestureRecognizer pc_jsRecognizerName] should] equal:@"rotation"];
        });
    });

    describe(@"pc_eventNameForState", ^{
        context(@"UITapGestureRecognizer", ^{
            __block UITapGestureRecognizer *tapGestureRecognizer;
            beforeEach(^{
                tapGestureRecognizer = [UITapGestureRecognizer new];
            });

            context(@"began", ^{
                specify(^{
                    [[[tapGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateBegan] should] equal:@"tap"];
                });
            });

            context(@"ended", ^{
                specify(^{
                    [[[tapGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateEnded] should] equal:@"tap"];
                });
            });
        });

        context(@"UISwipeGestureRecognizer", ^{
            __block UISwipeGestureRecognizer *swipeGestureRecognizer;
            beforeEach(^{
                swipeGestureRecognizer = [UISwipeGestureRecognizer new];
            });

            context(@"began", ^{
                specify(^{
                    [[[swipeGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateBegan] should] equal:@"swipe"];
                });
            });

            context(@"ended", ^{
                specify(^{
                    [[[swipeGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateEnded] should] equal:@"swipe"];
                });
            });
        });

        context(@"UILongPressGestureRecognizer", ^{
            __block UILongPressGestureRecognizer *longPressGestureRecognizer;
            beforeEach(^{
                longPressGestureRecognizer = [UILongPressGestureRecognizer new];
            });

            context(@"began", ^{
                specify(^{
                    [[[longPressGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateBegan] should] equal:@"longPressBegan"];
                });
            });

            context(@"changed", ^{
                specify(^{
                    [[[longPressGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateChanged] should] equal:@"longPressChanged"];
                });
            });

            context(@"ended", ^{
                specify(^{
                    [[[longPressGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateEnded] should] equal:@"longPressEnded"];
                });
            });

            context(@"cancelled", ^{
                specify(^{
                    [[[longPressGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateCancelled] should] equal:@"longPressEnded"];
                });
            });
        });

        context(@"UIPanGestureRecognizer", ^{
            __block UIPanGestureRecognizer *panGestureRecognizer;
            beforeEach(^{
                panGestureRecognizer = [UIPanGestureRecognizer new];
            });

            context(@"began", ^{
                specify(^{
                    [[[panGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateBegan] should] equal:@"panBegan"];
                });
            });

            context(@"changed", ^{
                specify(^{
                    [[[panGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateChanged] should] equal:@"panChanged"];
                });
            });

            context(@"ended", ^{
                specify(^{
                    [[[panGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateEnded] should] equal:@"panEnded"];
                });
            });

            context(@"cancelled", ^{
                specify(^{
                    [[[panGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateCancelled] should] equal:@"panEnded"];
                });
            });
        });

        context(@"PCPinchDirectionGestureRecognizer", ^{
            __block PCPinchDirectionGestureRecognizer *pinchDirectionGestureRecognizer;
            beforeEach(^{
                pinchDirectionGestureRecognizer = [PCPinchDirectionGestureRecognizer new];
            });

            context(@"began", ^{
                specify(^{
                    [[[pinchDirectionGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateBegan] should] equal:@"pinchBegan"];
                });
            });

            context(@"changed", ^{
                specify(^{
                    [[[pinchDirectionGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateChanged] should] equal:@"pinchChanged"];
                });
            });

            context(@"ended", ^{
                specify(^{
                    [[[pinchDirectionGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateEnded] should] equal:@"pinchEnded"];
                });
            });

            context(@"cancelled", ^{
                specify(^{
                    [[[pinchDirectionGestureRecognizer pc_eventNameForState:UIGestureRecognizerStateCancelled] should] equal:@"pinchEnded"];
                });
            });
        });
    });

    describe(@"pc_continuous", ^{
        specify(^{
            [[theValue([UITapGestureRecognizer pc_continuous]) should] beNo];
        });

        specify(^{
            [[theValue([UISwipeGestureRecognizer pc_continuous]) should] beNo];
        });

        specify(^{
            [[theValue([UILongPressGestureRecognizer pc_continuous]) should] beYes];
        });

        specify(^{
            [[theValue([UIPanGestureRecognizer pc_continuous]) should] beYes];
        });

        specify(^{
            [[theValue([PCPinchDirectionGestureRecognizer pc_continuous]) should] beYes];
        });

        specify(^{
            [[theValue([UIRotationGestureRecognizer pc_continuous]) should] beYes];
        });
    });

    describe(@"pc_arguments", ^{
        context(@"UITapGestureRecognizer", ^{
            __block UITapGestureRecognizer *tapGestureRecognizer;
            beforeEach(^{
                tapGestureRecognizer = [UITapGestureRecognizer new];
                [tapGestureRecognizer stub:@selector(pc_skView)];
                tapGestureRecognizer.numberOfTapsRequired = 2;
                [tapGestureRecognizer stub:@selector(numberOfTouches) andReturn:theValue(2)];
            });

            it(@"should contain the correct number of arguments", ^{
                [[[tapGestureRecognizer pc_arguments] should] haveCountOf:3];
            });

            it(@"should have the correct location", ^{
                NSValue *locationValue = [[tapGestureRecognizer pc_arguments] firstObject];
                CGPoint location = [locationValue CGPointValue];
                [[theValue(location) should] equal:theValue(CGPointMake(0, 0))];
            });

            it(@"should have the correct number of taps", ^{
                NSNumber *numberOfTaps = [tapGestureRecognizer pc_arguments][1];
                [[numberOfTaps should] equal:@2];
            });

            it(@"should have the correct number of touches", ^{
                NSNumber *numberOfTouches = [tapGestureRecognizer pc_arguments][2];
                [[numberOfTouches should] equal:@2];
            });
        });

        context(@"UISwipeGestureRecognizer", ^{
            __block UISwipeGestureRecognizer *swipeGestureRecognizer;
            beforeEach(^{
                swipeGestureRecognizer = [UISwipeGestureRecognizer new];
                [swipeGestureRecognizer stub:@selector(pc_skView)];
                [swipeGestureRecognizer stub:@selector(numberOfTouches) andReturn:theValue(2)];
                [swipeGestureRecognizer stub:@selector(direction) andReturn:theValue(UISwipeGestureRecognizerDirectionUp)];
            });

            it(@"should contain the correct number of arguments", ^{
                [[[swipeGestureRecognizer pc_arguments] should] haveCountOf:3];
            });

            it(@"should have the correct location", ^{
                NSValue *locationValue = [[swipeGestureRecognizer pc_arguments] firstObject];
                CGPoint location = [locationValue CGPointValue];
                [[theValue(location) should] equal:theValue(CGPointMake(0, 0))];
            });

            it(@"should have the correct direction", ^{
                NSNumber *numberOfTaps = [swipeGestureRecognizer pc_arguments][1];
                [[numberOfTaps should] equal:@"up"];
            });

            it(@"should have the correct number of touches", ^{
                NSNumber *numberOfTouches = [swipeGestureRecognizer pc_arguments][2];
                [[numberOfTouches should] equal:@2];
            });
        });

        context(@"UILongPressGestureRecognizer", ^{
            __block UILongPressGestureRecognizer *longPressGestureRecognizer;
            beforeEach(^{
                longPressGestureRecognizer = [UILongPressGestureRecognizer new];
                [longPressGestureRecognizer stub:@selector(pc_skView)];
                longPressGestureRecognizer.numberOfTapsRequired = 2;
                [longPressGestureRecognizer stub:@selector(numberOfTouches) andReturn:theValue(2)];
            });

            it(@"should contain the correct number of arguments", ^{
                [[[longPressGestureRecognizer pc_arguments] should] haveCountOf:3];
            });

            it(@"should have the correct location", ^{
                NSValue *locationValue = [[longPressGestureRecognizer pc_arguments] firstObject];
                CGPoint location = [locationValue CGPointValue];
                [[theValue(location) should] equal:theValue(CGPointMake(0, 0))];
            });

            it(@"should have the correct number of taps", ^{
                NSNumber *numberOfTaps = [longPressGestureRecognizer pc_arguments][1];
                [[numberOfTaps should] equal:@2];
            });

            it(@"should have the correct number of touches", ^{
                NSNumber *numberOfTouches = [longPressGestureRecognizer pc_arguments][2];
                [[numberOfTouches should] equal:@2];
            });
        });

        context(@"UIPanGestureRecognizer", ^{
            __block UIPanGestureRecognizer *panGestureRecognizer;
            beforeEach(^{
                panGestureRecognizer = [UIPanGestureRecognizer new];
                [panGestureRecognizer stub:@selector(pc_skView)];
            });

            it(@"should contain the correct number of arguments", ^{
                [[[panGestureRecognizer pc_arguments] should] haveCountOf:3];
            });

            it(@"should have the correct location", ^{
                NSValue *locationValue = [[panGestureRecognizer pc_arguments] firstObject];
                CGPoint location = [locationValue CGPointValue];
                [[theValue(location) should] equal:theValue(CGPointMake(0, 0))];
            });

            it(@"should have the correct translation", ^{
                CGPoint translation = [[panGestureRecognizer pc_arguments][1] CGPointValue];
                [[theValue(translation) should] equal:theValue(CGPointMake(0, 0))];
            });

            it(@"should have the correct velocity", ^{
                CGPoint velocity = [[panGestureRecognizer pc_arguments][2] CGPointValue];
                [[theValue(velocity) should] equal:theValue(CGPointMake(0, 0))];
            });
        });

        context(@"PCPinchDirectionGestureRecognizer", ^{
            __block PCPinchDirectionGestureRecognizer *pinchDirectionGestureRecognizer;
            beforeEach(^{
                pinchDirectionGestureRecognizer = [PCPinchDirectionGestureRecognizer new];
                [pinchDirectionGestureRecognizer stub:@selector(pc_skView)];
                [pinchDirectionGestureRecognizer stub:@selector(velocity) andReturn:theValue(1)];
            });

            it(@"should contain the correct number of arguments", ^{
                [[[pinchDirectionGestureRecognizer pc_arguments] should] haveCountOf:2];
            });

            it(@"should have the correct location", ^{
                NSValue *locationValue = [[pinchDirectionGestureRecognizer pc_arguments] firstObject];
                CGPoint location = [locationValue CGPointValue];
                [[theValue(location) should] equal:theValue(CGPointMake(0, 0))];
            });

            it(@"should have the correct direction", ^{
                NSNumber *isOpen = [pinchDirectionGestureRecognizer pc_arguments][1];
                [[isOpen should] equal:@"open"];
            });
        });
    });

    describe(@"pc_handleTouchEventWithRecognizer", ^{
        context(@"UITapGestureRecognizer", ^{
            __block UITapGestureRecognizer *tapGestureRecognizer;
            beforeEach(^{
                tapGestureRecognizer = [UITapGestureRecognizer new];
                [tapGestureRecognizer stub:@selector(pc_skView)];
                tapGestureRecognizer.numberOfTapsRequired = 2;
                [tapGestureRecognizer stub:@selector(numberOfTouches) andReturn:theValue(2)];
            });

            it(@"should fire a JS event notification", ^{
                [[PCJSContextEventNotificationName should] bePosted];
                [tapGestureRecognizer pc_handleTouchEventWithRecognizer:tapGestureRecognizer];
            });
        });

        context(@"UISwipeGestureRecognizer", ^{
            __block UISwipeGestureRecognizer *swipeGestureRecognizer;
            beforeEach(^{
                swipeGestureRecognizer = [UISwipeGestureRecognizer new];
                [swipeGestureRecognizer stub:@selector(pc_skView)];
                [swipeGestureRecognizer stub:@selector(numberOfTouches) andReturn:theValue(2)];
                [swipeGestureRecognizer stub:@selector(direction) andReturn:theValue(UISwipeGestureRecognizerDirectionUp)];
            });

            it(@"should fire a JS event notification", ^{
                [[PCJSContextEventNotificationName should] bePosted];
                [swipeGestureRecognizer pc_handleTouchEventWithRecognizer:swipeGestureRecognizer];
            });
        });

        context(@"UILongPressGestureRecognizer", ^{
            __block UILongPressGestureRecognizer *longPressGestureRecognizer;
            beforeEach(^{
                longPressGestureRecognizer = [UILongPressGestureRecognizer new];
                [longPressGestureRecognizer stub:@selector(pc_skView)];
                longPressGestureRecognizer.numberOfTapsRequired = 2;
                [longPressGestureRecognizer stub:@selector(numberOfTouches) andReturn:theValue(2)];
            });

            it(@"should fire a JS event notification", ^{
                [[PCJSContextEventNotificationName should] bePosted];
                [longPressGestureRecognizer pc_handleTouchEventWithRecognizer:longPressGestureRecognizer];
            });
        });

        context(@"UIPanGestureRecognizer", ^{
            __block UIPanGestureRecognizer *panGestureRecognizer;
            beforeEach(^{
                panGestureRecognizer = [UIPanGestureRecognizer new];
                [panGestureRecognizer stub:@selector(pc_skView)];
            });

            it(@"should fire a JS event notification", ^{
                [[PCJSContextEventNotificationName should] bePosted];
                [panGestureRecognizer pc_handleTouchEventWithRecognizer:panGestureRecognizer];
            });
        });

        context(@"PCPinchDirectionGestureRecognizer", ^{
            __block PCPinchDirectionGestureRecognizer *pinchDirectionGestureRecognizer;
            beforeEach(^{
                pinchDirectionGestureRecognizer = [PCPinchDirectionGestureRecognizer new];
                [pinchDirectionGestureRecognizer stub:@selector(pc_skView)];
                [pinchDirectionGestureRecognizer stub:@selector(velocity) andReturn:theValue(1)];
            });

            it(@"should fire a JS event notification", ^{
                [[PCJSContextEventNotificationName should] bePosted];
                [pinchDirectionGestureRecognizer pc_handleTouchEventWithRecognizer:pinchDirectionGestureRecognizer];
            });
        });
    });
});


SPEC_END
