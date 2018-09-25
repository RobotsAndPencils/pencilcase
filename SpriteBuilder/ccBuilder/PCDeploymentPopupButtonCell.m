//
//  PCDeploymentPopupButtonCell.m
//  SpriteBuilder
//
//  Created by Brandon on 2014-03-24.
//
//

#import "PCDeploymentPopupButtonCell.h"

@implementation PCDeploymentPopupButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGFloat cornerRadius = 3.0f;

    // Background gradient
    [context saveGraphicsState];
    NSBezierPath *backgroundPath =
    [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.0f, 2.0f) xRadius:cornerRadius yRadius:cornerRadius];
    [backgroundPath setClip];

    NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor: [NSColor colorWithDeviceWhite:0.90f alpha:0.2f] endingColor: [NSColor colorWithDeviceWhite:0.95f alpha:0.2f]];

    [backgroundGradient drawInRect:[backgroundPath bounds] angle:270.0f];
    [context restoreGraphicsState];

    // Dark stroke
    [context saveGraphicsState];
    if ([[self.controlView window] isKeyWindow]) {
        [[NSColor colorWithDeviceWhite:0.5f alpha:1.0f] setStroke];
    }
    else {
        [[NSColor colorWithDeviceWhite:0.5f alpha:0.5f] setStroke];
    }
    [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 1.5f, 1.5f) xRadius:cornerRadius yRadius:cornerRadius] stroke];
    [context restoreGraphicsState];

    // Inner light stroke
    [context saveGraphicsState];
    [[NSColor colorWithDeviceWhite:1.0f alpha:0.4f] setStroke];
    [[NSBezierPath bezierPathWithRoundedRect:NSOffsetRect(NSInsetRect(frame, 2.5f, 1.5f), 0.0, 1.0) xRadius:cornerRadius yRadius:cornerRadius] stroke];
    [context restoreGraphicsState];

    // Draw lighter overlay if button is pressed
    if([self isHighlighted]) {
        [context saveGraphicsState];
        [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.0f, 2.0f) xRadius:cornerRadius yRadius:cornerRadius] setClip];
        [[NSColor colorWithCalibratedWhite:1.0f alpha:0.35] setFill];
        NSRectFillUsingOperation(frame, NSCompositeSourceOver);
        [context restoreGraphicsState];
    }
}

- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [super drawImageWithFrame:CGRectInset(cellFrame, 2.0, 2.0) inView:controlView];
}

- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [super drawTitleWithFrame:NSOffsetRect(cellFrame, 2.0f, 0.0f) inView:controlView];
}

@end
