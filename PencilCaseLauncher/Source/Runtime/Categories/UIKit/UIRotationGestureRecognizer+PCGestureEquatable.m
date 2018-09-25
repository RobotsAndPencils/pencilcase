//
//  UIRotationGestureRecognizer+PCGestureEquatable.m
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import "UIRotationGestureRecognizer+PCGestureEquatable.h"

@implementation UIRotationGestureRecognizer (PCGestureEquatable)

- (BOOL)pc_isEqualConfiguration:(id)recognizer {
    if (recognizer == self) return YES;
    return [recognizer isKindOfClass:[self class]];
}

@end
