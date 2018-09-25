//
//  PCUserProjectTableRowView.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-21.
//
//

#import "PCUserProjectTableRowView.h"
#import "NSColor+HexColors.h"

@implementation PCUserProjectTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    NSColor *selectionColor = [NSColor pc_colorFromHexRGB:@"F6F6F6"];
    
    switch (self.selectionHighlightStyle) {
        case NSTableViewSelectionHighlightStyleRegular: {
            if (self.selected) {
                if (!self.emphasized) {
                    selectionColor = [selectionColor colorWithAlphaComponent:0.5];
                }
                self.emphasized = NO;
                [selectionColor set];
                NSRect bounds = self.bounds;
                const NSRect *rects = NULL;
                NSInteger count = 0;
                [self getRectsBeingDrawn:&rects count:&count];
                for (NSInteger i = 0; i < count; i++) {
                    NSRect rect = NSIntersectionRect(bounds, rects[i]);
                    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
                }
            }
            break;
        }
        default: {
            [super drawSelectionInRect:dirtyRect];
            break;
        }
    }
}


@end
