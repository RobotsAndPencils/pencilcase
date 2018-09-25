//
//  UIView+FirstResponder.m
//  PencilCaseLauncher
//
//  Created by Stephen Gazzard on 2015-04-24.
//
//

#import "UIView+Snapshot.h"

@implementation UIView (Snapshot)

- (id)findFirstResponderInViewTree {
    if (self.isFirstResponder) return self;
    for (UIView *subView in self.subviews) {
        id responder = [subView findFirstResponderInViewTree];
        if (responder) return responder;
    }
    return nil;
}

@end
