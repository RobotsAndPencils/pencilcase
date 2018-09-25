//
//  UITapGestureRecognizer+PCGestureEquatable.m
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import "UITapGestureRecognizer+PCGestureEquatable.h"

@implementation UITapGestureRecognizer (PCGestureEquatable)

- (BOOL)pc_isEqualConfiguration:(id)recognizer {
    if (recognizer == self) return YES;
    if (![recognizer isKindOfClass:[self class]]) return NO;

    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)recognizer;
    return tapGestureRecognizer.numberOfTapsRequired == self.numberOfTapsRequired && tapGestureRecognizer.numberOfTouchesRequired == self.numberOfTouchesRequired;
}

@end
