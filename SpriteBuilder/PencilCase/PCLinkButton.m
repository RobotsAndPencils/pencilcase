//
//  PCLinkButton.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-20.
//
//

#import "PCLinkButton.h"

@implementation PCLinkButton

- (void)awakeFromNib {
    _myTrackingRectTag = [self addTrackingRect:[self bounds]
                                         owner:self
                                      userData:NULL
                                  assumeInside:YES];
}

- (void)dealloc {
    [self removeTrackingRect:_myTrackingRectTag];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [[NSCursor arrowCursor] set];
}

@end
