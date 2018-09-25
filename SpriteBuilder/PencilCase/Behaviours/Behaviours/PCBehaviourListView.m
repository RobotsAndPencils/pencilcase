//
//  PCBehaviourListView.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-09.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCBehaviourListView.h"
#import <Quartz/Quartz.h>

@interface PCBehaviourListView () <NSDraggingDestination>

@property (strong, nonatomic) NSMutableArray *insertionMarkerLineYPositions;
@property (strong, nonatomic) NSNumber *selectedLine; // the y position of the selected line
@property (strong, nonatomic) NSValue *lastDragPoint;
@property (assign, nonatomic) BOOL stopScrolling;
@property (assign, nonatomic) BOOL isScrolling;

@end

@implementation PCBehaviourListView

const CGFloat PCBehaviourListScrollDuration = 0.5;
const CGFloat PCBehaviourListScrollCheckHeight = 0.1;
const CGFloat PCBehaviourListScrollHeight = 150.0;
const CGFloat PCBehaviourListMarkerLineStartX = 30.0;
const CGFloat PCBehaviourListMarkerLineEndMargin = 15.0;

NSString *const PCBehaviourWhenMovedNotification = @"PCBehaviourWhenMovedNotification";
NSString *const PCBehaviourWhenMovedIndexKey = @"PCBehaviourWhenMovedIndexKey";

- (void)awakeFromNib {
    [super awakeFromNib];
    [self registerForDraggedTypes:@[PCPasteboardTypeBehavioursWhen]];
    self.stopScrolling = NO;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if (self.selectedLine == nil) return;
    
    CGFloat width = self.frame.size.width;
    CGFloat markerHeight = 2.0;
    
    [[NSColor colorWithRed:41/255.0 green:135/255.0 blue:253/255.0 alpha:1] set];
    
    // add the straight line between the whens
    NSRectFill(CGRectMake(PCBehaviourListMarkerLineStartX, [self.selectedLine floatValue], width - PCBehaviourListMarkerLineEndMargin - PCBehaviourListMarkerLineStartX, markerHeight));
    
    CGFloat circleRadius = 3.0f;
    
    // the center of the rect will be PCBehaviourListMarkerLineStartX - circleRadius, [self.selectedLine floatValue] + (markerHeight * 0.5)
    CGRect circleFrame = CGRectMake(PCBehaviourListMarkerLineStartX - (2.0 * circleRadius), [self.selectedLine floatValue] + (markerHeight * 0.5) - circleRadius, 2.0 * circleRadius, 2.0 * circleRadius);
    
    // add a circle in front of the line
    NSBezierPath* circlePath = [NSBezierPath bezierPathWithOvalInRect:circleFrame];
    [circlePath setLineWidth:markerHeight];
    [circlePath stroke];
}

#pragma mark - Private 

- (void)updateLinePositionFromTouchPoint:(NSPoint)touchPoint {
    if ([self closestLineYPositions:touchPoint.y] != self.selectedLine) {
        self.selectedLine = [self closestLineYPositions:touchPoint.y];
        [self setNeedsDisplay:YES];
    }
}

- (NSNumber *)closestLineYPositions:(CGFloat)currentY {
    CGFloat diff = FLT_MAX;
    NSNumber *result;
    
    // parse through the y positions array to find the closest line
    for (NSNumber *lineY in self.insertionMarkerLineYPositions) {
        CGFloat currentDiff = fabs([lineY floatValue] - currentY);
        if (currentDiff < diff) {
            result = lineY;
            diff = currentDiff;
        }
    }
    
    return result;
}

#pragma mark - NSDraggingDestination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    
    if ([[pboard types] containsObject:PCPasteboardTypeBehavioursWhen]) {
        if (sourceDragMask & NSDragOperationMove) {
            self.insertionMarkerLineYPositions = [NSMutableArray array];
            
            // get all the frames of the whens, as they maybe not be in the right order
            NSMutableArray *frames = [NSMutableArray array];
            for (NSView *subview in self.subviews) {
                [frames addObject:[NSValue valueWithRect:subview.frame]];
            }
            
            // sort it from smallest to biggest y
            [frames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 rectValue].origin.y == [obj2 rectValue].origin.y) return NSOrderedSame;
                if ([obj1 rectValue].origin.y < [obj2 rectValue].origin.y) return NSOrderedAscending;
                return NSOrderedDescending;
            }];
            
            CGFloat currentY = 0.0f;
            
            // calculate the y position of each line
            for (NSInteger idx = 0; idx < [frames count]; idx++){
                NSRect frame = [frames[idx] rectValue];
                [self.insertionMarkerLineYPositions addObject:@((currentY + frame.origin.y)/2.0)];
                currentY = frame.origin.y + frame.size.height;
            }
            
            self.lastDragPoint = nil;
            
            // Make sure to add the line right after the last when, use the first line to get the spacing value for it
            [self.insertionMarkerLineYPositions addObject:@(currentY+[self.insertionMarkerLineYPositions.firstObject floatValue])];

            return NSDragOperationMove;
        }
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    
    if ([[pboard types] containsObject:PCPasteboardTypeBehavioursWhen]) {
        if (sourceDragMask & NSDragOperationMove) {
            NSPoint currentDragPt = sender.draggingLocation;
            
            BOOL testScrollUp = YES;
            BOOL skipScrolling = YES;
            
            if (self.lastDragPoint) {
                if ([self.lastDragPoint pointValue].y != currentDragPt.y) {
                    // find the direction of where the drag point is going
                    testScrollUp = currentDragPt.y > [self.lastDragPoint pointValue].y;
                    skipScrolling = NO; 
                }
            }

            self.lastDragPoint = [NSValue valueWithPoint:currentDragPt];
            
            NSPoint ptInView = [self convertPoint:[self.lastDragPoint pointValue] fromView:nil];
            [self updateLinePositionFromTouchPoint:ptInView];
            
            if (skipScrolling) return NSDragOperationMove;
            
            // Only try scrolling in the direction of where the drag is going
            self.stopScrolling = NO;
            if (testScrollUp) {
                [self tryScrollingUp];
            }
            else {
                [self tryScrollingDown];
            }
            
            return NSDragOperationMove;
        }
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    self.stopScrolling = YES;
    self.selectedLine = nil;
    [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCBehaviourWhenMovedNotification object:nil userInfo:@{PCBehaviourWhenMovedIndexKey:@([self.insertionMarkerLineYPositions indexOfObject:self.selectedLine])}];
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    self.stopScrolling = YES;
    self.selectedLine = nil;
    [self setNeedsDisplay:YES];
}

#pragma mark - Improved Scrolling

- (void)tryScrollingDown {
    if (![self.superview.superview isKindOfClass:[NSScrollView class]]) return;
    if (self.stopScrolling == YES) return;
    if (self.isScrolling == YES) return;

    NSScrollView *scrollView = (NSScrollView *)self.superview.superview;
    
    //check if we are close to bottom of the list
    NSPoint pointInScroll = [scrollView convertPoint:[self.lastDragPoint pointValue] fromView:nil];
    if (pointInScroll.y < ((1.0 - PCBehaviourListScrollCheckHeight) * scrollView.frame.size.height)) return;
    
    CGFloat maxScrollY = self.frame.size.height - scrollView.frame.size.height;
    if (maxScrollY <= 0) return; // we can't scroll down, content is smaller then scroll view
    
    NSPoint currentScrollPoint = scrollView.contentView.bounds.origin;

    if (currentScrollPoint.y >= maxScrollY) return; // already at the bottom

    self.isScrolling = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:PCBehaviourListScrollDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];    
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        self.isScrolling = NO;
        [self tryScrollingDown]; // repeat scrolling action as mouse maynot be moving
    }];
    currentScrollPoint.y += PCBehaviourListScrollHeight;
    if (currentScrollPoint.y > maxScrollY) currentScrollPoint.y = maxScrollY;
    [[scrollView.contentView animator] setBoundsOrigin:currentScrollPoint];
    [NSAnimationContext endGrouping];
}

- (void)tryScrollingUp {
    if (![self.superview.superview isKindOfClass:[NSScrollView class]]) return;
    if (self.stopScrolling == YES) return;
    if (self.isScrolling == YES) return;    
    
    NSScrollView *scrollView = (NSScrollView *)self.superview.superview;
    
    //check if we are close to top of the list
    NSPoint pointInScroll = [scrollView convertPoint:[self.lastDragPoint pointValue] fromView:nil];
    if (pointInScroll.y > (PCBehaviourListScrollCheckHeight) * scrollView.frame.size.height) return;
    
    NSPoint currentScrollPoint = scrollView.contentView.bounds.origin;
    if (currentScrollPoint.y <= 0) return; // already at the top
    
    self.isScrolling = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:PCBehaviourListScrollDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        self.isScrolling = NO;
        [self tryScrollingUp];
    }];
    currentScrollPoint.y -= PCBehaviourListScrollHeight;
    if (currentScrollPoint.y <= 0) currentScrollPoint.y = 0;
    [[scrollView.contentView animator] setBoundsOrigin:currentScrollPoint];
    [NSAnimationContext endGrouping];
}

@end
