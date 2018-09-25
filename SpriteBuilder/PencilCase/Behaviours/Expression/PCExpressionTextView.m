//
//  PCExpressionTextView.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-17.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCExpressionTextView.h"
#import "PCTokenAttachmentCell.h"
#import "PCStatement.h"
#import "PCExpression.h"
#import "PCToken.h"
#import "PCBehaviourJavaScriptValidator.h"
#import <INPopoverController/INPopoverWindow.h>
#import "PCUndoManager.h"

NSString * const PCTokenPasteboardType = @"com.robotsandpencils.PCTokenPasteboardType";
CGFloat const PCTokenCancelingClickDistance = 4;

@interface PCExpressionTextView ()

@property (strong, nonatomic) PCTokenAttachmentCell *hoveredCell;
@property (strong, nonatomic) NSUndoManager *internalUndoManager;

@end

@implementation PCExpressionTextView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    self.textContainerInset = NSMakeSize(0, 4);
    self.typingAttributes = @{ NSFontAttributeName : [NSFont fontWithName:@"Menlo" size:12.0] };
    [self setLinkTextAttributes:@{}];
    self.smartInsertDeleteEnabled = NO;
    self.automaticTextReplacementEnabled = NO;
    self.automaticQuoteSubstitutionEnabled = NO;
    self.automaticDashSubstitutionEnabled = NO;
    self.automaticSpellingCorrectionEnabled = NO;
    self.automaticLinkDetectionEnabled = NO;
    self.internalUndoManager = [[NSUndoManager alloc] init];
}

- (NSUndoManager *)undoManager {
    return _internalUndoManager;
}

- (IBAction)undo:(id)sender {
    [self.internalUndoManager undo];
}

- (IBAction)redo:(id)sender {
    [self.internalUndoManager redo];
}


- (NSSize)intrinsicContentSize {
    [self.layoutManager ensureLayoutForBoundingRect:NSMakeRect(0, 0, self.bounds.size.width, CGFLOAT_MAX) inTextContainer:self.textContainer];
    CGSize size = [self.layoutManager usedRectForTextContainer:self.textContainer].size;
    size.height += 5; // Not sure why this is needed
    return size;
}

- (void)didChangeText {
    [super didChangeText];
    [self invalidateIntrinsicContentSize];
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self invalidateIntrinsicContentSize];
}

- (NSArray *)writablePasteboardTypes {
    return @[ PCTokenPasteboardType, NSStringPboardType ];
}

- (NSArray *)readablePasteboardTypes {
    return @[ PCTokenPasteboardType, NSStringPboardType ];
}

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type {
    if ([type isEqualToString:PCTokenPasteboardType]) {
        NSRange range = [self selectedRange];
        if (range.length == 0) return NO;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self chunksForRange:range]];
        [pboard setData:data forType:type];
        return YES;
    }
    else if ([type isEqualToString:NSStringPboardType]) {
        [pboard setString:[self stringForRange:[self selectedRange]] forType:type];
        return YES;
    }
    else {
        return [super writeSelectionToPasteboard:pboard type:type];
    }
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard type:(NSString *)type {
    if ([type isEqualToString:PCTokenPasteboardType]) {
        NSData *data = [pboard dataForType:type];
        NSArray *chunks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSAttributedString *string = [self stringFromChunks:chunks];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self insertText:string];
        });
        return YES;
    }
    else {
        return [super readSelectionFromPasteboard:pboard type:type];
    }
}

- (NSString *)preferredPasteboardTypeFromArray:(NSArray *)availableTypes restrictedToTypesFromArray:(NSArray *)allowedTypes {
    if ([availableTypes containsObject:PCTokenPasteboardType]) return PCTokenPasteboardType;
    return [super preferredPasteboardTypeFromArray:availableTypes restrictedToTypesFromArray:allowedTypes];
}

- (NSArray *)expressionChunks {
    NSMutableArray *chunks = [NSMutableArray array];
    NSRange range = NSMakeRange(0, [self.textStorage length]);
    [self.textStorage enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
        if ([attributes objectForKey:NSAttachmentAttributeName]) {
            NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
            if ([attachment.attachmentCell isKindOfClass:[PCTokenAttachmentCell class]]) {
                PCTokenAttachmentCell *cell = (PCTokenAttachmentCell *)attachment.attachmentCell;
                [chunks addObject:cell.token];
            }
        }
        else {
            [chunks addObject:[self.textStorage attributedSubstringFromRange:range].string];
        }
    }];
    return chunks;
}

- (NSString *)stringForRange:(NSRange)range {
    NSMutableString *string = [NSMutableString string];
    [self.textStorage enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
        if ([attributes objectForKey:NSAttachmentAttributeName]) {
            NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
            if ([attachment.attachmentCell isKindOfClass:[PCTokenAttachmentCell class]]) {
                PCTokenAttachmentCell *cell = (PCTokenAttachmentCell *)attachment.attachmentCell;
                [string appendString:cell.token.displayName];
            }
        }
        else {
            [string appendString:[self.textStorage attributedSubstringFromRange:range].string];
        }
    }];
    return string;
}

- (NSArray *)chunksForRange:(NSRange)range {
    NSMutableArray *chunks = [NSMutableArray array];
    [self.textStorage enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
        if ([attributes objectForKey:NSAttachmentAttributeName]) {
            NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
            if ([attachment.attachmentCell isKindOfClass:[PCTokenAttachmentCell class]]) {
                PCTokenAttachmentCell *cell = (PCTokenAttachmentCell *)attachment.attachmentCell;
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cell.token];
                [chunks addObject:data];
            }
        }
        else {
            [chunks addObject:[self.textStorage attributedSubstringFromRange:range]];
        }
    }];
    return chunks;
}

- (NSAttributedString *)stringFromChunks:(NSArray *)chunks {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    for (id item in chunks) {
        if ([item isKindOfClass:[NSData class]]) {
            PCToken *token = [NSKeyedUnarchiver unarchiveObjectWithData:item];
            NSAttributedString *attachment = [token attributedString];
            [string appendAttributedString:attachment];
        }
        else {
            [string appendAttributedString:item];
        }
    }
    return [string copy];
}

- (BOOL)acceptsFirstResponder {
    return self.editable;
}

- (void)mouseMoved:(NSEvent *)theEvent {
    [super mouseMoved:theEvent];

    if (theEvent.window != self.window) return;

    CGPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    CGRect rect = CGRectNull;
    PCTokenAttachmentCell *cell = [self cellAtPoint:location cellRect:&rect];
    if (cell) {
        cell.allowEditing = self.editable;
        CGPoint cellPoint = CGPointMake(location.x - rect.origin.x, location.y - rect.origin.y);
        [cell mouseMoved:cellPoint];
    }
    if (cell != self.hoveredCell) {
        [self.hoveredCell mouseExited];
    }

    if ([self linkAtPoint:location]) {
        [[NSCursor pointingHandCursor] set];
    }
    else {
        [[NSCursor arrowCursor] set];
    }
    
    self.hoveredCell = cell;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [self.hoveredCell mouseExited];
    self.hoveredCell = nil;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSEvent *mouseDownEvent = theEvent;
    [super mouseDown:theEvent];

    /*
     The TextView will start an internal event tracking loop when we call super (docs search: "The Mouse-Tracking Loop Approach". Basically it loops calling `nextEventMatchingMask:`) The interal loop waits for a mouse up before exiting. So by the time this code runs some number of other events have fired and we are now on the mouse up. mouseUp: is not called in this private tracking mode. I have been unsuccessful finding any way to be notified of the events occuring in this private trackign mode. So we store the mouseDownEvent and compare it to the current event (now mouseup) to see if we should treat it as a click. Since I can't find a way of knowing if a drag started and then cancelled we use distance between events to determine if we should count this as a click. The other option is to not call super here but then we lose all of the default behaviour from NSTextView.
     
     TLDR: Mouse event handling in NSTextView uses a private tracking loop forcing us to dance a bit to detect clicks.
     */
    NSEvent *currentEvent = [theEvent.window currentEvent];
    CGFloat distance = hypotf(mouseDownEvent.locationInWindow.x - currentEvent.locationInWindow.x, mouseDownEvent.locationInWindow.y - currentEvent.locationInWindow.y);
    if (distance < PCTokenCancelingClickDistance) {
        [self handleMouseUpEvent:[theEvent.window currentEvent]];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    [self handleMouseUpEvent:theEvent];
}

- (void)handleMouseUpEvent:(NSEvent *)theEvent {
    CGPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    id link = [self linkAtPoint:location];
    if (link) {
        [self.delegate textView:self clickedOnLink:link atIndex:0];
    }

    CGRect rect = CGRectNull;
    PCTokenAttachmentCell *cell = [self cellAtPoint:location cellRect:&rect];
    if (cell && self.tokenSelectedHandler) {
        NSData *archivedToken = [NSKeyedArchiver archivedDataWithRootObject:cell.token];
        PCToken *deepCopiedToken = [NSKeyedUnarchiver unarchiveObjectWithData:archivedToken];
        self.tokenSelectedHandler(deepCopiedToken);
    }

    CGPoint contentViewlocation = [theEvent.window.contentView convertPoint:[theEvent locationInWindow] fromView:nil];
    [self.hoveredCell clickedLocation:contentViewlocation inView:theEvent.window.contentView didUpdateBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NSTextDidChangeNotification object:self];
        [self.layoutManager textContainerChangedGeometry:self.textContainer];
    }];
}

- (PCTokenAttachmentCell *)cellAtPoint:(CGPoint)point cellRect:(CGRect *)cellRect {
    __block PCTokenAttachmentCell *foundCell;
    [self.textStorage enumerateAttributesInRange:NSMakeRange(0, self.textStorage.length) options:0 usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
        if ([attributes objectForKey:NSAttachmentAttributeName]) {
            NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
            if ([attachment.attachmentCell isKindOfClass:[PCTokenAttachmentCell class]]) {
                PCTokenAttachmentCell *cell = (PCTokenAttachmentCell *)attachment.attachmentCell;
                NSUInteger rectCount = 0;
                NSRectArray rects = [self.layoutManager rectArrayForCharacterRange:range withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textContainer rectCount:&rectCount];
                for (NSInteger i = 0; i < rectCount; i++) {
                    NSRect rect = rects[i];
                    if (CGRectContainsPoint(rect, point)) {
                        foundCell = cell;
                        if (cellRect) *cellRect = rect;
                        *stop = YES;
                    }
                }
            }
        }
    }];
    
    return foundCell;
}

- (id)linkAtPoint:(CGPoint)point {
    __block id foundLink;
    [self.textStorage enumerateAttributesInRange:NSMakeRange(0, self.textStorage.length) options:0 usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
        if (![attributes objectForKey:NSLinkAttributeName]) return;

        NSUInteger rectCount = 0;
        NSRectArray rects = [self.layoutManager rectArrayForCharacterRange:range withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textContainer rectCount:&rectCount];
        for (NSInteger i = 0; i < rectCount; i++) {
            NSRect rect = rects[i];
            if (CGRectContainsPoint(rect, point)) {
                foundLink = attributes[NSLinkAttributeName];
                *stop = YES;
            }
        }
    }];

    return foundLink;
}

- (void)setHoveredCell:(PCTokenAttachmentCell *)hoveredCell {
    if (_hoveredCell == hoveredCell) return;
    _hoveredCell.hovered = NO;
    _hoveredCell = hoveredCell;
    _hoveredCell.hovered = YES;
}

- (NSView *)hitTest:(NSPoint)aPoint {
    id result = [super hitTest:aPoint];
    if (self.editable) return result;

    if (result == self) {
        NSPoint localPoint = [self convertPoint:aPoint fromView:self.superview];
        if (![self cellAtPoint:localPoint cellRect:nil] && ![self linkAtPoint:localPoint]) {
            return nil;
        }
    }
    return result;
}

@end
