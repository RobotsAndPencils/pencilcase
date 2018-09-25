//
//  SKNodeTouchRecognizerTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 2014-09-12.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SpriteKit/SpriteKit.h>
#import "SKNode+TouchRecognizers.h"
#import "SKNode+SFGestureRecognizers.h"
#import "PCJSContext.h"

SPEC_BEGIN(SKNodeTouchRecognizerTests)

__block PCJSContext *jsContext;
__block SKNode *node;
beforeEach(^{
    jsContext = [[PCJSContext alloc] init];
    node = [SKNode node];
    jsContext[@"node"] = node;
});

context(@"adding recognizers", ^{
    specify(^{
        [[theBlock(^{
            [jsContext evaluateScript:@"node.addTapRecognizer(1, 1);"];
        }) should] change:^NSInteger {
            return node.sf_gestureRecognizers.count;
        } by:1];
    });

    specify(^{
        [[theBlock(^{
            [jsContext evaluateScript:@"node.addSwipeRecognizer(1, 'left');"];
        }) should] change:^NSInteger {
            return node.sf_gestureRecognizers.count;
        } by:1];
    });

    specify(^{
        [[theBlock(^{
            [jsContext evaluateScript:@"node.addLongPressRecognizer(1, 1);"];
        }) should] change:^NSInteger {
            return node.sf_gestureRecognizers.count;
        } by:1];
    });

    specify(^{
        [[theBlock(^{
            [jsContext evaluateScript:@"node.addPinchRecognizer('open');"];
        }) should] change:^NSInteger {
            return node.sf_gestureRecognizers.count;
        } by:1];
    });

    specify(^{
        [[theBlock(^{
            [jsContext evaluateScript:@"node.addPanRecognizer();"];
        }) should] change:^NSInteger {
            return node.sf_gestureRecognizers.count;
        } by:1];
    });

    context(@"adding multiple recognizers", ^{
        beforeEach(^{
            [jsContext evaluateScript:@"node.addTapRecognizer(1, 1);"];
            [jsContext evaluateScript:@"node.addSwipeRecognizer(1, 'left');"];
            [jsContext evaluateScript:@"node.addLongPressRecognizer(1, 1);"];
            [jsContext evaluateScript:@"node.addPinchRecognizer('open');"];
            [jsContext evaluateScript:@"node.addPanRecognizer();"];
        });

        context(@"shouldn't add more than one recognizer of a given class and configuration", ^{
            specify(^{
                [[theBlock(^{
                    [jsContext evaluateScript:@"node.addTapRecognizer(1, 1);"];
                }) shouldNot] change:^NSInteger {
                    return node.sf_gestureRecognizers.count;
                }];
            });

            specify(^{
                [[theBlock(^{
                    [jsContext evaluateScript:@"node.addSwipeRecognizer(1, 'left');"];
                }) shouldNot] change:^NSInteger {
                    return node.sf_gestureRecognizers.count;
                }];
            });

            specify(^{
                [[theBlock(^{
                    [jsContext evaluateScript:@"node.addLongPressRecognizer(1, 1);"];
                }) shouldNot] change:^NSInteger {
                    return node.sf_gestureRecognizers.count;
                }];
            });

            specify(^{
                [[theBlock(^{
                    [jsContext evaluateScript:@"node.addPinchRecognizer('open');"];
                }) shouldNot] change:^NSInteger {
                    return node.sf_gestureRecognizers.count;
                }];
            });

            specify(^{
                [[theBlock(^{
                    [jsContext evaluateScript:@"node.addPanRecognizer();"];
                }) shouldNot] change:^NSInteger {
                    return node.sf_gestureRecognizers.count;
                }];
            });
        });
    });
});

SPEC_END
