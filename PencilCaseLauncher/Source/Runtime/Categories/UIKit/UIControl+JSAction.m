//
//  UIControl+JSAction.m
//  PencilCaseJSDemo
//
//  Created by Brandon on 12/27/2013.
//  Copyright (c) 2013 Robots and Pencils. All rights reserved.
//
//  Based on https://github.com/steamclock/jscalc/tree/master/iOS/JSCalc
//  Might be able to have more than one handler with some runtime magic
//  Initial support for just touch up inside is probably fine though
//

#import "UIControl+JSAction.h"

@import ObjectiveC;

@implementation UIControl (JSAction)

static const char *BlockKey = "SCBlocks";

- (void)addEventHandler:(JSValue *)handler forControlEvents:(UIControlEvents)controlEvents {
    JSManagedValue *managedHandler = [JSManagedValue managedValueWithValue:handler andOwner:self];
    objc_setAssociatedObject(self, &BlockKey, managedHandler, OBJC_ASSOCIATION_RETAIN);
    [self addTarget:self action:@selector(handleControlEvent) forControlEvents:controlEvents];
}

- (void)setTouchUpInsideHandler:(JSValue *)handler {
    [self addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleControlEvent {
    JSManagedValue *managedHandler = objc_getAssociatedObject(self, &BlockKey);
    if (managedHandler) {
        [managedHandler.value callWithArguments:@[]];
    }
}

@end