//
//  PCInspectorTabBarButtonCell.m
//  SpriteBuilder
//
//  Created by Brandon on 2014-03-24.
//
//

#import "PCInspectorTabBarButtonCell.h"
#import "NSImage+DrawAsTemplate.h"

@implementation PCInspectorTabBarButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    // Don't want to draw a bezel
    return;
}

- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    CGFloat alpha = 0.2;

    if ([[controlView window] isKeyWindow]) {
        alpha = 0.5;
    }

    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    BOOL selected = ((NSButton *)controlView).state == NSOnState;
    BOOL enabled = [(NSControl *)controlView isEnabled];
    [self drawCenteredImage:image inFrame:frame alpha:alpha selected:selected enabled:enabled];
}

- (void)drawCenteredImage:(NSImage*)image inFrame:(NSRect)frame alpha:(CGFloat)alpha selected:(BOOL)selected enabled:(BOOL)enabled {
    CGSize imageSize = [image size];
    CGFloat x = frame.origin.x + (frame.size.width - imageSize.width) / 2.0;
    CGFloat y = frame.origin.y + (frame.size.height - imageSize.height) / 2.0;
    CGRect rect = CGRectIntegral(NSMakeRect(x, y + 1, imageSize.width, imageSize.height));
    [image rp_drawAsTemplateInRect:rect inView:self.controlView highlighted:selected enabled:enabled];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    CGSize size = frame.size;
    size.height = CGRectGetHeight(controlView.bounds) - 30.0f;
    frame.size = size;
    CGPoint origin = frame.origin;
    origin.y = 30.0f;
    frame.origin = origin;

    NSMutableAttributedString *adjustedTitle = [title mutableCopy];
    [adjustedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [title length])];

    [adjustedTitle drawInRect:frame];

    return frame;
}

@end
