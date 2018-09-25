//
//  RPJSTimers.m
//  Pods
//
//  Created by Brandon Evans on 2014-12-05.
//
//

#import "RPJSTimers.h"

@implementation RPJSTimers

+ (void)setupInContext:(JSContext *)context {
    // Variadic blocks don't expose their variadic argument to JS, so use a wrapper JS function to handle setTimeout arguments
    context[@"__timers_setTimeout"] = ^(JSValue* function, JSValue* timeout, NSArray *arguments) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([timeout toInt32] * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [function callWithArguments:arguments];
        });
    };
    [context evaluateScript:@"function setTimeout(func, delay) { var args = Array.prototype.slice.call(arguments, 2); __timers_setTimeout(func, delay, args); };"];
}

@end
