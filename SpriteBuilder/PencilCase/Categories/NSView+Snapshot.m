//
//  NSView+Snapshot.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2015-02-24.
//
//

#import "NSView+Snapshot.h"

@implementation NSView (Snapshot)

- (NSImage *)pc_snapshot {
    BOOL wasHidden = self.isHidden;
    CGFloat wantedLayer = self.wantsLayer;

    self.hidden = NO;
    self.wantsLayer = YES;

    NSImage *image = [[NSImage alloc] initWithSize:self.bounds.size];
    [image lockFocus];
    CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;
    [self.layer renderInContext:context];
    [image unlockFocus];

    self.wantsLayer = wantedLayer;
    self.hidden = wasHidden;

    return image;
}

@end
