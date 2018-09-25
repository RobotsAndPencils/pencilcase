//
//  PCFocusRingView.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-06-23.
//
//

#import "PCFocusRingView.h"

@implementation PCFocusRingView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.wantsLayer = YES;
        self.ringColor = [NSColor keyboardFocusIndicatorColor];
        self.layer.borderColor = self.ringColor.CGColor;
        self.layer.borderWidth = 2;
    }
    return self;
}

- (void)setRingColor:(NSColor *)ringColor {
    _ringColor = ringColor;
    self.layer.borderColor = _ringColor.CGColor;
}

@end