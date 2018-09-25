//
//  SKTransition+FromString.m
//  
//
//  Created by Brandon Evans on 2014-10-06.
//
//

#import "SKTransition+FromString.h"

@implementation SKTransition (FromString)

+ (SKTransition *)transitionFromString:(NSString *)transitionName withDuration:(CGFloat)duration {
    if (duration <= 0) return nil;

    if ([transitionName isEqualToString:@"Slide Left"]) {
        return [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:duration];
    }
    if ([transitionName isEqualToString:@"Slide Right"]) {
        return [SKTransition pushWithDirection:SKTransitionDirectionRight duration:duration];
    }
    if ([transitionName isEqualToString:@"Slide Down"]) {
        return [SKTransition pushWithDirection:SKTransitionDirectionDown duration:duration];
    }
    if ([transitionName isEqualToString:@"Slide Up"]) {
        return [SKTransition pushWithDirection:SKTransitionDirectionUp duration:duration];
    }
    if ([transitionName isEqualToString:@"Fade In"]) {
        return [SKTransition fadeWithDuration:duration];
    }
    if ([transitionName isEqualToString:@"Cross Fade"]) {
        return [SKTransition crossFadeWithDuration:duration];
    }
    if ([transitionName isEqualToString:@"Instant"]) {
        return nil;
    }
    return nil;
}

@end
