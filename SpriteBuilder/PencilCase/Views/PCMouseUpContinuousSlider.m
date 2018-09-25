//
//  PCMouseUpContinuousSlider.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-05-30.
//
//

#import "PCMouseUpContinuousSlider.h"

@implementation PCMouseUpContinuousSlider

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if (self.mouseUpHandler) self.mouseUpHandler(theEvent);
}

@end
