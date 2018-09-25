//
//  PCOverlayWindow.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-12.
//
//

#import "PCOverlayWindow.h"

@implementation PCOverlayWindow

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.mouseDownHandler) self.mouseDownHandler();
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

@end
