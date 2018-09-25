//
//  UIPanGestureRecognizer+PCGestureEquatable.m
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import "UIPanGestureRecognizer+PCGestureEquatable.h"

@implementation UIPanGestureRecognizer (PCGestureEquatable)

- (BOOL)pc_isEqualConfiguration:(id)recognizer {
    if (recognizer == self) return YES;
    if (![recognizer isKindOfClass:[self class]]) return NO;

    return YES;
}

@end
