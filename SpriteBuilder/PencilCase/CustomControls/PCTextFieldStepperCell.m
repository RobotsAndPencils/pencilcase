//
//  PCTextFieldStepperCell.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-06-18.
//
//

#import "PCTextFieldStepperCell.h"
#import "PCTextStepperTextView.h"

const NSInteger PADDING_MARGIN = 5;

@interface PCTextFieldStepperCell ()

@property (strong, nonatomic) PCTextStepperTextView *fieldEditor;

@end

@implementation PCTextFieldStepperCell

- (id)init {
    self = [super init];
    if (self) {
        self.alignment = NSCenterTextAlignment;
    }
    return self;
}

- (NSTextView *)fieldEditorForView:(NSView *)aControlView {
    if (!self.fieldEditor) {
        self.fieldEditor = [[PCTextStepperTextView alloc] init];
        self.fieldEditor.fieldEditor = YES;
    }
    return self.fieldEditor;
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    
    //Padding on left side
    titleFrame.origin.x = PADDING_MARGIN;
    
    //Padding on right side
    titleFrame.size.width -= (2 * PADDING_MARGIN );
    return titleFrame;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
    NSRect textFrame = aRect;
    textFrame.origin.x += PADDING_MARGIN;
    textFrame.size.width -= (2 * PADDING_MARGIN);
    [super editWithFrame: textFrame inView: controlView editor:textObj delegate:anObject event: theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
    NSRect textFrame = aRect;
    textFrame.origin.x += PADDING_MARGIN;
    textFrame.size.width -= (2 * PADDING_MARGIN);
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}


#pragma mark Public Methods

- (void)setDragDisabled:(BOOL) disabled {
    self.fieldEditor.dragDisabled = disabled;
}




@end
