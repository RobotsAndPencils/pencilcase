//
//  PCPassthroughView.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-30.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCPassthroughView.h"

@implementation PCPassthroughView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) return nil;
    return hit;
}

@end
