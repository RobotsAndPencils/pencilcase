//
//  UIPinchGestureRecognizer+PCGestureEquatable.m
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import "PCPinchDirectionGestureRecognizer+PCGestureEquatable.h"
#import "PCPinchDirectionGestureRecognizer.h"

@implementation PCPinchDirectionGestureRecognizer (PCGestureEquatable)

- (BOOL)pc_isEqualConfiguration:(id)recognizer {
    if (![recognizer isKindOfClass:[self class]]) return NO;
    if (recognizer == self) return YES;

    PCPinchDirectionGestureRecognizer *pinchGestureRecognizer = (PCPinchDirectionGestureRecognizer *)recognizer;
    return pinchGestureRecognizer.pinchDirection == self.pinchDirection;
}

@end
