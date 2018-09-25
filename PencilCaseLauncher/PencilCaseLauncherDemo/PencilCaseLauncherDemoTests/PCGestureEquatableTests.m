//
//  PCGestureEquatableTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 14-12-29.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "UITapGestureRecognizer+PCGestureEquatable.h"
#import "UISwipeGestureRecognizer+PCGestureEquatable.h"
#import "UILongPressGestureRecognizer+PCGestureEquatable.h"
#import "UIPanGestureRecognizer+PCGestureEquatable.h"
#import "PCPinchDirectionGestureRecognizer+PCGestureEquatable.h"
#import "UIRotationGestureRecognizer+PCGestureEquatable.h"

SPEC_BEGIN(PCGestureEquatableTests)

describe(@"PCGestureEquatable", ^{
    describe(@"UITapGestureRecognizer", ^{
        __block UITapGestureRecognizer *recognizer;
        beforeEach(^{
            recognizer = [UITapGestureRecognizer new];
            recognizer.numberOfTapsRequired = 1;
            recognizer.numberOfTouchesRequired = 1;
        });

        specify(^{
            [[theValue([recognizer pc_isEqualConfiguration:nil]) should] beNo];
        });

        context(@"when compared with a different kind of object", ^{
            specify(^{
                [[theValue([recognizer pc_isEqualConfiguration:[NSObject new]]) should] beNo];
            });
        });

        context(@"when compared with a tap recognizer", ^{
            __block UITapGestureRecognizer *recognizer2;
            beforeEach(^{
                recognizer2 = [UITapGestureRecognizer new];
            });

            context(@"with different tap or touch counts", ^{
                beforeEach(^{
                    recognizer2.numberOfTapsRequired = 3;
                    recognizer2.numberOfTouchesRequired = 2;
                });

                specify(^{
                    [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beNo];
                });
            });

            context(@"with the same tap and touch count", ^{
                beforeEach(^{
                    recognizer2.numberOfTapsRequired = 1;
                    recognizer2.numberOfTouchesRequired = 1;
                });

                specify(^{
                    [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beYes];
                });
            });
        });
    });

    describe(@"UISwipeGestureRecognizer", ^{
        __block UISwipeGestureRecognizer *recognizer;
        beforeEach(^{
            recognizer = [UISwipeGestureRecognizer new];
            recognizer.direction = UISwipeGestureRecognizerDirectionDown;
            recognizer.numberOfTouchesRequired = 1;
        });

        specify(^{
            [[theValue([recognizer pc_isEqualConfiguration:nil]) should] beNo];
        });

        context(@"when compared with a different kind of object", ^{
            specify(^{
                [[theValue([recognizer pc_isEqualConfiguration:[NSObject new]]) should] beNo];
            });
        });

        context(@"when compared with a swipe recognizer", ^{
            __block UISwipeGestureRecognizer *recognizer2;
            beforeEach(^{
                recognizer2 = [UISwipeGestureRecognizer new];
            });

            context(@"with different tap or touch counts", ^{
                beforeEach(^{
                    recognizer2.direction = UISwipeGestureRecognizerDirectionUp;
                    recognizer2.numberOfTouchesRequired = 2;
                });

                specify(^{
                    [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beNo];
                });
            });

            context(@"with the same direction and touch count", ^{
                beforeEach(^{
                    recognizer2.direction = UISwipeGestureRecognizerDirectionDown;
                    recognizer2.numberOfTouchesRequired = 1;
                });

                specify(^{
                    [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beYes];
                });
            });
        });
    });

    describe(@"UILongPressGestureRecognizer", ^{
        __block UILongPressGestureRecognizer *recognizer;
        beforeEach(^{
            recognizer = [UILongPressGestureRecognizer new];
            recognizer.numberOfTapsRequired = 1;
            recognizer.numberOfTouchesRequired = 1;
        });

        specify(^{
            [[theValue([recognizer pc_isEqualConfiguration:nil]) should] beNo];
        });

        context(@"when compared with a different kind of object", ^{
            specify(^{
                [[theValue([recognizer pc_isEqualConfiguration:[NSObject new]]) should] beNo];
            });
        });

        context(@"when compared with a long press recognizer", ^{
            __block UILongPressGestureRecognizer *recognizer2;
            beforeEach(^{
                recognizer2 = [UILongPressGestureRecognizer new];
            });

            context(@"with different tap or touch counts", ^{
                beforeEach(^{
                    recognizer2.numberOfTapsRequired = 3;
                    recognizer2.numberOfTouchesRequired = 2;
                });

                specify(^{
                    [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beNo];
                });
            });

            context(@"with the same direction and touch count", ^{
                beforeEach(^{
                    recognizer2.numberOfTapsRequired = 1;
                    recognizer2.numberOfTouchesRequired = 1;
                });

                specify(^{
                    [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beYes];
                });
            });
        });
    });

    describe(@"UIPanGestureRecognizer", ^{
        __block UIPanGestureRecognizer *recognizer;
        beforeEach(^{
            recognizer = [UIPanGestureRecognizer new];
        });

        specify(^{
            [[theValue([recognizer pc_isEqualConfiguration:nil]) should] beNo];
        });

        context(@"when compared with a different kind of object", ^{
            specify(^{
                [[theValue([recognizer pc_isEqualConfiguration:[NSObject new]]) should] beNo];
            });
        });

        context(@"when compared with a pan recognizer", ^{
            __block UIPanGestureRecognizer *recognizer2;
            beforeEach(^{
                recognizer2 = [UIPanGestureRecognizer new];
            });

            specify(^{
                [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beYes];
            });
        });
    });

    describe(@"PCPinchDirectionGestureRecognizer", ^{
        __block PCPinchDirectionGestureRecognizer *recognizer;
        beforeEach(^{
            recognizer = [PCPinchDirectionGestureRecognizer new];
            recognizer.pinchDirection = PCPinchDirectionOpen;
        });

        specify(^{
            [[theValue([recognizer pc_isEqualConfiguration:nil]) should] beNo];
        });

        context(@"when compared with a different kind of object", ^{
            specify(^{
                [[theValue([recognizer pc_isEqualConfiguration:[NSObject new]]) should] beNo];
            });
        });

        context(@"when compared with a pinch recognizer", ^{
            __block PCPinchDirectionGestureRecognizer *recognizer2;
            beforeEach(^{
                recognizer2 = [PCPinchDirectionGestureRecognizer new];
            });

            context(@"with different tap or touch counts", ^{
                beforeEach(^{
                    recognizer2.pinchDirection = PCPinchDirectionClosed;
                });

                specify(^{
                    [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beNo];
                });
            });

            context(@"with the same direction and touch count", ^{
                beforeEach(^{
                    recognizer2.pinchDirection = PCPinchDirectionOpen;
                });

                specify(^{
                    [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beYes];
                });
            });
        });
    });

    describe(@"UIRotationGestureRecognizer", ^{
        __block UIRotationGestureRecognizer *recognizer;
        beforeEach(^{
            recognizer = [UIRotationGestureRecognizer new];
        });

        specify(^{
            [[theValue([recognizer pc_isEqualConfiguration:nil]) should] beNo];
        });

        context(@"when compared with a different kind of object", ^{
            specify(^{
                [[theValue([recognizer pc_isEqualConfiguration:[NSObject new]]) should] beNo];
            });
        });

        context(@"when compared with a rotation recognizer", ^{
            __block UIRotationGestureRecognizer *recognizer2;
            beforeEach(^{
                recognizer2 = [UIRotationGestureRecognizer new];
            });

            specify(^{
                [[theValue([recognizer pc_isEqualConfiguration:recognizer2]) should] beYes];
            });
        });
    });
});

SPEC_END
