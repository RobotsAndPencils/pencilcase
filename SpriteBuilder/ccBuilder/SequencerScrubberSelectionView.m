/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "SequencerScrubberSelectionView.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+Sequencer.h"
#import "PlugInNode.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "AppDelegate.h"
#import "SequencerChannel.h"
#import "SequencerCallbackChannel.h"
#import "SequencerSoundChannel.h"
#import "SequencerPopoverHandler.h"
#import "SKNode+NodeInfo.h"
#import "OALSimpleAudio.h"

const CGFloat CCBSeqScrubberHeight = 16;

@implementation SequencerScrubberSelectionView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    imgScrubHandle = [NSImage imageNamed:@"seq-scrub-handle.png"];
    imgScrubLine = [NSImage imageNamed:@"seq-scrub-line.png"];

    return self;
}

#pragma mark - Rendering

- (void)drawRect:(NSRect)dirtyRect {
    SequencerSequence *seq = [SequencerHandler sharedHandler].currentSequence;

    // Draw selection
    NSGraphicsContext *gc = [NSGraphicsContext currentContext];
    [gc saveGraphicsState];

    [NSBezierPath clipRect:NSMakeRect(0, 0, [self activeWidth], self.bounds.size.height - CCBSeqScrubberHeight)];

    if (mouseState == CCBSeqMouseStateSelecting && xStartSelectTime != xEndSelectTime) {
        // Determine min/max values for the selection
        CGFloat xMinTime = 0;
        CGFloat xMaxTime = 0;
        if (xStartSelectTime < xEndSelectTime) {
            xMinTime = xStartSelectTime;
            xMaxTime = xEndSelectTime;
        }
        else {
            xMinTime = xEndSelectTime;
            xMaxTime = xStartSelectTime;
        }

        // Rows
        int yMinRow = 0;
        int yMaxRow = 0;
        int yMinSubRow = 0;
        int yMaxSubRow = 0;

        if (yStartSelectRow < yEndSelectRow) {
            yMinRow = yStartSelectRow;
            yMaxRow = yEndSelectRow;
            yMinSubRow = yStartSelectSubRow;
            yMaxSubRow = yEndSelectSubRow;
        }
        else {
            yMinRow = yEndSelectRow;
            yMaxRow = yStartSelectRow;
            yMinSubRow = yEndSelectSubRow;
            yMaxSubRow = yStartSelectSubRow;
        }

        // Sub rows
        if (yMinRow == yMaxRow) {
            if (yStartSelectSubRow < yEndSelectSubRow) {
                yMinSubRow = yStartSelectSubRow;
                yMaxSubRow = yEndSelectSubRow;
            }
            else {
                yMinSubRow = yEndSelectSubRow;
                yMaxSubRow = yStartSelectSubRow;
            }
        }

        // Check bounds
        if (xMinTime < 0) xMinTime = 0;
        if (xMaxTime > seq.timelineLength) xMaxTime = seq.timelineLength;

        // Calc x/width
        CGFloat x = [seq timeToPosition:xMinTime];
        CGFloat w = [seq timeToPosition:xMaxTime] - x;

        // Calc y/height
        NSOutlineView *outline = [SequencerHandler sharedHandler].outlineHierarchy;

        NSRect minRowRect = [outline rectOfRow:yMinRow];
        minRowRect.size.height = kCCBSeqDefaultRowHeight;
        minRowRect.origin.y += kCCBSeqDefaultRowHeight * yMinSubRow;

        NSRect maxRowRect = [outline rectOfRow:yMaxRow];
        maxRowRect.size.height = kCCBSeqDefaultRowHeight;
        maxRowRect.origin.y += kCCBSeqDefaultRowHeight * yMaxSubRow;

        NSRect yStartRect = [self convertRect:minRowRect fromView:outline];
        NSRect yEndRect = [self convertRect:maxRowRect fromView:outline];

        CGFloat y = yEndRect.origin.y;
        CGFloat h = (yStartRect.origin.y + yStartRect.size.height) - y;

        // Draw the selection rectangle
        NSRect rect = NSMakeRect(x, y - 1, w + 1, h + 1);

        [[NSColor colorWithDeviceRed:0.83f green:0.88f blue:1.00f alpha:0.50f] set];
        [NSBezierPath fillRect:rect];

        [[NSColor colorWithDeviceRed:0.45f green:0.55f blue:0.82f alpha:1.00f] set];
        NSFrameRect(rect);
    }

    [gc restoreGraphicsState];

    // Draw scrubber
    CGFloat currentPos = TIMELINE_PAD_PIXELS;
    if (seq) {
        currentPos = [seq timeToPosition:seq.timelinePosition];
    }

    CGFloat yPos = self.bounds.size.height - imgScrubHandle.size.height;

    // Handle
    [imgScrubHandle drawAtPoint:NSMakePoint(currentPos - 3, yPos - 1) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];

    // Line
    [imgScrubLine drawInRect:NSMakeRect(currentPos, 0, 2, yPos) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

#pragma mark - Helper methods

- (CGFloat)activeWidth {
    return [[SequencerHandler sharedHandler].outlineHierarchy tableColumnWithIdentifier:@"sequencer"].width;
}

- (NSInteger)yMousePosToRow:(CGFloat)y {
    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;

    NSPoint convPoint = [outlineView convertPoint:NSMakePoint(0, y) fromView:self];

    if (y < 0) return CCBSequencerSelectedRowNoneBelow;
    else if (y >= (self.bounds.size.height - CCBSeqScrubberHeight)) return CCBSequencerSelectedRowNoneAbove;

    return [outlineView rowAtPoint:convPoint];
}

- (NSInteger)yMousePosToSubRow:(CGFloat)y {
    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;

    NSInteger row = [self yMousePosToRow:y];
    if (row == CCBSequencerSelectedRowNoneAbove || row == CCBSequencerSelectedRowNoneBelow) {
        return 0;
    }
    else if (row == CCBSequencerSelectedRowNone) {
        SKNode *lastNode = [outlineView itemAtRow:[outlineView numberOfRows] - 1];
        if (lastNode.seqExpanded) {
            return [[[lastNode plugIn] animatablePropertiesForSpriteKitNode:lastNode] count] - 1;
        }
        else {
            return 0;
        }
    }

    NSRect cellFrame = [outlineView frameOfCellAtColumn:0 row:row];
    NSPoint convPoint = [outlineView convertPoint:NSMakePoint(0, y) fromView:self];

    CGFloat yInCell = convPoint.y - cellFrame.origin.y;
    NSInteger subRow = (NSInteger)floor(yInCell / kCCBSeqDefaultRowHeight);

    // Check bounds
    id item = [outlineView itemAtRow:row];

    if ([item isKindOfClass:[SequencerChannel class]]) {
        return 0;
    }
    SKNode *node = item;

    if (node.seqExpanded) {
        if (subRow >= [[[node plugIn] animatablePropertiesForSpriteKitNode:node] count]) {
            subRow = [[[node plugIn] animatablePropertiesForSpriteKitNode:node] count] - 1;
        }
    }
    else {
        subRow = 0;
    }

    return subRow;
}

- (void)selectNodeUnderMouseLocation:(NSPoint)mouseLocation {
    int row = [self yMousePosToRow:mouseLocation.y];
    if (row < 0) row = [[SequencerHandler sharedHandler].outlineHierarchy numberOfRows] - 1;
    [self selectNodesFromTopRow:row toBottomRow:row clearExistingNodes:YES];
}

- (void)selectNodesFromTopRow:(NSInteger)topRow toBottomRow:(NSInteger)bottomRow clearExistingNodes:(BOOL)clearExistingNodes{
    // Add/remove the node associated with this keyframe to the current selection
    NSMutableArray *selectedNodes = clearExistingNodes ? [NSMutableArray array] : [[AppDelegate appDelegate].selectedSpriteKitNodes mutableCopy];
    for (NSInteger rowIndex = topRow; rowIndex <= bottomRow; rowIndex += 1) {
        SKNode *node = [[SequencerHandler sharedHandler].outlineHierarchy itemAtRow:rowIndex];
        if ([node isKindOfClass:[SKNode class]] && ![NSStringFromClass([node class]) isEqualToString:@"PCSlideNode"] && ![selectedNodes containsObject:node]) {
            [selectedNodes addObject:node];
        }
    }
    [AppDelegate appDelegate].selectedSpriteKitNodes = selectedNodes;
}

- (NSString *)propNameForNode:(SKNode *)node subRow:(int)sub {
    NSArray *props = [node.plugIn animatablePropertiesForSpriteKitNode:node];

    NSString *prop;
    prop = [props objectAtIndex:sub];

    return prop;
}

#pragma mark - Autoscroll

- (void)updateAutoScrollHorizontal {
    SequencerSequence *seq = [SequencerHandler sharedHandler].currentSequence;

    if (autoScrollHorizontalDirection) {
        // Perform scroll
        if (autoScrollHorizontalDirection == CCBSeqAutoScrollHorizontalLeft) {
            seq.timelineOffset -= 20 / seq.timelineScale;
        }
        else if (autoScrollHorizontalDirection == CCBSeqAutoScrollHorizontalRight) {
            seq.timelineOffset += 20 / seq.timelineScale;
        }

        // Reschedule callback
        [self performSelector:@selector(updateAutoScrollHorizontal) withObject:nil afterDelay:0.1f];

        if (mouseState == CCBSeqMouseStateScrubbing) {
            // Update time marker
            seq.timelinePosition = [seq positionToTime:lastMousePosition.x];
        }
        else if (mouseState == CCBSeqMouseStateSelecting) {
            xEndSelectTime = [seq positionToTime:lastMousePosition.x];
        }

        didAutoScroll = YES;
    }
}

- (void)autoScrollHorizontalDirection:(int)dir {
    if (dir == autoScrollHorizontalDirection) return;

    autoScrollHorizontalDirection = dir;

    if (dir != CCBSeqAutoScrollHorizontalNone) {
        // Schedule callback
        [self updateAutoScrollHorizontal];
    }
}

- (void)updateAutoScrollVertical {
    NSScrollView *scrollView = [SequencerHandler sharedHandler].scrollView;
    NSClipView *contentView = scrollView.contentView;

    if (autoScrollVerticalDirection) {
        if (autoScrollVerticalDirection == CCBSeqAutoScrollVerticalUp) {
            CGFloat yScroll = contentView.bounds.origin.y - 10;

            [contentView scrollToPoint:[contentView constrainScrollPoint:NSMakePoint(0, yScroll)]];
            [scrollView reflectScrolledClipView:[scrollView contentView]];
        }
        else if (autoScrollVerticalDirection == CCBSeqAutoScrollVerticalDown) {
            CGFloat yScroll = contentView.bounds.origin.y + 10;

            [contentView scrollToPoint:[contentView constrainScrollPoint:NSMakePoint(0, yScroll)]];
            [scrollView reflectScrolledClipView:[scrollView contentView]];
        }

        // Fake drag event
        [self mouseDragged:self.lastDragEvent];

        // Reschedule callback
        [self performSelector:@selector(updateAutoScrollVertical) withObject:nil afterDelay:0.1f];

        didAutoScroll = YES;
    }
}

- (void)autoScrollVerticalDirection:(int)dir {
    if (dir == autoScrollVerticalDirection) return;

    autoScrollVerticalDirection = dir;

    if (dir != CCBSeqAutoScrollHorizontalNone) {
        // Schedule callback
        [self updateAutoScrollVertical];
    }
}

#pragma mark - Keyframes

- (void)addKeyframeAtRow:(NSInteger)row sub:(NSInteger)sub time:(CGFloat)time {
    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;

    // Get the double clicked node
    id item = [outlineView itemAtRow:row];

    if ([item isKindOfClass:[SequencerChannel class]]) {
        SequencerChannel *channel = item;
        SequencerKeyframe *eventKeyframe = [channel addDefaultKeyframeAtTime:time];
        [self setNeedsDisplay:YES];
        SequencerSequence *seq = [SequencerHandler sharedHandler].currentSequence;
        CGFloat xPos = [seq timeToPosition:eventKeyframe.time];
        CGFloat yPos = self.frame.origin.y + self.frame.size.height;
        NSRect kfBounds = NSMakeRect(xPos - 3, yPos - 50, 7, 10);
        [SequencerPopoverHandler popoverChannelKeyframes:[channel keyframesAtTime:time] kfBounds:kfBounds overView:self];
        return;
    }

    SKNode *node = item;
    NSString *prop = [self propNameForNode:node subRow:sub];

    [node addDefaultKeyframeForProperty:prop atTime:time sequenceId:[SequencerHandler sharedHandler].currentSequence.sequenceId];
}

- (SequencerKeyframe *)keyframeForRow:(int)row sub:(int)sub minTime:(CGFloat)minTime maxTime:(CGFloat)maxTime {
    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;

    id item = [outlineView itemAtRow:row];

    if ([item isKindOfClass:[SequencerChannel class]]) {
        // Handle audio & callbacks
        SequencerChannel *channel = item;
        return [channel.seqNodeProp keyframeBetweenMinTime:minTime maxTime:maxTime];
    }

    SKNode *node = item;
    NSString *prop = [self propNameForNode:node subRow:sub];

    SequencerNodeProperty *seqNodeProp = [node sequenceNodeProperty:prop sequenceId:[SequencerHandler sharedHandler].currentSequence.sequenceId];

    return [seqNodeProp keyframeBetweenMinTime:minTime maxTime:maxTime];
}

- (SequencerKeyframe *)keyframeForInterpolationInRow:(int)row sub:(int)sub time:(CGFloat)time {
    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    SKNode *node = [outlineView itemAtRow:row];
    NSString *prop = [self propNameForNode:node subRow:sub];

    SequencerNodeProperty *seqNodeProp = [node sequenceNodeProperty:prop sequenceId:[SequencerHandler sharedHandler].currentSequence.sequenceId];

    return [seqNodeProp keyframeForInterpolationAtTime:time];
}

- (NSArray *)keyframesInSelectionArea {
    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    SequencerSequence *seq = [[SequencerHandler sharedHandler] currentSequence];

    NSMutableArray *selectedKeyframes = [NSMutableArray array];

    // Determine min/max values for the selection
    CGFloat xMinTime = 0;
    CGFloat xMaxTime = 0;
    if (xStartSelectTime < xEndSelectTime) {
        xMinTime = xStartSelectTime;
        xMaxTime = xEndSelectTime;
    }
    else {
        xMinTime = xEndSelectTime;
        xMaxTime = xStartSelectTime;
    }

    // Rows
    int yMinRow = 0;
    int yMaxRow = 0;
    int yMinSubRow = 0;
    int yMaxSubRow = 0;

    if (yStartSelectRow < yEndSelectRow) {
        yMinRow = yStartSelectRow;
        yMaxRow = yEndSelectRow;
        yMinSubRow = yStartSelectSubRow;
        yMaxSubRow = yEndSelectSubRow;
    }
    else {
        yMinRow = yEndSelectRow;
        yMaxRow = yStartSelectRow;
        yMinSubRow = yEndSelectSubRow;
        yMaxSubRow = yStartSelectSubRow;
    }

    if (yMinRow == yMaxRow) {
        // Only selection within a row

        if (yStartSelectSubRow < yEndSelectSubRow) {
            yMinSubRow = yStartSelectSubRow;
            yMaxSubRow = yEndSelectSubRow;
        }
        else {
            yMinSubRow = yEndSelectSubRow;
            yMaxSubRow = yStartSelectSubRow;
        }

        id item = [outlineView itemAtRow:yMinRow];

        if ([item isKindOfClass:[SequencerChannel class]]) {
            // Handle audio & callbacks
            SequencerChannel *channel = item;
            [selectedKeyframes addObjectsFromArray:[channel.seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
        }
        else {
            SKNode *node = item;
            for (int subRow = yMinSubRow; subRow <= yMaxSubRow; subRow++) {
                NSString *propName = [self propNameForNode:node subRow:subRow];
                SequencerNodeProperty *seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
            }
        }
    }
    else {
        // Selection spanning multiple rows
        for (int row = yMinRow; row <= yMaxRow; row++) {
            id item = [outlineView itemAtRow:row];
            SKNode *node = nil;

            if ([item isKindOfClass:[SequencerChannel class]]) {
                SequencerChannel *channel = item;
                [selectedKeyframes addObjectsFromArray:[channel.seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
            }
            else {
                node = item;
            }

            if (node.seqExpanded) {
                // This row is expanded
                if (row == yMinRow) {
                    for (int subRow = yMinSubRow; subRow < [[node.plugIn animatablePropertiesForSpriteKitNode:node] count]; subRow++) {
                        NSString *propName = [self propNameForNode:node subRow:subRow];
                        SequencerNodeProperty *seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                        [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
                    }
                }
                else if (row == yMaxRow) {
                    for (int subRow = 0; subRow <= yMaxSubRow; subRow++) {
                        NSString *propName = [self propNameForNode:node subRow:subRow];
                        SequencerNodeProperty *seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                        [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
                    }
                }
                else {
                    for (int subRow = 0; subRow < [[node.plugIn animatablePropertiesForSpriteKitNode:node] count]; subRow++) {
                        NSString *propName = [self propNameForNode:node subRow:subRow];
                        SequencerNodeProperty *seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                        [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
                    }
                }
            }
            else {
                // Row is not expaned, only select the first visible property
                NSString *propName = [self propNameForNode:node subRow:0];
                SequencerNodeProperty *seqNodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
                [selectedKeyframes addObjectsFromArray:[seqNodeProp keyframesBetweenMinTime:xMinTime maxTime:xMaxTime]];
            }
        }
    }

    return selectedKeyframes;
}

#pragma mark - Mouse Events

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint:mouseLocationInWindow fromView:nil];

    // Pass on events that are not in the active area (eg on the scrollbar)
    if (mouseLocation.x > [self activeWidth]) {
        [super mouseDown:theEvent];
        return;
    }

    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;
    [self.window makeFirstResponder:nil];

    lastMousePosition = mouseLocation;

    SequencerSequence *seq = [SequencerHandler sharedHandler].currentSequence;

    // Calculate the clicked time and time span for hit area of keyframes
    CGFloat time = [seq positionToTime:mouseLocation.x];

    CGFloat timeMin = [seq positionToTime:mouseLocation.x - 3];
    CGFloat timeMax = [seq positionToTime:mouseLocation.x + 3];
    timeMax = fmax(timeMax, timeMax + 1.0 / (double)[SequencerHandler sharedHandler].currentSequence.timelineResolution);//Ensure at least one delta time step.

    int row = [self yMousePosToRow:mouseLocation.y];
    int subRow = [self yMousePosToSubRow:mouseLocation.y];

    SKNode *node;
    if (row >= 0) {
        id item = [outlineView itemAtRow:row];
        if ([item isKindOfClass:[SKNode class]]) {
            node = item;
        }
    }

    didAutoScroll = NO;
    mouseDownPosition = mouseLocation;
    mouseDownKeyframe = [self keyframeForRow:row sub:subRow minTime:timeMin maxTime:timeMax];
    mouseDownRelPositionX = (NSInteger)floor((seq.timelineScale * seq.timelineOffset) + mouseLocation.x);
    [[OALSimpleAudio sharedInstance] stopAllEffects];

    if (mouseLocation.y > self.bounds.size.height - CCBSeqScrubberHeight) {
        // Scrubbing
        seq.timelinePosition = time;
        mouseState = CCBSeqMouseStateScrubbing;
    }
    else {
        if (mouseDownKeyframe) {
            if (theEvent.modifierFlags & NSShiftKeyMask) {
                mouseDownKeyframe.selected = !mouseDownKeyframe.selected;

                // Add/remove the node associated with this keyframe to the current selection
                NSMutableArray *selectedNodes = [[AppDelegate appDelegate].selectedSpriteKitNodes mutableCopy];
                if (mouseDownKeyframe.selected && ![selectedNodes containsObject:node]) {
                    if (node) {
                        [selectedNodes addObject:node];
                    }
                }
                else {
                    [selectedNodes removeObject:node];
                }
                [AppDelegate appDelegate].selectedSpriteKitNodes = selectedNodes;
            }
            else {
                // Select the node associated with this keyframe
                if (node) {
                    [[AppDelegate appDelegate] setSelectedNode:node];
                }

                // Handle selections
                if (!mouseDownKeyframe.selected) {
                    [[SequencerHandler sharedHandler] deselectAllKeyframes];
                    mouseDownKeyframe.selected = YES;
                }

                // Center on keyframe for double clicks
                if (theEvent.clickCount == 2) {
                    seq.timelinePosition = mouseDownKeyframe.time;
                    if (node) {
                        // Center
                        [[AppDelegate appDelegate] setSelectedNode:node];
                        PCNodeManager *nodeManager = [AppDelegate appDelegate].nodeManager;

                        if (subRow != 0) {
                            // Calc bounds of keyframe
                            CGFloat xPos = [seq timeToPosition:mouseDownKeyframe.time];
                            NSRect kfBounds = NSMakeRect(xPos - 3, mouseLocation.y, 7, 10);

                            // Popover
                            [SequencerPopoverHandler popoverNode:nodeManager property:[self propNameForNode:node subRow:subRow] overView:self kfBounds:kfBounds];
                        }
                    }
                    else {
                        // This is a channel keyframe
                        CGFloat time = mouseDownKeyframe.time;
                        SequencerChannel *channel = nil;
                        if (mouseDownKeyframe.type == kCCBKeyframeTypeCallbacks) {
                            channel = seq.callbackChannel;
                        }
                        else if (mouseDownKeyframe.type == kCCBKeyframeTypeSoundEffects) {
                            channel = seq.soundChannel;
                        }

                        NSAssert(channel, @"Keyframe doesn't have valid channel");

                        // Calc bounds of keyframe
                        CGFloat xPos = [seq timeToPosition:mouseDownKeyframe.time];
                        NSRect kfBounds = NSMakeRect(xPos - 3, mouseLocation.y, 7, 10);

                        // Popover
                        [SequencerPopoverHandler popoverChannelKeyframes:[channel keyframesAtTime:time] kfBounds:kfBounds overView:self];
                    }
                }

                // Start dragging keyframe(s)
                for (SequencerKeyframe *keyframe in [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence]) {
                    keyframe.timeAtDragStart = keyframe.time;
                    seq.timelinePosition = keyframe.time;
                }

                mouseState = CCBSeqMouseStateKeyframe;
            }

            [outlineView reloadItem:node];
        }
        else if (theEvent.modifierFlags & NSAlternateKeyMask) {
            mouseState = CCBSeqMouseStateNone;

            int clickedRow = row;
            int clickedSubRow = subRow;

            if (clickedRow != -1) {
                [self addKeyframeAtRow:clickedRow sub:clickedSubRow time:time];
            }
        }
        else {
            seq.timelinePosition = time;

            mouseState = CCBSeqMouseStateSelecting;

            // Position in time
            xStartSelectTime = time;
            xEndSelectTime = xStartSelectTime;

            // Row selection
            yStartSelectRow = row;
            if (yStartSelectRow < 0) yStartSelectRow = [outlineView numberOfRows] - 1;
            yEndSelectRow = yStartSelectRow;

            // Selection in row
            yStartSelectSubRow = subRow;
            yEndSelectSubRow = yStartSelectSubRow;
            
            // Deselect all keyframes
            [[SequencerHandler sharedHandler] deselectAllKeyframes];
        }
    }

    [[AppDelegate appDelegate] updateInspectorFromSelection];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint:mouseLocationInWindow fromView:nil];

    [SequencerHandler sharedHandler].currentSequence.timelinePosition = [[SequencerHandler sharedHandler].currentSequence positionToTime:mouseLocation.x];;

    [self selectNodeUnderMouseLocation:mouseLocation];
    [super rightMouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint:mouseLocationInWindow fromView:nil];

    if (mouseLocation.x > [self activeWidth]) {
        [super mouseDragged:theEvent];
    }

    self.lastDragEvent = theEvent;

    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;

    SequencerSequence *seq = [SequencerHandler sharedHandler].currentSequence;

    lastMousePosition = mouseLocation;
    NSInteger relMousePosX = (NSInteger)floor((seq.timelineScale * seq.timelineOffset) + mouseLocation.x);

    if (mouseLocation.x < 0) {
        [self autoScrollHorizontalDirection:CCBSeqAutoScrollHorizontalLeft];
    }
    else if (mouseLocation.x > self.bounds.size.width) {
        [self autoScrollHorizontalDirection:CCBSeqAutoScrollHorizontalRight];
    }
    else {
        [self autoScrollHorizontalDirection:CCBSeqAutoScrollHorizontalNone];
    }

    if (mouseState == CCBSeqMouseStateScrubbing) {
        // Scrubbing in the timeline

        seq.timelinePosition = [seq positionToTime:mouseLocation.x];
    }
    else if (mouseState == CCBSeqMouseStateSelecting) {
        // Drawing a selection box

        xEndSelectTime = [seq positionToTime:mouseLocation.x];
        yEndSelectRow = [self yMousePosToRow:mouseLocation.y];

        int scrollDir = CCBSeqAutoScrollVerticalNone;

        if (yEndSelectRow == CCBSequencerSelectedRowNone) {
            yEndSelectRow = [outlineView numberOfRows] - 1;
        }
        else if (yEndSelectRow == CCBSequencerSelectedRowNoneAbove) {
            // Get row visible at the top of the sequencer
            yEndSelectRow = [outlineView rowAtPoint:[outlineView convertPoint:NSMakePoint(0, self.bounds.size.height - CCBSeqScrubberHeight) fromView:self]];
            if (yEndSelectRow == -1) yEndSelectRow = 0;

            // Scroll up
            scrollDir = CCBSeqAutoScrollVerticalUp;
        }
        else if (yEndSelectRow == CCBSequencerSelectedRowNoneBelow) {
            // Get the row at the visible end of the sequencer
            yEndSelectRow = [outlineView rowAtPoint:[outlineView convertPoint:NSMakePoint(0, 0) fromView:self]];
            if (yEndSelectRow == -1) yEndSelectRow = [outlineView numberOfRows] - 1;

            // Scroll down
            scrollDir = CCBSeqAutoScrollVerticalDown;
        }

        [self autoScrollVerticalDirection:scrollDir];

        yEndSelectSubRow = [self yMousePosToSubRow:mouseLocation.y];

        [self setNeedsDisplay:YES];
    }
    else if (mouseState == CCBSeqMouseStateKeyframe) {
        // Mouse down in a keyframe

        int xDelta = relMousePosX - mouseDownRelPositionX;

        NSArray *selection = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];

        BOOL moved = NO;

        for (SequencerKeyframe *keyframe in selection) {
            CGFloat oldTime = keyframe.time;

            CGFloat startPos = [seq timeToPosition:keyframe.timeAtDragStart];
            CGFloat newTime = [seq positionToTime:startPos + xDelta];

            if (oldTime != newTime) {
                keyframe.time = newTime;
                moved = YES;
                seq.timelinePosition = mouseDownKeyframe.time;
                [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*keyframe"];                
            }
        }

        if (moved) {
            [[SequencerHandler sharedHandler].outlineHierarchy reloadData];
            [[SequencerHandler sharedHandler] updatePropertiesToTimelinePosition];
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint:mouseLocationInWindow fromView:nil];

    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;

    // Check for out of bounds
    if (mouseLocation.x > [self activeWidth]) {
        [super mouseUp:theEvent];
    }

    if (mouseState == CCBSeqMouseStateSelecting) {
        NSInteger topRow = MIN(yStartSelectRow, yEndSelectRow);
        NSInteger bottomRow = MAX(yStartSelectRow, yEndSelectRow);

        BOOL clearExistingSelection = theEvent.modifierFlags & NSShiftKeyMask;
        if (clearExistingSelection) {
            [[SequencerHandler sharedHandler] deselectAllKeyframes];
        }

        NSArray *selectedKeyframes = [self keyframesInSelectionArea];
        for (SequencerKeyframe *keyframe in selectedKeyframes) {
            keyframe.selected = YES;
            [outlineView reloadData];
        }

        [self selectNodesFromTopRow:topRow toBottomRow:bottomRow clearExistingNodes:clearExistingSelection];
    }
    else if (mouseState == CCBSeqMouseStateKeyframe) {
        if (NSEqualPoints(mouseLocation, mouseDownPosition) && !didAutoScroll) {
            [[SequencerHandler sharedHandler] deselectAllKeyframes];
            mouseDownKeyframe.selected = YES;
        }
        else {
            // Moved keyframes, clean up duplicates
            [[SequencerHandler sharedHandler] deleteDuplicateKeyframesForCurrentSequence];
            [outlineView reloadData];
            [[SequencerHandler sharedHandler] sequencerDidMoveKeyframes];
        }
    }

    // Clean up
    mouseState = CCBSeqMouseStateNone;
    [self autoScrollHorizontalDirection:CCBSeqAutoScrollHorizontalNone];
    [self autoScrollVerticalDirection:CCBSeqAutoScrollVerticalNone];
    [self setNeedsDisplay:YES];
}

- (void)scrollWheel:(NSEvent *)theEvent {
    SequencerSequence *seq = [SequencerHandler sharedHandler].currentSequence;

    seq.timelineOffset -= theEvent.deltaX / seq.timelineScale * 4.0f;

    [super scrollWheel:theEvent];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
    AppDelegate *ad = [AppDelegate appDelegate];

    NSPoint mouseLocationInWindow = [theEvent locationInWindow];
    NSPoint mouseLocation = [self convertPoint:mouseLocationInWindow fromView:nil];

    // Check that document is open
    if (!ad.hasOpenedDocument) return nil;

    // Check that user clicked a row
    int row = [self yMousePosToRow:mouseLocation.y];
    if (row < 0) return nil;

    SequencerSequence *seq = [SequencerHandler sharedHandler].currentSequence;
    int subRow = [self yMousePosToSubRow:mouseLocation.y];
    CGFloat timeMin = [seq positionToTime:mouseLocation.x - 3];
    CGFloat timeMax = [seq positionToTime:mouseLocation.x + 3];

    // Check if a keyframe was clicked
    SequencerKeyframe *keyframe = [self keyframeForRow:row sub:subRow minTime:timeMin maxTime:timeMax];
    if (keyframe) {
        mouseDownKeyframe = keyframe;
        // Handle selections
        if (!mouseDownKeyframe.selected) {
            [[SequencerHandler sharedHandler] deselectAllKeyframes];
            mouseDownKeyframe.selected = YES;
        }

        [SequencerHandler sharedHandler].contextKeyframe = keyframe;
        return [AppDelegate appDelegate].menuContextKeyframe;
    }

    NSOutlineView *outlineView = [SequencerHandler sharedHandler].outlineHierarchy;

    id item = [outlineView itemAtRow:row];
    if ([item isKindOfClass:[SequencerChannel class]]) {
        NSMenu *menu = [AppDelegate appDelegate].menuContextKeyframeNoselection;
        return menu;
    }

    // Check if an interpolation was clicked
    keyframe = [self keyframeForInterpolationInRow:row sub:subRow time:[seq positionToTime:mouseLocation.x]];
    if (keyframe && [keyframe supportsFiniteTimeInterpolations]) {
        [SequencerHandler sharedHandler].contextKeyframe = keyframe;

        // Highlight selected option in context menu
        NSMenu *menu = [AppDelegate appDelegate].menuContextKeyframeInterpol;

        for (NSMenuItem *item in menu.itemArray) {
            [item setState:NSOffState];
        }

        NSMenuItem *item = [menu itemWithTag:keyframe.easing.type];
        [item setState:NSOnState];

        // Enable or disable options menu item
        NSMenuItem *itemOpt = [menu itemWithTag:-1];
        [itemOpt setEnabled:keyframe.easing.hasOptions];

        //Enabled 'Paste Keyframes' if its available
        for (NSMenuItem *item in menu.itemArray) {
            if (item.action == @selector(menuPasteKeyframes:)) {
                NSPasteboard *cb = [NSPasteboard generalPasteboard];
                NSString *type = [cb availableTypeFromArray:@[ kClipboardKeyFrames, kClipboardChannelKeyframes ]];

                //We've got a copy paste of a keyframe. Enable the Paste menuitem.
                [item setEnabled:(type != nil)];
            }
        }

        return menu;
    }
    else {
        NSMenu *menu = [AppDelegate appDelegate].menuContextKeyframeNoselection;
        
        //Enabled 'Paste Keyframes' if its available
        for (NSMenuItem *item in menu.itemArray) {
            if (item.action == @selector(menuPasteKeyframes:)) {
                NSPasteboard *cb = [NSPasteboard generalPasteboard];
                NSString *type = [cb availableTypeFromArray:@[ kClipboardKeyFrames, kClipboardChannelKeyframes ]];

                //We've got a copy paste of a keyframe. Enable the Paste menuitem.
                [item setEnabled:(type != nil)];
            }
        }
        return menu;
    }
    return nil;
}

@end
