//
//  UISwipeGestureRecognizer+PCGestureEquatable.m
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import "UISwipeGestureRecognizer+PCGestureEquatable.h"

@implementation UISwipeGestureRecognizer (PCGestureEquatable)

- (BOOL)pc_isEqualConfiguration:(id)recognizer {
    if (recognizer == self) return YES;
    if (![recognizer isKindOfClass:[self class]]) return NO;

    UISwipeGestureRecognizer *swipeGestureRecognizer = (UISwipeGestureRecognizer *)recognizer;
    return swipeGestureRecognizer.direction == self.direction && swipeGestureRecognizer.numberOfTouchesRequired == self.numberOfTouchesRequired;
}
@end
