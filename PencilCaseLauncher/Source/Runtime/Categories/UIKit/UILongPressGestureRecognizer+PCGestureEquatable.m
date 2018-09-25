//
//  UILongPressGestureRecognizer+PCGestureEquatable.m
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import "UILongPressGestureRecognizer+PCGestureEquatable.h"

@implementation UILongPressGestureRecognizer (PCGestureEquatable)

- (BOOL)pc_isEqualConfiguration:(id)recognizer {
    if (recognizer == self) return YES;
    if (![recognizer isKindOfClass:[self class]]) return NO;

    UILongPressGestureRecognizer *longPressGestureRecognizer = (UILongPressGestureRecognizer *)recognizer;
    return longPressGestureRecognizer.numberOfTapsRequired == self.numberOfTapsRequired && longPressGestureRecognizer.numberOfTouchesRequired == self.numberOfTouchesRequired;
}

@end
