//
//  PCInspectorTabBar.m
//  SpriteBuilder
//
//  Created by Brandon on 2014-03-24.
//
//

#import "PCInspectorTabBar.h"
#import "PCInspectorTabBarButtonCell.h"

@implementation PCInspectorTabBar

+ (CGFloat)SMTabBarButtonWidth {
    static CGFloat buttonWidth = 36.0f;
    return buttonWidth;
}

+ (Class)buttonCellClass {
    return [PCInspectorTabBarButtonCell class];
}

- (void)drawRect:(CGRect)rect {
    if ([[self window] isKeyWindow]) {
        static NSColor *backgroundColor = nil;
        static NSColor *borderColor = nil;
        if (!backgroundColor) {
            backgroundColor = [NSColor colorWithDeviceRed:0.93 green:0.93 blue:0.93 alpha:1.0];
            borderColor = [NSColor colorWithDeviceRed:0.70 green:0.70 blue:0.70 alpha:1.0];
        }

        // Draw background
        [backgroundColor setFill];
        [NSBezierPath fillRect:self.bounds];

        // Draw bottom border
        [borderColor setStroke];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 0.5f)];
    } else {
        static NSColor *backgroundColor = nil;
        static NSColor *borderColor = nil;
        if (!backgroundColor) {
            backgroundColor = [NSColor colorWithDeviceRed:0.97 green:0.97 blue:0.97 alpha:1.0];
            borderColor = [NSColor colorWithDeviceRed:0.70 green:0.70 blue:0.70 alpha:1.0];
        }

        // Draw background
        [backgroundColor setFill];
        [NSBezierPath fillRect:self.bounds];

        // Draw dark gray bottom border
        [borderColor setStroke];
        [NSBezierPath setDefaultLineWidth:0.0f];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 0.5f)];
    }
}

- (void)adjustSubviews {
    NSUInteger numberOfButtons = [self.barButtons count];
    CGFloat completeWidth = CGRectGetWidth(self.bounds);
    NSInteger index = 0;
    for (NSButton *button in self.barButtons) {
        button.frame = NSMakeRect(completeWidth / numberOfButtons * index, NSMinY(self.bounds), completeWidth / numberOfButtons, NSHeight(self.bounds));
        index += 1;
    }
}

- (void)setEnabled:(BOOL)enabled {
    for (NSButton *button in self.barButtons) {
        button.enabled = enabled;
    }
}

@end
