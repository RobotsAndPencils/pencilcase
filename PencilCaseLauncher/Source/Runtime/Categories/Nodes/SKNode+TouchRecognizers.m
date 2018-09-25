//
//  SKNode(TouchRecognizers)
//  PCPlayer
//
//  Created by brandon on 2014-02-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <PencilCaseLauncher/PCPinchDirectionGestureRecognizer.h>
#import "SKNode+TouchRecognizers.h"
#import "UIGestureRecognizer+JSEvents.h"
#import "UIGestureRecognizer+PCGestureEquatable.h"
#import "SKNode+SFGestureRecognizers.h"
#import "PCTouchRecognizer.h"

@implementation SKNode (TouchRecognizers)

#pragma mark - Public

- (void)pc_addTapRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches taps:(NSUInteger)numberOfTaps {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithJSEventHandlers];
    tapGestureRecognizer.numberOfTouchesRequired = numberOfTouches;
    tapGestureRecognizer.numberOfTapsRequired = numberOfTaps;
    [self pc_addRecognizer:tapGestureRecognizer];
}

- (void)pc_addLongPressRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches taps:(NSUInteger)numberOfTaps {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithJSEventHandlers];
    recognizer.numberOfTouchesRequired = numberOfTouches;
    recognizer.numberOfTapsRequired = numberOfTaps;
    [self pc_addRecognizer:recognizer];
}

- (void)pc_addPinchGestureRecognizerForDirection:(NSString *)pinchDirectionName {
    PCPinchDirection direction;
    if ([pinchDirectionName isEqualToString:@"open"]) {
        direction = PCPinchDirectionOpen;
    }
    else if ([pinchDirectionName isEqualToString:@"close"]) {
        direction = PCPinchDirectionClosed;
    }
    else {
        return;
    }

    PCPinchDirectionGestureRecognizer *pinchDirectonGestureRecognizer = [[PCPinchDirectionGestureRecognizer alloc] initWithJSEventHandlers];
    pinchDirectonGestureRecognizer.pinchDirection = direction;
    [self pc_addRecognizer:pinchDirectonGestureRecognizer];
}

- (void)pc_addSwipeRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches direction:(NSString *)directionString {
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithJSEventHandlers];
    UISwipeGestureRecognizerDirection direction;
    if ([directionString isEqualToString:@"up"]) {
        direction = UISwipeGestureRecognizerDirectionUp;
    }
    else if ([directionString isEqualToString:@"down"]) {
        direction = UISwipeGestureRecognizerDirectionDown;
    }
    else if ([directionString isEqualToString:@"right"]) {
        direction = UISwipeGestureRecognizerDirectionRight;
    }
    else if ([directionString isEqualToString:@"left"]) {
        direction = UISwipeGestureRecognizerDirectionLeft;
    }
    else {
        return;
    }
    swipeGestureRecognizer.direction = direction;
    swipeGestureRecognizer.numberOfTouchesRequired = numberOfTouches;
    [self pc_addRecognizer:swipeGestureRecognizer];
}

- (void)addPanRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithJSEventHandlers];
    [self pc_addRecognizer:panGestureRecognizer];
}

- (void)pc_addTouchRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches {
    PCTouchRecognizer *touchRecognizer = [[PCTouchRecognizer alloc] initWithJSEventHandlers];
    touchRecognizer.numberOfTouchesRequired = numberOfTouches;
    [self pc_addRecognizer:touchRecognizer];
}

#pragma mark - Private

- (void)pc_addRecognizer:(UIGestureRecognizer *)recognizer {
    if ([self pc_hasEquivalentRecognizer:recognizer]) return;

    recognizer.cancelsTouchesInView = NO;
    [recognizer setValue:self forKey:@"pc_node"];
    [self sf_addGestureRecognizer:recognizer];
}

- (BOOL)pc_hasEquivalentRecognizer:(UIGestureRecognizer *)recognizer {
    BOOL hasMatchingRecognizer = NO;
    for (UIGestureRecognizer *eachRecognizer in self.sf_gestureRecognizers) {
        if ([eachRecognizer pc_isEqualConfiguration:recognizer]) {
            hasMatchingRecognizer = YES;
            break;
        }
    }
    return hasMatchingRecognizer;
}

@end
