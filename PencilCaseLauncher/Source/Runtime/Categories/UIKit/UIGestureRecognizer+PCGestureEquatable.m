//
//  UIGestureRecognizer+PCGestureEquatable.m
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import "UIGestureRecognizer+PCGestureEquatable.h"

@implementation UIGestureRecognizer (PCGestureEquatable)

- (BOOL)pc_isEqualConfiguration:(id)recognizer {
    return [self isEqual:recognizer];
}

@end
