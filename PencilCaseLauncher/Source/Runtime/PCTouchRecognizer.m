//
//  PCTouchRecognizer.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-02-03.
//
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "PCTouchRecognizer.h"

@implementation PCTouchRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        self.numberOfTouchesRequired = 1;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count != self.numberOfTouchesRequired) return;

    self.state = UIGestureRecognizerStateBegan;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateChanged;
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateEnded;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateCancelled;
    [super touchesCancelled:touches withEvent:event];
}

+ (BOOL)pc_isContinuous {
    return YES;
}

+ (NSString *)pc_jsRecognizerName {
    return @"touch";
}

#pragma mark - PCGestureEquatable

- (BOOL)pc_isEqualConfiguration:(id)recognizer {
    if (recognizer == self) return YES;
    if (![recognizer isKindOfClass:[self class]]) return NO;
    PCTouchRecognizer *touchRecognizer = (PCTouchRecognizer *)recognizer;
    return touchRecognizer.numberOfTouchesRequired == self.numberOfTouchesRequired;
}

@end
