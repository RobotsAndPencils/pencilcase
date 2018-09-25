//
//  SOMyEditor.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-06-18.
//
//

#import "PCTextStepperTextView.h"


@interface PCTextStepperTextView ()

@end

@implementation PCTextStepperTextView

- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container {
    if (self = [super initWithFrame:frameRect textContainer:container]) {
        self.dragDisabled = YES;
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (!self.dragDisabled) {
         [super mouseDown:theEvent];
    } else {
        self.dragDisabled = NO;
    }
}


@end
