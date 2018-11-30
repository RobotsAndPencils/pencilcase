//
//  PCPaddedSecureTextFieldCell.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-15.
//
//

#import "PCPaddedSecureTextFieldCell.h"

@implementation PCPaddedSecureTextFieldCell

- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame {
    return NSMakeRect(frame.origin.x + self.xPadding, frame.origin.y + self.yPadding, frame.size.width - self.xPadding, frame.size.height - self.yPadding);
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)editor delegate:(id)delegate event:(NSEvent *)event {
    [super editWithFrame:[self adjustedFrameToVerticallyCenterText:aRect] inView:controlView editor:editor delegate:delegate event:event];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)editor delegate:(id)delegate start:(NSInteger)start length:(NSInteger)length {
    [super selectWithFrame:[self adjustedFrameToVerticallyCenterText:aRect] inView:controlView editor:editor delegate:delegate start:start length:length];
}

- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)view {
    [super drawInteriorWithFrame:[self adjustedFrameToVerticallyCenterText:frame] inView:view];
}

@end
