//
//  PCTextFieldStepper.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-06-18.
//
//

#import "PCTextStepperProtocol.h"
#import "InspectorValue.h"
#import "PCTextFieldStepper.h"
#import "PCTextFieldStepperCell.h"

typedef NS_ENUM(NSInteger, PCTextStepperButton) {
    PCTextStepperButtonLeft,
    PCTextStepperButtonRight,
    PCTextStepperButtonNone
};

const CGFloat PCDefaultStepAmount = 1.0;
const CGFloat PCDefaultTextStepAmount = 1;
const CGFloat PCUseDefaultTextStepAmount = 0;

@interface PCTextFieldStepper ()

@property (strong, nonatomic) NSBezierPath *left;
@property (strong, nonatomic) NSTrackingArea *trackingArea;
@property (assign, nonatomic) NSPoint mouseDownPoint;
@property (strong, nonatomic) PCTextFieldStepperCell *stepperCell;

@end

@implementation PCTextFieldStepper

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stepAmount = PCDefaultStepAmount;
}

- (void)updateTrackingAreas {
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    NSInteger mouseTrackingOptions = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:(NSTrackingAreaOptions) mouseTrackingOptions owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (![self isEnabled]) return;
    
    [super mouseDown:theEvent];
    self.mouseDownPoint = [theEvent locationInWindow];
   
    PCTextStepperButton buttonIntersection = [self textStepperButtonIntersectsWith:[theEvent locationInWindow]];
    
    switch (buttonIntersection) {
        case PCTextStepperButtonLeft:
            // make sure any value change is within the limits
            [self setFloatValue:MAX((float)[self minAmount], self.floatValue - (float)self.stepAmount)];
            break;
        case PCTextStepperButtonRight:
            // make sure any value change is within the limits
            [self setFloatValue:MIN((float)[self maxAmount], self.floatValue + (float)self.stepAmount)];
            break;
        case PCTextStepperButtonNone:
            return;
        default:
            break;
    }
    [self updateLabel:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (![self isEnabled]) return;
    
    NSPoint dragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (dragPoint.x >= self.mouseDownPoint.x) {
        // make sure any value change is within the limits
        [self setFloatValue:MIN((float)[self maxAmount], self.floatValue + (float)self.stepAmount)];
    } else {
        // make sure any value change is within the limits
        [self setFloatValue:MAX((float)[self minAmount], self.floatValue - (float)self.stepAmount)];
    }
    self.mouseDownPoint = dragPoint;
    [self updateLabel:nil];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (![self isEnabled]) return;
    
    NSPoint mouseReleasePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (mouseReleasePoint.x > self.frame.size.width || mouseReleasePoint.x < 0 || mouseReleasePoint.y > self.frame.size.height || mouseReleasePoint.y < 0) {
        [self setDragging:YES];
        [self.window makeFirstResponder:nil];
    } else {
        [self selectText:self];
        [[NSCursor IBeamCursor] set];
    }
    [self setDragging:NO];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if (![self isEnabled]) return;
    
    [[NSCursor resizeLeftRightCursor] set];
    [[self window] disableCursorRects];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[self window] enableCursorRects];
}

- (BOOL)resignFirstResponder {
    [self setDragging:YES];
    [super resignFirstResponder];
    return YES;
}

- (void)setDragging:(BOOL)setDragging {
    if ([self.cell conformsToProtocol:@protocol(PCDisableDragProtocol)]) {
        id<PCDisableDragProtocol> textStepperCell = (id<PCDisableDragProtocol>)self.cell;
        [textStepperCell setDragDisabled:setDragging];
    }
}

- (void)updateLabel:(NSNotification *)notification {
    NSDictionary *bindingInfo = [self infoForBinding:NSValueBinding];
    [[bindingInfo valueForKey:NSObservedObjectKey] setValue:@(self.floatValue) forKeyPath:[bindingInfo valueForKey:NSObservedKeyPathKey]];
}

- (PCTextStepperButton)textStepperButtonIntersectsWith:(NSPoint)mouseDownPoint {
    NSPoint clickPoint = [self convertPoint:mouseDownPoint fromView:nil];
    if (clickPoint.x <= self.frame.size.width * 0.15) {
        return PCTextStepperButtonLeft;
    }
    if (clickPoint.x >= self.frame.size.width - self.frame.size.width * 0.15) {
        return PCTextStepperButtonRight;
    }
    return PCTextStepperButtonNone;
}

- (void)drawRect:(NSRect)dirtyRect {
    self.alignment = NSCenterTextAlignment;
    [[self cell] setBezelStyle:NSRoundedBezelStyle];
    [super drawRect:dirtyRect];
    [self drawStepperButtons];
}

- (void)drawStepperButtons {
    CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
    
    // Left Arrow
    [NSGraphicsContext saveGraphicsState];
    CGContextTranslateCTM(context, self.frame.size.width * 0.05, self.frame.size.height/2);
    CGContextRotateCTM(context, 90 * M_PI / 180);
    
    NSBezierPath* leftArrow = NSBezierPath.bezierPath;
    [leftArrow moveToPoint: NSMakePoint(0, 0)];
    [leftArrow lineToPoint: NSMakePoint(3.46, -6)];
    [leftArrow lineToPoint: NSMakePoint(-3.46, -6)];
    [leftArrow closePath];
    [NSColor.grayColor setFill];
    [leftArrow fill];
    [NSGraphicsContext restoreGraphicsState];

    
    // Right Arrow
    [NSGraphicsContext saveGraphicsState];
    CGContextTranslateCTM(context, self.frame.size.width - self.frame.size.width * 0.05, self.frame.size.height/2);
    CGContextRotateCTM(context, -90 * M_PI / 180);
    
    NSBezierPath* rightArrow = NSBezierPath.bezierPath;
    [rightArrow moveToPoint: NSMakePoint(0, 0)];
    [rightArrow lineToPoint: NSMakePoint(3.46, -6)];
    [rightArrow lineToPoint: NSMakePoint(-3.46, -6)];
    [rightArrow closePath];
    [NSColor.grayColor setFill];
    [rightArrow fill];
    [NSGraphicsContext restoreGraphicsState];
}

- (CGFloat)maxAmount{
    if (self.formatter && [self.formatter isKindOfClass:[NSNumberFormatter class]]){
        NSNumberFormatter *numberFormatter = self.formatter;
        if (numberFormatter.maximum == nil) return CGFLOAT_MAX;
        return [numberFormatter.maximum floatValue];
    }
    // if we don't have a number formatter, set max to very high
    return CGFLOAT_MAX;
}

- (CGFloat)minAmount{
    if (self.formatter && [self.formatter isKindOfClass:[NSNumberFormatter class]]){
        NSNumberFormatter *numberFormatter = self.formatter;
        if (numberFormatter.minimum == nil) return -CGFLOAT_MAX;
        return [numberFormatter.minimum floatValue];
    }
    // if we don't have a number formatter, set min to very low
    return -CGFLOAT_MAX;
}

#pragma mark - Public

+ (void)setFormatterFor:(CGFloat)maximum inspectorValue:(InspectorValue *)inspectorValue multiplier:(CGFloat)multiplier stepAmount:(CGFloat)stepAmount minimum:(CGFloat)minimum {
    // For opacity we want to add a multiplier to the formatting so it is scaled to between min and max.
    // Have to make sure multiplier, max, and min values are actually set and not empty.
    if (![inspectorValue conformsToProtocol:@protocol(PCTextStepperProtocol)]) return;

    id <PCTextStepperProtocol> textStepperInspectorValue = (id <PCTextStepperProtocol>) inspectorValue;

    // Need to always set a step amount since the inspector may have been cached
    stepAmount = stepAmount == PCUseDefaultTextStepAmount ? PCDefaultTextStepAmount : stepAmount;
    [textStepperInspectorValue setStepAmount:stepAmount];

    // Update or remove the cached formatter if the inspector supports it
    if ([textStepperInspectorValue respondsToSelector:@selector(setFormatter:)]) {
        if (minimum == 0.0 && maximum == 0.0 && multiplier == 0.0) {
            [textStepperInspectorValue setFormatter:nil];
        }
        else {
            // set the number formatter for the NSTextField
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setGeneratesDecimalNumbers:NO];
            [formatter setMaximumFractionDigits:0];
            [formatter setMultiplier:@(multiplier)];
            [formatter setMinimum:@(minimum)];
            [formatter setMaximum:@(maximum)];
            [textStepperInspectorValue setFormatter:formatter];
        }
    }
}

@end
