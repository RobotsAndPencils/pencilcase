//
//  PCMultiDragGestureRecognizer.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-30.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCMultiDragGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <RXCollections/RXCollection.h>
#import <objc/runtime.h>
#import "PCMultiDragTouch.h"

@interface PCMultiDragGestureRecognizer () <UIGestureRecognizerDelegate>

@property (strong, nonatomic, readwrite) NSMutableArray *activeTouches;

@end

@implementation PCMultiDragGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        self.activeTouches = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    for (PCMultiDragTouch *touch in self.activeTouches) {
        UIPanGestureRecognizer *pan = touch.gestureRecognizer;
        pan.delegate = nil;
        [pan.view removeGestureRecognizer:pan];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        PCMultiDragTouch *drag = [[PCMultiDragTouch alloc] init];
        drag.touch = touch;
        drag.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        drag.gestureRecognizer.delegate = self;
        [drag.gestureRecognizer touchesBegan:touches withEvent:event];
        [self.activeTouches addObject:drag];
    }
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *movedTouches = [self.activeTouches rx_filterWithBlock:^BOOL(PCMultiDragTouch *each) {
        return [touches containsObject:each.touch];
    }];
    for (PCMultiDragTouch *touch in movedTouches) {
        UIPanGestureRecognizer *pan = touch.gestureRecognizer;
        [pan touchesMoved:touches withEvent:event];
    }
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *endedTouches = [self.activeTouches rx_filterWithBlock:^BOOL(PCMultiDragTouch *each) {
        return [touches containsObject:each.touch];
    }];

    [self.activeTouches removeObjectsInArray:endedTouches];

    if ([self.activeTouches count] == 0) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *endedTouches = [self.activeTouches rx_filterWithBlock:^BOOL(PCMultiDragTouch *each) {
        return [touches containsObject:each.touch];
    }];

    [self.activeTouches removeObjectsInArray:endedTouches];

    if ([self.activeTouches count] == 0) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

#pragma mark - Public

#pragma mark - Private

- (void)handleGesture:(UIPanGestureRecognizer *)gesture {}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // We will send touches to our pans manually.
    return NO;
}

@end
