//
//  UIGestureRecognizer+JSEvents
//  PCPlayer
//
//  Created by brandon on 2014-02-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "UIGestureRecognizer+JSEvents.h"
#import "SKNode+JavaScript.h"
#import "PCAppViewController.h"
#import "PCJSContext.h"
#import "NSString+CamelCase.h"
#import "PCPinchDirectionGestureRecognizer.h"
#import "PCTouchRecognizer.h"
#import <objc/runtime.h>

@implementation UIGestureRecognizer (JSEvents)

#pragma mark - Public

- (instancetype)initWithJSEventHandlers {
    self = [self initWithTarget:self action:@selector(pc_handleTouchEventWithRecognizer:)];

    if (self) {
        self.cancelsTouchesInView = NO;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
    }

    return self;
}

#pragma mark - Private

- (SKView *)pc_skView {
    return [PCAppViewController lastCreatedInstance].spriteKitView;
}

- (CGPoint)pc_convertSKViewPointToScene:(CGPoint)point {
    return [[self pc_skView] convertPoint:point toScene:[self pc_skView].scene];
}

// Posts a notification for a JS event to be fired in the context on the recognizer's node
// An easy win here would be to also restrict the number of recognizers of a given type/configuration to one
- (void)pc_handleTouchEventWithRecognizer:(UIGestureRecognizer *)recognizer {
    NSString *eventName = [recognizer pc_eventNameForState:recognizer.state];
    NSArray *arguments = [recognizer pc_arguments];

    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:recognizer.pc_node userInfo:@{
        PCJSContextEventNotificationEventNameKey: eventName,
        PCJSContextEventNotificationArgumentsKey: arguments
    }];
}

+ (NSString *)pc_stringForDirection:(UISwipeGestureRecognizerDirection)direction {
    switch (direction) {
        case UISwipeGestureRecognizerDirectionRight:
            return @"right";
        case UISwipeGestureRecognizerDirectionLeft:
            return @"left";
        case UISwipeGestureRecognizerDirectionUp:
            return @"up";
        case UISwipeGestureRecognizerDirectionDown:
            return @"down";
        default:
            return @"";
    }
}

+ (NSString *)pc_stringForRecognizerState:(UIGestureRecognizerState)state {
    NSString *name;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            name = @"Began";
            break;
        case UIGestureRecognizerStateChanged:
            name = @"Changed";
            break;
        case UIGestureRecognizerStateEnded:
            name = @"Ended";
            break;
        case UIGestureRecognizerStateCancelled:
            name = @"Ended";
            break;
        default:
            name = @"";
            break;
    }
    return name;
}

- (NSString *)pc_eventNameForState:(UIGestureRecognizerState)state {
    NSString *eventNameSuffix = [[self class] pc_stringForRecognizerState:state];
    NSString *eventName = [[self class] pc_jsRecognizerName];
    if ([[self class] pc_continuous]) {
        eventName = [eventName stringByAppendingString:eventNameSuffix];
    }

    return eventName;
}

- (NSArray *)pc_arguments {
    NSMutableArray *arguments = [NSMutableArray array];

    // Location
    CGPoint location = [self pc_convertSKViewPointToScene:[self locationInView:[self pc_skView]]];
    [arguments addObject:[NSValue valueWithCGPoint:location]];

    // Swipe direction
    if ([self isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swipeRecognizer = (UISwipeGestureRecognizer *)self;
        UISwipeGestureRecognizerDirection direction = swipeRecognizer.direction;
        [arguments addObject:[[self class] pc_stringForDirection:direction]];
    }

    // Num Fingers
    if ([self isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swipeRecognizer = (UISwipeGestureRecognizer *)self;
        [arguments addObject:@(swipeRecognizer.numberOfTouches)];
    }
    if ([self isKindOfClass:[PCTouchRecognizer class]]) {
        PCTouchRecognizer *touchRecognizer = (PCTouchRecognizer *)self;
        [arguments addObject:@(touchRecognizer.numberOfTouches)];
    }

    // Taps
    if ([self isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)self;
        [arguments addObject:@(tapRecognizer.numberOfTapsRequired)];
        [arguments addObject:@(tapRecognizer.numberOfTouches)];
    }

    // Long Press
    if ([self isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *longPressRecognizer = (UILongPressGestureRecognizer *)self;
        [arguments addObject:@(longPressRecognizer.numberOfTapsRequired)];
        [arguments addObject:@(longPressRecognizer.numberOfTouches)];
    }

    // Pinch gesture direction
    if ([self isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinchGestureRecognizer = (UIPinchGestureRecognizer *)self;
        BOOL isOpening = pinchGestureRecognizer.velocity >= 0;
        NSString *direction = isOpening ? @"open" : @"close";
        [arguments addObject:direction];
    }

    // Pan translation and velocity
    if ([self isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *swipeRecognizer = (UIPanGestureRecognizer *)self;

        CGPoint translation = [self pc_convertSKViewPointToScene:[swipeRecognizer translationInView:[self pc_skView]]];
        [arguments addObject:[NSValue valueWithCGPoint:translation]];

        CGPoint velocity = [self pc_convertSKViewPointToScene:[swipeRecognizer velocityInView:[self pc_skView]]];
        [arguments addObject:[NSValue valueWithCGPoint:velocity]];
    }

    if (self.pc_node) {
        [arguments addObject:self.pc_node];
    }

    return [arguments copy];
};

// e.g. UILongPressGestureRecognizer -> longPress
+ (NSString *)pc_jsRecognizerName {
    NSString *name = NSStringFromClass([self class]);
    name = [name stringByReplacingOccurrencesOfString:@"UI" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"GestureRecognizer" withString:@""];
    name = [name pc_lowerCamelCaseString];
    return name;
}

// Returns whether this class of recognizer is a continuous recognizer, per the documentation
// Note that taps are discrete, but will still fire events for each recognizer state
// We simplify the JS API though, and will only fire an event for ended, so as to be consistent with swipe
+ (BOOL)pc_continuous {
    BOOL isSwipe = [self isSubclassOfClass:[UISwipeGestureRecognizer class]];
    BOOL isTap = [self isSubclassOfClass:[UITapGestureRecognizer class]];
    return !(isSwipe || isTap);
}

#pragma mark - Properties

- (void)setPc_node:(SKNode *)node {
    objc_setAssociatedObject(self, @"pc_node", node, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SKNode *)pc_node {
    return objc_getAssociatedObject(self, @"pc_node");
}

@end
