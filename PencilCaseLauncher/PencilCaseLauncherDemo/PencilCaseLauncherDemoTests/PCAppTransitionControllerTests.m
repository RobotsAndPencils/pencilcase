//
//  PCAppTransitionControllerTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-06-02.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SpriteKit/SpriteKit.h>
#import <PencilCaseLauncher/PCApp.h>
#import <PencilCaseLauncher/PCCard.h>
#import "PCAppTransitionController.h"
#import "PCSpriteKitPresenter.h"
#import "PCCard.h"
#import "CCBReader.h"

void delay(CGFloat duration, void(^block)()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

@interface PCAppTransitionController (Tests)
- (void)goToSlideAtIndex:(NSInteger)slideIndex withTransition:(SKTransition *)transition duration:(CGFloat)duration completion:(void (^)())completion;
@end

SPEC_BEGIN(PCAppTransitionControllerTests)

describe(@"When transitioning between cards", ^{
    __block PCApp *app;
    __block PCCard *card1;
    __block PCCard *card2;
    __block PCCard *card3;
    __block PCAppTransitionController *transitionController;
    __block KWMock *presenter;
    __block BOOL hasPresented;
    beforeEach(^{
        card1 = [PCCard nullMock];
        card2 = [PCCard nullMock];
        card3 = [PCCard nullMock];

        app = [[PCApp alloc] init];
        [app.cards addObject:card1];
        [app.cards addObject:card2];
        [app.cards addObject:card3];

        transitionController = [[PCAppTransitionController alloc] initWithApp:app cardIndex:0];

        presenter = [KWMock nullMockForProtocol:@protocol(PCSpriteKitPresenter)];
        hasPresented = NO;
        [presenter stub:@selector(presentScene:withTransition:duration:completion:) withBlock:^id(NSArray *params) {
            if (params.count < 4) return nil;

            hasPresented = YES;

            CGFloat duration = [params[2] floatValue];
            void(^completion)() = params[3];
            delay(duration, completion);

            return nil;
        }];
        [presenter stub:@selector(isPresentingAScene) andReturn:theValue(hasPresented)];
        
        transitionController.presenter = (id <PCSpriteKitPresenter>)presenter;
        [transitionController goToCurrentSlide];
    });

    context(@"The cards are the same", ^{
        let(cardIndex, ^{ return @0; });

        context(@"Single transition", ^{
            void(^steps)() = ^{
                [transitionController goToSlideAtIndex:cardIndex.integerValue withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
            };

            pending(@"should transition once", ^{
                [[expectFutureValue(presenter) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(presentScene:withTransition:duration:completion:) withCount:1];
                steps();
            });

            pending(@"first card did disappear", ^{
                [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear) withCount:1];
                steps();
            });

            pending(@"first card will appear", ^{
                [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardWillAppear) withCount:1];
                steps();
            });

            pending(@"first card did appear", ^{
                [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidAppear) withCount:1];
                steps();
            });

            pending(@"card should be able to transition after", ^{
                steps();
                [[expectFutureValue(theValue(card1.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beYes];
            });
        });

        context(@"Two transitions", ^{
            context(@"Second starts before first ends", ^{
                void(^steps)() = ^{
                    [transitionController goToSlideAtIndex:cardIndex.integerValue withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
                    delay(0.25, ^{
                        [transitionController goToSlideAtIndex:cardIndex.integerValue withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
                    });
                };

                pending(@"should transition once", ^{
                    [[expectFutureValue(presenter) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(presentScene:withTransition:duration:completion:) withCount:1];
                    steps();
                });

                pending(@"first card did disappear", ^{
                    [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear) withCount:1];
                    steps();
                });

                pending(@"first card will appear", ^{
                    [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardWillAppear) withCount:1];
                    steps();
                });

                pending(@"first card did appear", ^{
                    [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidAppear) withCount:1];
                    steps();
                });

                pending(@"card should be able to transition after", ^{
                    steps();
                    [[expectFutureValue(theValue(card1.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beYes];
                });
            });

            context(@"Second starts after first ends", ^{
                void(^steps)() = ^{
                    [transitionController goToSlideAtIndex:cardIndex.integerValue withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
                    delay(0.75, ^{
                        [transitionController goToSlideAtIndex:cardIndex.integerValue withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
                    });
                };

                pending(@"should transition twice", ^{
                    [[expectFutureValue(presenter) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(presentScene:withTransition:duration:completion:) withCount:2];
                    steps();
                });

                pending(@"first card did disappear", ^{
                    [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear) withCount:2];
                    steps();
                });

                pending(@"first card will appear", ^{
                    [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardWillAppear) withCount:2];
                    steps();
                });

                pending(@"first card did appear", ^{
                    [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidAppear) withCount:2];
                    steps();
                });

                pending(@"card should be able to transition after", ^{
                    steps();
                    [[expectFutureValue(theValue(card1.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beYes];
                });
            });
        });
    });

    context(@"The cards are different", ^{
        let(cardIndex, ^{ return @1; });

        context(@"Single transition", ^{
            void(^steps)() = ^{
                [transitionController goToSlideAtIndex:cardIndex.integerValue withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
            };

            pending(@"should transition once", ^{
                [[presenter should] receive:@selector(presentScene:withTransition:duration:completion:) withCount:1];
                steps();
            });

            pending(@"first card did disappear", ^{
                [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear) withCount:1];
                steps();
            });

            pending(@"first card should not be able to transition after", ^{
                steps();
                [[expectFutureValue(theValue(card1.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beNo];
            });

            pending(@"second card will appear", ^{
                [[card2 should] receive:@selector(cardWillAppear) withCount:1];
                steps();
            });

            pending(@"second card did appear", ^{
                [[expectFutureValue(card2) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidAppear) withCount:1];
                steps();
            });

            pending(@"second card didn't disappear", ^{
                [[expectFutureValue(card2) shouldNotEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear)];
                steps();
            });

            pending(@"second card should be able to transition after", ^{
                steps();
                [[expectFutureValue(theValue(card2.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beYes];
            });
        });

        context(@"Two transitions", ^{
            context(@"Second starts before first ends", ^{
                void(^steps)() = ^{
                    [transitionController goToSlideAtIndex:cardIndex.integerValue withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
                    delay(0.25, ^{
                        [transitionController goToSlideAtIndex:cardIndex.integerValue + 1 withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
                    });
                };

                pending(@"should transition once", ^{
                    [[expectFutureValue(presenter) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(presentScene:withTransition:duration:completion:) withCount:1];
                    steps();
                });

                pending(@"first card did disappear", ^{
                    [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear)];
                    steps();
                });

                pending(@"first card should not be able to transition after", ^{
                    steps();
                    [[expectFutureValue(theValue(card1.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beNo];
                });

                pending(@"second card will appear", ^{
                    [[card2 should] receive:@selector(cardWillAppear) withCount:1];
                    steps();
                });

                pending(@"second card did appear", ^{
                    [[expectFutureValue(card2) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidAppear) withCount:1];
                    steps();
                });

                pending(@"second card didn't disappear", ^{
                    [[expectFutureValue(card2) shouldNotEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear)];
                    steps();
                });

                pending(@"second card should be able to transition after", ^{
                    steps();
                    [[expectFutureValue(theValue(card2.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beYes];
                });
            });

            context(@"Second starts after first ends", ^{
                void(^steps)() = ^{
                    [transitionController goToSlideAtIndex:cardIndex.integerValue withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
                    delay(0.75, ^{
                        [transitionController goToSlideAtIndex:cardIndex.integerValue + 1 withTransition:[SKTransition fadeWithDuration:0.5] duration:0.5 completion:nil];
                    });
                };

                pending(@"should transition twice", ^{
                    [[expectFutureValue(presenter) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(presentScene:withTransition:duration:completion:) withCount:2];
                    steps();
                });

                pending(@"first card should have lifecycle methods called on it", ^{
                    [[expectFutureValue(card1) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear)];
                    steps();
                });

                pending(@"first card should not be able to transition after", ^{
                    steps();
                    [[expectFutureValue(theValue(card1.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beNo];
                });

                pending(@"second card will appear", ^{
                    [[card2 should] receive:@selector(cardWillAppear) withCount:1];
                    steps();
                });

                pending(@"second card did appear", ^{
                    [[expectFutureValue(card2) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidAppear) withCount:1];
                    steps();
                });

                pending(@"second card did disappear", ^{
                    [[expectFutureValue(card2) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear) withCount:1];
                    steps();
                });

                pending(@"second card should not be able to transition after", ^{
                    steps();
                    [[expectFutureValue(theValue(card2.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beNo];
                });

                pending(@"third card will appear", ^{
                    [[expectFutureValue(card3) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardWillAppear) withCount:1];
                    steps();
                });

                pending(@"third card did appear", ^{
                    [[expectFutureValue(card3) shouldEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidAppear) withCount:1];
                    steps();
                });

                pending(@"third card didn't disappear", ^{
                    [[expectFutureValue(card3) shouldNotEventuallyBeforeTimingOutAfter(3.0)] receive:@selector(cardDidDisappear)];
                    steps();
                });

                pending(@"third card should be able to transition after", ^{
                    steps();
                    [[expectFutureValue(theValue(card3.canTransition)) shouldEventuallyBeforeTimingOutAfter(3.0)] beYes];
                });
            });
        });
    });
});

SPEC_END
