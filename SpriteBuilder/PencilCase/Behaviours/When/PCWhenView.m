//
//  PCWhenView.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCWhenView.h"
#import "BehavioursStyleKit.h"

@interface PCWhenView () <NSDraggingSource, NSPasteboardWriting>

@end

@implementation PCWhenView

#pragma mark - init

- (void)awakeFromNib {
    [super awakeFromNib];
    self.allowDrag = YES;
}

#pragma mark - Super

#pragma mark Layer

- (BOOL)wantsLayer {
    return YES;
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)updateLayer {
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.layer.borderColor = [NSColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1].CGColor;
    if (self.sourceHighlighted) {
        self.layer.borderColor = [BehavioursStyleKit normalBlueColor].CGColor;
        self.layer.backgroundColor = [NSColor colorWithRed:210/255.0 green:231/255.0 blue:251/255.0 alpha:1].CGColor;
    }
    else if (self.selected) {
        self.layer.borderColor = [BehavioursStyleKit normalBlueColor].CGColor;
    }
    self.layer.borderWidth = 2;
    self.layer.cornerRadius = 10;
}

#pragma mark - Private

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self setNeedsDisplay:YES];
}

- (void)setSourceHighlighted:(BOOL)sourceHighlighted {
    _sourceHighlighted = sourceHighlighted;
    [self setNeedsDisplay:YES];
}

#pragma mark - Drag Source Operations

- (void)mouseDragged:(NSEvent *)theEvent {
    if (self.allowDrag == NO) return;
    
    NSDraggingItem *draggingItem = [[NSDraggingItem alloc] initWithPasteboardWriter:self];

    // Render an image of the view to display on drag
    NSImage *image = [[NSImage alloc] initWithSize:self.bounds.size];
    [image lockFocus];
    CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;
    [self.layer renderInContext:context];
    [image unlockFocus];
    
    [draggingItem setDraggingFrame:self.bounds contents:image];
    
    NSDraggingSession *session = [self beginDraggingSessionWithItems:@[draggingItem] event:theEvent source:self];
    session.animatesToStartingPositionsOnCancelOrFail = YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
}

#pragma mark - NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationEvery;
}

#pragma mark - NSPasteboardWriting

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[PCPasteboardTypeBehavioursWhen];
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    return @{};
}

@end

