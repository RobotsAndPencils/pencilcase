//
//  PCInspectableView.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-13.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCInspectableView.h"

@implementation PCInspectableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGRect rect = CGRectInset(self.bounds, self.borderWidth * 0.5, self.borderWidth * 0.5);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.cornerRadius yRadius:self.cornerRadius];
    [self.backgroundColor setFill];
    [path fill];

    if (self.borderWidth > 0) {
        path.lineWidth = self.borderWidth;
        [self.borderColor setStroke];
        [path stroke];
    }
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

- (void)setBorderColor:(NSColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay:YES];
}

- (void)setBorderWidth:(NSInteger)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay:YES];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay:YES];
}

@end
