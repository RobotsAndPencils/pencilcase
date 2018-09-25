//
//  PCRecentsWindow.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 3/22/2014.
//
//

#import "PCRecentsWindow.h"

@interface PCRecentsWindow ()

@property (nonatomic, assign) NSPoint mouseDownLocation;

@end

const NSInteger pcRecentsFrameOriginOffsetX = 15;
const NSInteger pcRecentsFrameOriginOffsetY = 16;
const NSInteger pcRecentsFrameWidthCurveOffset = 31;
const NSInteger pcRecentsFrameHeightCurveOffset = 35;

@implementation PCRecentsWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation];
    if (self)
    {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}

- (NSWindowStyleMask)styleMask {
    return NSBorderlessWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask  | NSTitledWindowMask;
}

- (void) setContentView:(NSView *)aView {
    
    NSView *backView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    backView.wantsLayer             = YES;
    backView.layer.masksToBounds    = NO;
    backView.layer.shadowColor      = [NSColor shadowColor].CGColor;
    backView.layer.shadowOpacity    = 0.5;
    backView.layer.shadowOffset     = CGSizeMake(0, -3);
    backView.layer.shadowRadius     = 6.0;
    
    
    NSView *frontView = [aView initWithFrame:CGRectMake(backView.frame.origin.x + pcRecentsFrameOriginOffsetX, backView.frame.origin.y + pcRecentsFrameOriginOffsetY, backView.frame.size.width - pcRecentsFrameWidthCurveOffset, (backView.frame.size.height - pcRecentsFrameHeightCurveOffset))];
    [backView addSubview: frontView];
    frontView.layer.cornerRadius    = 6;
    frontView.layer.masksToBounds   = YES;
    frontView.layer.borderColor     = [[NSColor clearColor] CGColor];
    frontView.layer.borderWidth     = 0.0;
    
    [super setContentView:backView];
    
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent{
    self.mouseDownLocation = [self mouseLocationOutsideOfEventStream];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    CGPoint currentMouseLocation = [self mouseLocationOutsideOfEventStream];
    CGPoint newOrigin = CGPointMake(self.frame.origin.x + currentMouseLocation.x - self.mouseDownLocation.x, self.frame.origin.y + currentMouseLocation.y - self.mouseDownLocation.y);
    [self setFrameOrigin:newOrigin];
}

@end
