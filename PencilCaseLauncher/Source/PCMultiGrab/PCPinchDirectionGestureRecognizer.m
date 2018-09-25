//
//  PCPinchDirectionGesutureRecognizer.m
//  
//
//  Created by Orest Nazarewycz on 2014-11-03.
//
//

#import "PCPinchDirectionGestureRecognizer.h"

@implementation PCPinchDirectionGestureRecognizer

- (void)setState:(UIGestureRecognizerState)state {
    switch (self.pinchDirection) {
        case PCPinchDirectionOpen:
            if (self.scale > 1) {
                [super setState:state];
            } else {
                return;
            }
            
        case PCPinchDirectionClosed:
        default:
            if (self.scale < 1) {
                [super setState:state];
            } else {
                return;
            }
    }
}

+ (NSString *)pc_jsRecognizerName {
    return @"pinch";
}

@end
