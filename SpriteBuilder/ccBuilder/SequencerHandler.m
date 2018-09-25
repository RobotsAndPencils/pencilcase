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

// Header
#import "SequencerHandler.h"

// Frameworks

// Categories
#import "NSPasteboard+CCB.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+Sequencer.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+EditorResizing.h"

// Project
#import "AppDelegate.h"
#import "PCStageScene.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "SequencerExpandBtnCell.h"
#import "SequencerStructureCell.h"
#import "SequencerCell.h"
#import "SequencerSequence.h"
#import "SequencerScrubberSelectionView.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerNodeProperty.h"
#import "SequencerButtonCell.h"
#import "SequencerCallbackChannel.h"
#import "SequencerSoundChannel.h"
#import "MainWindow.h"
#import "PCStageScene.h"
#import "ResourceManagerUtil.h"

static SequencerHandler *sharedSequencerHandler;


@interface SequencerHandler ()

@property (nonatomic, weak, readwrite) NSOutlineView *outlineHierarchy;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end


@implementation SequencerHandler

@synthesize loopPlayback;

#pragma mark Init and singleton object

- (id)initWithOutlineView:(NSOutlineView *)view {
    self = [super init];
    if (!self) {
        return nil;
    }

    sharedSequencerHandler = self;

    _appDelegate = [AppDelegate appDelegate];
    _outlineHierarchy = view;

    [_outlineHierarchy setDataSource:self];
    [_outlineHierarchy setDelegate:self];
    [_outlineHierarchy reloadData];

    [_outlineHierarchy registerForDraggedTypes:@[ PCPasteboardTypeNode, PCPasteboardTypeTexture, PCPasteboardTypeTemplate, PCPasteboardTypeCCB, PCPasteboardTypePluginNode, PCPasteboardTypeWAV, PCPasteboardTypeMOV ]];

    [_outlineHierarchy.outlineTableColumn.dataCell setEditable:YES];

    return self;
}

+ (SequencerHandler *)sharedHandler {
    return sharedSequencerHandler;
}

#pragma mark Handle Scale slider

- (void)setTimeScaleSlider:(NSSlider *)slider {
    if (slider == _timeScaleSlider) return;

    _timeScaleSlider = slider;

    [_timeScaleSlider setTarget:self];
    [_timeScaleSlider setAction:@selector(timeScaleSliderUpdated:)];
}

- (void)timeScaleSliderUpdated:(id)sender {
    self.currentSequence.timelineScale = self.timeScaleSlider.floatValue;
}

- (void)updateScaleSlider {
    if (!self.currentSequence) {
        self.timeScaleSlider.doubleValue = kCCBDefaultTimelineScale;
        [self.timeScaleSlider setEnabled:NO];
        return;
    }

    [self.timeScaleSlider setEnabled:YES];

    self.timeScaleSlider.floatValue = self.currentSequence.timelineScale;
}

#pragma mark Handle scroller

- (float)visibleTimeArea {
    NSTableColumn *column = [self.outlineHierarchy tableColumnWithIdentifier:@"sequencer"];
    return (column.width - 2 * TIMELINE_PAD_PIXELS) / self.currentSequence.timelineScale;
}

- (float)maxTimelineOffset {
    float visibleTime = [self visibleTimeArea];
    return MAX(self.currentSequence.timelineLength - visibleTime, 0);
}

- (void)updateScroller {
    float visibleTime = [self visibleTimeArea];
    float maxTimeScroll = self.currentSequence.timelineLength - visibleTime;

    float proportion = visibleTime / self.currentSequence.timelineLength;

    self.scroller.knobProportion = proportion;
    self.scroller.doubleValue = self.currentSequence.timelineOffset / maxTimeScroll;

    if (proportion < 1) {
        [self.scroller setEnabled:YES];
    }
    else {
        [self.scroller setEnabled:NO];
    }
}

- (void)updateScrollerToShowCurrentTime {
    float visibleTime = [self visibleTimeArea];
    float maxTimeScroll = [self maxTimelineOffset];
    float timelinePosition = self.currentSequence.timelinePosition;
    if (maxTimeScroll > 0) {
        float minVisibleTime = self.scroller.doubleValue * (self.currentSequence.timelineLength - visibleTime);
        float maxVisibleTime = self.scroller.doubleValue * (self.currentSequence.timelineLength - visibleTime) + visibleTime;

        if (timelinePosition < minVisibleTime) {
            self.scroller.doubleValue = timelinePosition / (self.currentSequence.timelineLength - visibleTime);
            self.currentSequence.timelineOffset = self.scroller.doubleValue * (self.currentSequence.timelineLength - visibleTime);
        } else if (timelinePosition > maxVisibleTime) {
            self.scroller.doubleValue = (timelinePosition - visibleTime) / (self.currentSequence.timelineLength - visibleTime);
            self.currentSequence.timelineOffset = self.scroller.doubleValue * (self.currentSequence.timelineLength - visibleTime);
        }
    }
}

- (void)setScroller:(NSScroller *)scroller {
    if (scroller == _scroller) return;

    _scroller = scroller;

    [_scroller setTarget:self];
    [_scroller setAction:@selector(scrollerUpdated:)];

    [self updateScroller];
}

- (void)scrollerUpdated:(id)sender {
    float newOffset = self.currentSequence.timelineOffset;
    float visibleTime = [self visibleTimeArea];

    switch ([self.scroller hitPart]) {
        case NSScrollerNoPart:
            break;
        case NSScrollerDecrementPage:
            newOffset -= 300 / self.currentSequence.timelineScale;
            break;
        case NSScrollerKnob:
            newOffset = self.scroller.doubleValue * (self.currentSequence.timelineLength - visibleTime);
            break;
        case NSScrollerIncrementPage:
            newOffset += 300 / self.currentSequence.timelineScale;
            break;
        case NSScrollerDecrementLine:
            newOffset -= 20 / self.currentSequence.timelineScale;
            break;
        case NSScrollerIncrementLine:
            newOffset += 20 / self.currentSequence.timelineScale;
            break;
        case NSScrollerKnobSlot:
            newOffset = self.scroller.doubleValue * (self.currentSequence.timelineLength - visibleTime);
            break;
        default:
            break;
    }

    self.currentSequence.timelineOffset = newOffset;
}

#pragma mark Outline view

- (void)updateOutlineViewSelection {
    if ([self.appDelegate.selectedSpriteKitNodes count] == 0) {
        [self.outlineHierarchy selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
        return;
    }

    // Expand parents of the selected node
    SKNode *firstSelectedNode = [self.appDelegate.selectedSpriteKitNodes firstObject];
    NSMutableArray *nodesToExpand = [NSMutableArray array];
    while (firstSelectedNode != [PCStageScene scene].rootNode && firstSelectedNode != nil) {
        [nodesToExpand insertObject:firstSelectedNode atIndex:0];
        firstSelectedNode = firstSelectedNode.parent;
    }
    for (SKNode *node in nodesToExpand) {
        [self.outlineHierarchy expandItem:node.parent];
    }

    // Update the selection
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];

    for (SKNode *selectedNode in self.appDelegate.selectedSpriteKitNodes) {
        NSInteger row = [self.outlineHierarchy rowForItem:selectedNode];
        [indexes addIndex:row];
    }
    [self.outlineHierarchy selectRowIndexes:indexes byExtendingSelection:NO];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {

    if ([PCStageScene scene].rootNode == nil) return 0;
    if (item == nil) {
        return self.displayTimeline ? 3 : 1;
    }

    SKNode *node = (SKNode *)item;
    NSArray *filteredChildren = [self filteredChildrenForNode:node];

    return [filteredChildren count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (!item) return YES;

    // Channels are not expandable
    if ([item isKindOfClass:[SequencerChannel class]]) {
        return NO;
    }

    SKNode *node = (SKNode *)item;
    NSArray *children = [node children];
    NodeInfo *info = node.userObject;
    PlugInNode *plugIn = info.plugIn;

    if ([children count] == 0) return NO;
    if (!plugIn.canHaveChildren) return NO;

    return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        if (self.displayTimeline) {
            if (index == 0) {
                // Callback channel
                return self.currentSequence.callbackChannel;
            }
            else if (index == 1) {
                // Sound channel
                return self.currentSequence.soundChannel;
            }
            else {
                // Nodes
                return [PCStageScene scene].rootNode;
            }
        }
        else {
            return [PCStageScene scene].rootNode;
        }
    }

    SKNode *node = (SKNode *)item;
    NSArray *filteredChildren = [self filteredChildrenForNode:node];
    return filteredChildren[(NSUInteger)index];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSIndexSet *indexes = [self.outlineHierarchy selectedRowIndexes];
    NSMutableArray *selectedOutlineNodes = [NSMutableArray array];
    NSMutableArray *selectedNodes = [self.appDelegate.selectedSpriteKitNodes mutableCopy];

    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        id item = [self.outlineHierarchy itemAtRow:idx];

        if ([item isKindOfClass:[SKNode class]]) {
            SKNode *node = item;
            [selectedOutlineNodes addObject:node];
            if (![self.appDelegate.selectedSpriteKitNodes containsObject:item]) {
                [selectedNodes addObject:node];
            }
        }
    }];

    for (id node in self.appDelegate.selectedSpriteKitNodes) {
        if (![selectedOutlineNodes containsObject:node]) {
            [selectedNodes removeObject:node];
        }
    }

    self.appDelegate.selectedSpriteKitNodes = selectedNodes;
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    SKNode *node = [notification userInfo][@"NSObject"];
    [node setExtraProp:@NO forKey:@"isExpanded"];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    SKNode *node = [notification userInfo][@"NSObject"];
    [node setExtraProp:@YES forKey:@"isExpanded"];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if (!item) return @"Root";

    SKNode *node = item;

    if ([item isKindOfClass:[SequencerChannel class]]) {
        SequencerChannel *channel = item;
        return channel.displayName;
    }

    if ([tableColumn.identifier isEqualToString:@"sequencer"]) {
        return @"";
    }

    if ([tableColumn.identifier isEqualToString:@"hidden"]) {
        return @(node.hidden);
    }

    if ([tableColumn.identifier isEqualToString:@"locked"]) {
        return @(node.locked);
    }
    return node.displayName;
}

- (void)setChildrenHidden:(bool)hidden withChildren:(NSArray *)children {
    for (SKNode *child in children) {
        child.hidden = hidden;
        [self setChildrenHidden:hidden withChildren:child.children];
    }
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    SKNode *node = item;

    if ([tableColumn.identifier isEqualToString:@"hidden"]) {
        BOOL hidden = [(NSNumber *)object boolValue];

        node.visible = !hidden;
        NSString *propertyKey = @"visible";
        [node updateAnimateablePropertyValue:@(node.visible) propName:propertyKey];
        [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:propertyKey];

        [outlineView reloadItem:node reloadChildren:YES];
    }
    else if ([tableColumn.identifier isEqualToString:@"locked"]) {
        node.locked = [(NSNumber *)object boolValue];
        if ([AppDelegate appDelegate].selectedSpriteKitNode == node) {
            [[AppDelegate appDelegate] updateInspectorFromSelection];
        }
    }
    else if (![object isEqualToString:node.displayName]) {
        node.displayName = object;
        [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*nodeDisplayName"];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outline shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([tableColumn.identifier isEqualToString:@"hidden"]) {
        return NO;
    }
    else if ([tableColumn.identifier isEqualToString:@"locked"]) {
        return NO;
    }
    else {
        [outline editColumn:0 row:[outline selectedRow] withEvent:[NSApp currentEvent] select:YES];
    }
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
    if (!self.dragAndDropEnabled) return NO;
    NSMutableArray *draggedObjects = [[NSMutableArray alloc] init];

    BOOL anyValidDrags = NO;
    for (id item in items) {
        SKNode *draggedNode = item;
        if (![item isKindOfClass:[SKNode class]]) continue;
        if (draggedNode == [PCStageScene scene].rootNode) continue;

        anyValidDrags = YES;
        NSMutableDictionary *clipDict = [CCBWriterInternal dictionaryFromSKNode:draggedNode];
        clipDict[@"srcNode"] = @((long long)draggedNode);
        [draggedObjects addObject:clipDict];
    }
    NSData *clipData = [NSKeyedArchiver archivedDataWithRootObject:draggedObjects];
    [pboard setData:clipData forType:PCPasteboardTypeNode];
    return anyValidDrags;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    if (!item) return NSDragOperationNone;
    NSPasteboard *pasteboard = [info draggingPasteboard];

    // Dragging over a node
    if ([item isKindOfClass:[SKNode class]]) {
        SKNode *targetNode = item;
        
        NSData *nodeData = [pasteboard dataForType:PCPasteboardTypeNode];
        if (nodeData) {
            NSArray *clipArray = [NSKeyedUnarchiver unarchiveObjectWithData:nodeData];
            // Iterate over all of the dragged nodes
            for (NSDictionary *clipDict in clipArray) {
                void *draggedNodePtr = (void *)[clipDict[@"srcNode"] longLongValue];
                SKNode *draggedNode = (__bridge SKNode *)draggedNodePtr;

                // Can't drop on self
                if (draggedNode == targetNode) return NSDragOperationNone;
                // Can't drop on a child of self
                if ([self isNode:targetNode aChildOfNode:draggedNode]) return NSDragOperationNone;
                // Can't drop on a node that doesn't accept children
                if (!targetNode.plugIn.canHaveChildren) return NSDragOperationNone;
            }
            return NSDragOperationEvery;
        }
    }

    // Dropped WavFile;
    NSArray *pasteboardWavs = [pasteboard propertyListsForType:PCPasteboardTypeWAV];

    if (pasteboardWavs.count != 0) {
        if ([item isKindOfClass:[SequencerSoundChannel class]]) {
            // Dropped WavFile;
            NSPoint mouseLocationInWindow = info.draggingLocation;
            NSPoint mouseLocation = [self.scrubberSelectionView convertPoint:mouseLocationInWindow fromView:[self.appDelegate.window contentView]];

            self.currentSequence.soundChannel.dragAndDropTimeStamp = [self.currentSequence positionToTime:mouseLocation.x];

            self.currentSequence.soundChannel.needDragAndDropRedraw = YES;
            [self.scrubberSelectionView setNeedsDisplay:YES];

            return NSDragOperationGeneric;
        }
        else
            return NSDragOperationNone;
    }

    if ([item isKindOfClass:[SequencerSoundChannel class]] || [item isKindOfClass:[SequencerCallbackChannel class]]) {
        return NSDragOperationNone;//Restrict drag and drop
    }

    return NSDragOperationGeneric;
}

- (BOOL)isNode:(SKNode *)child aChildOfNode:(SKNode *)parent {
    if (!child) return NO;
    if (!child.parent) return NO;
    if (child.parent == parent) return YES;
    return [self isNode:child.parent aChildOfNode:parent];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    NSPasteboard *pasteboard = [info draggingPasteboard];
    BOOL didDrop = NO;
    BOOL addedObject = NO;
    
    NSData *clipData = [pasteboard dataForType:PCPasteboardTypeNode];
    if (clipData) {
        NSMutableArray *clipArray = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        for (NSDictionary *clipDict in clipArray) {
            SKNode *clipNode = [CCBReaderInternal spriteKitNodeGraphFromDictionary:clipDict parentSize:CGSizeZero];
            if (![self.appDelegate addSpriteKitNode:clipNode toParent:item atIndex:index followInsertionNode:YES]) continue;
            
            // Remove old node
            void *draggedNodePtr = (void *)[clipDict[@"srcNode"] longLongValue];
            SKNode *draggedNode = (__bridge SKNode *)draggedNodePtr;
            
            // Since adding the sprite kit node can alter the parent we are adding to, due to the parent's insertion node, we can't use item as the parent any more.
            // Thus, we'll use clipNode's (the added spriteKitNode) parent for our toParent parameter.
            [clipNode pc_translateFromParent:draggedNode.parent toParent:clipNode.parent];
            
            [self.appDelegate deleteNode:draggedNode];
            [clipNode pc_makeFrameIntegral];
            [self.appDelegate setSelectedNode:clipNode];
            
            didDrop = YES;
        }
        return didDrop;
    }

    // Dropped textures
    NSArray *pbTextures = [pasteboard propertyListsForType:PCPasteboardTypeTexture];
    for (NSDictionary *dict in pbTextures) {
        [self.appDelegate dropAddSpriteWithUUID:dict[@"spriteFile"] at:CGPointMake(0, 0) parent:item];
        //[PositionPropertySetter refreshAllPositions];
        addedObject = YES;
    }

    // Dropped MovieFiles
    NSArray *pbMovs = [pasteboard propertyListsForType:PCPasteboardTypeMOV];
    if ([pbMovs count] > 0) {
        addedObject = YES;
    }

    // Dropped WavFile;
    NSArray *pbWavs = [pasteboard propertyListsForType:PCPasteboardTypeWAV];
    for (NSDictionary *dict in pbWavs) {
        NSPoint mouseLocationInWindow = info.draggingLocation;
        NSPoint mouseLocation = [self.scrubberSelectionView convertPoint:mouseLocationInWindow fromView:[self.appDelegate.window contentView]];

        //Create Keyframe
        SequencerKeyframe *keyFrame = [self.currentSequence.soundChannel addDefaultKeyframeAtTime:[self.currentSequence positionToTime:mouseLocation.x]];
        NSMutableArray *newArr = [NSMutableArray arrayWithArray:keyFrame.value];
        [newArr replaceObjectAtIndex:kSoundChannelKeyFrameName withObject:[ResourceManagerUtil uuidForResourceWithRelativePath:dict[@"wavFile"]]];
        keyFrame.value = newArr;

        addedObject = YES;
        [[AppDelegate appDelegate] saveUndoState];
    }

    // Dropped node plug-ins
    NSArray *pbNodePlugIn = [pasteboard propertyListsForType:PCPasteboardTypePluginNode];
    for (NSDictionary *dict in pbNodePlugIn) {
        [self.appDelegate dropAddPlugInNodeNamed:dict[@"nodeClassName"] parent:item index:index];
        addedObject = YES;
    }

    return addedObject;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return [item isKindOfClass:[SKNode class]];
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    if ([item isKindOfClass:[SequencerCallbackChannel class]]) {
        return kCCBSeqDefaultRowHeight;
    }
    else if ([item isKindOfClass:[SequencerSoundChannel class]]) {
        SequencerSoundChannel *channel = item;
        if (!channel.isEpanded) {
            return kCCBSeqDefaultRowHeight;
        }
        else {
            return kCCBSeqAudioRowHeight;//+1;
        }
    }

    SKNode *node = item;
    if (node.seqExpanded && self.displayTimeline) {
        return kCCBSeqDefaultRowHeight * ([[node.plugIn animatablePropertiesForSpriteKitNode:node] count]);
    }
    else {
        return kCCBSeqDefaultRowHeight;
    }
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    [cell setImagePosition:NSImageAbove];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([item isKindOfClass:[SequencerChannel class]]) {
        if ([tableColumn.identifier isEqualToString:@"expander"]) {
            SequencerExpandBtnCell *expCell = cell;
            expCell.node = nil;

            if ([item isKindOfClass:[SequencerCallbackChannel class]]) {
                expCell.isExpanded = NO;
                expCell.canExpand = NO;
            }
            else if ([item isKindOfClass:[SequencerSoundChannel class]]) {
                SequencerSoundChannel *soundChannel = item;

                expCell.isExpanded = soundChannel.isEpanded;
                expCell.canExpand = YES;
            }
        }
        else if ([tableColumn.identifier isEqualToString:@"structure"]) {
            SequencerStructureCell *strCell = cell;
            strCell.node = nil;
        }
        else if ([tableColumn.identifier isEqualToString:@"sequencer"]) {
            SequencerCell *seqCell = cell;
            seqCell.node = nil;

            if ([item isKindOfClass:[SequencerCallbackChannel class]]) {
                seqCell.channel = (SequencerCallbackChannel *)item;
            }
            else if ([item isKindOfClass:[SequencerSoundChannel class]]) {
                seqCell.channel = (SequencerSoundChannel *)item;
            }
        }
        else if ([tableColumn.identifier isEqualToString:@"locked"] ||
            [tableColumn.identifier isEqualToString:@"hidden"]) {
            SequencerButtonCell *buttonCell = cell;
            buttonCell.node = nil;

            BOOL transparent = [item isKindOfClass:[SequencerCallbackChannel class]] || [item isKindOfClass:[SequencerSoundChannel class]];
            buttonCell.transparent = transparent;
        }
        return;
    }

    SKNode *node = item;
    BOOL isRootNode = (node == [PCStageScene scene].rootNode);

    if ([tableColumn.identifier isEqualToString:@"hidden"]) {
        SequencerButtonCell *buttonCell = cell;
        buttonCell.node = node;
        [buttonCell setTransparent:NO];
        [buttonCell setEnabled:!node.parentHidden];
    }

    if ([tableColumn.identifier isEqualToString:@"locked"]) {
        SequencerButtonCell *buttonCell = cell;
        [buttonCell setTransparent:NO];
        buttonCell.node = node;
    }

    if ([tableColumn.identifier isEqualToString:@"expander"]) {
        SequencerExpandBtnCell *expCell = cell;
        expCell.isExpanded = node.seqExpanded;
        expCell.canExpand = (!isRootNode);
        expCell.node = node;
    }
    else if ([tableColumn.identifier isEqualToString:@"structure"]) {
        SequencerStructureCell *strCell = cell;
        strCell.drawProperties = self.displayTimeline;
        strCell.node = node;
    }
    else if ([tableColumn.identifier isEqualToString:@"sequencer"]) {
        SequencerCell *seqCell = cell;
        seqCell.node = node;
    }
}

- (void)updateExpandedForNode:(SKNode *)node {
    if ([self outlineView:self.outlineHierarchy isItemExpandable:node]) {
        BOOL expanded = [[node extraPropForKey:@"isExpanded"] boolValue];
        if (expanded) [self.outlineHierarchy expandItem:node];
        else [self.outlineHierarchy collapseItem:node];

        NSArray *children = [node children];
        for (SKNode *child in children) {
            [self updateExpandedForNode:child];
        }
    }
}

- (void)toggleSeqExpanderForRow:(int)row {
    id item = [self.outlineHierarchy itemAtRow:row];

    if ([item isKindOfClass:[SequencerCallbackChannel class]]) {
        return;
    }
    else if ([item isKindOfClass:[SequencerSoundChannel class]]) {
        SequencerSoundChannel *soundChannel = item;
        soundChannel.isEpanded = !soundChannel.isEpanded;
    }
    else {
        SKNode *node = item;

        if (node == [PCStageScene scene].rootNode && !node.seqExpanded) return;
        node.seqExpanded = !node.seqExpanded;
    }

    // Need to reload all data when changing heights of rows
    [self.outlineHierarchy reloadData];
}

#pragma mark Timeline

- (void)redrawTimeline:(BOOL)reload {
    [self.scrubberSelectionView setNeedsDisplay:YES];
    NSString *displayTime = [self.currentSequence currentDisplayTime];
    if (!displayTime) displayTime = @"00:00:00";
    [self.timeDisplay setStringValue:displayTime];
    [self updateScroller];
    if (reload) {
        [self.outlineHierarchy reloadData];
    }
}

- (void)redrawTimeline {
    [self redrawTimeline:YES];
}

#pragma mark Util

- (void)deleteSequenceId:(int)seqId {
    // Delete any keyframes for the sequence
    [[PCStageScene scene].rootNode deleteSequenceId:seqId];

    // Delete any chained sequence references
    for (SequencerSequence *seq in [AppDelegate appDelegate].currentDocument.sequences) {
        if (seq.chainedSequenceId == seqId) {
            seq.chainedSequenceId = -1;
        }
    }

    [[AppDelegate appDelegate] updateTimelineMenu];
}

- (void)deselectKeyframesForNode:(SKNode *)node {
    [node deselectAllKeyframes];

    // Also deselect keyframes of children
    for (SKNode *child in node.children) {
        [self deselectKeyframesForNode:child];
    }
}

- (void)deselectAllKeyframes {
    [self deselectKeyframesForNode:[PCStageScene scene].rootNode];
    [self.currentSequence.soundChannel.seqNodeProp deselectKeyframes];
    [self.currentSequence.callbackChannel.seqNodeProp deselectKeyframes];

    [self.outlineHierarchy reloadData];
}

- (BOOL)deleteSelectedKeyframesForCurrentSequence {
    BOOL didDelete = [[PCStageScene scene].rootNode deleteSelectedKeyframesForSequenceId:self.currentSequence.sequenceId];
    if (didDelete) {
        [[AppDelegate appDelegate] saveUndoStateDidChangePropertySkipSameCheck:@"*deletekeyframes"];
    }

    didDelete |= [self.currentSequence.callbackChannel.seqNodeProp deleteSelectedKeyframes];
    didDelete |= [self.currentSequence.soundChannel.seqNodeProp deleteSelectedKeyframes];

    if (didDelete) {
        [self redrawTimeline];
        [self updatePropertiesToTimelinePosition];
        [[AppDelegate appDelegate] updateInspectorFromSelection];
        [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*deletekeyframes"];
    }
    return didDelete;
}

- (void)deleteDuplicateKeyframesForCurrentSequence {
    BOOL didDelete = [[PCStageScene scene].rootNode deleteDuplicateKeyframesForSequenceId:self.currentSequence.sequenceId];

    if (didDelete) {
        [self redrawTimeline];
        [self updatePropertiesToTimelinePosition];
        [[AppDelegate appDelegate] updateInspectorFromSelection];
    }
}

- (void)deleteKeyframesForCurrentSequenceAfterTime:(float)time {
    [[PCStageScene scene].rootNode deleteKeyframesAfterTime:time sequenceId:self.currentSequence.sequenceId];
}

- (void)addSelectedKeyframesForChannel:(SequencerChannel *)channel ToArray:(NSMutableArray *)keyframes {
    for (SequencerKeyframe *keyframe in channel.seqNodeProp.keyframes) {
        if (keyframe.selected) {
            [keyframes addObject:keyframe];
        }
    }
}

- (void)addSelectedKeyframesForNode:(SKNode *)node toArray:(NSMutableArray *)keyframes {
    [node addSelectedKeyframesToArray:keyframes];

    // Also add selected keyframes of children
    for (SKNode *child in node.children) {
        [self addSelectedKeyframesForNode:child toArray:keyframes];
    }
}

- (NSArray *)selectedKeyframesForCurrentSequence {
    NSMutableArray *keyframes = [NSMutableArray array];
    [self addSelectedKeyframesForNode:[PCStageScene scene].rootNode toArray:keyframes];
    [self addSelectedKeyframesForChannel:self.currentSequence.callbackChannel ToArray:keyframes];
    [self addSelectedKeyframesForChannel:self.currentSequence.soundChannel ToArray:keyframes];
    return keyframes;
}

- (SequencerSequence *)seqId:(int)seqId inArray:(NSArray *)array {
    for (SequencerSequence *seq in array) {
        if (seq.sequenceId == seqId) return seq;
    }
    return NULL;
}

- (void)updatePropertiesToTimelinePositionForNode:(SKNode *)node sequenceId:(int)seqId localTime:(float)time {
    [node updatePropertiesTime:time sequenceId:seqId];

    // Also deselect keyframes of children
    for (SKNode *child in node.children) {
        int childSeqId = seqId;
        float localTime = time;

        // Sub ccb files uses different sequence id:s
        NSArray *childSequences = [child extraPropForKey:@"*sequences"];
        int childStartSequence = [[child extraPropForKey:@"*startSequence"] intValue];

        if (childSequences && childStartSequence != -1) {
            childSeqId = childStartSequence;
            SequencerSequence *seq = [self seqId:childSeqId inArray:childSequences];

            while (localTime > seq.timelineLength && seq.chainedSequenceId != -1) {
                localTime -= seq.timelineLength;
                seq = [self seqId:seq.chainedSequenceId inArray:childSequences];
                childSeqId = seq.sequenceId;
            }
        }

        [self updatePropertiesToTimelinePositionForNode:child sequenceId:childSeqId localTime:localTime];
    }
}

- (void)updatePropertiesToTimelinePosition {
    [self updatePropertiesToTimelinePositionForNode:[PCStageScene scene].rootNode sequenceId:self.currentSequence.sequenceId localTime:self.currentSequence.timelinePosition];
}

- (void)setCurrentSequence:(SequencerSequence *)sequence {
    if (sequence == _currentSequence) return;

    _currentSequence = sequence;

    [self.outlineHierarchy reloadData];
    [[AppDelegate appDelegate] updateTimelineMenu];
    [self redrawTimeline];
    [self updatePropertiesToTimelinePosition];
    [[AppDelegate appDelegate] updateInspectorFromSelection];
    [self updateScaleSlider];
}

- (void)menuSetSequence:(id)sender {
    int seqId = [sender tag];

    SequencerSequence *seqSet = NULL;
    for (SequencerSequence *seq in [AppDelegate appDelegate].currentDocument.sequences) {
        if (seq.sequenceId == seqId) {
            seqSet = seq;
            break;
        }
    }

    self.currentSequence = seqSet;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*selectedTimeline"];
}

- (void)menuSetChainedSequence:(id)sender {
    int seqId = [sender tag];
    if (seqId != self.currentSequence.chainedSequenceId) {
        self.currentSequence.chainedSequenceId = [sender tag];
        [[AppDelegate appDelegate] updateTimelineMenu];
        [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*chainedseqid"];
    }
}

- (void)sequencerDidMoveKeyframes {
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*keyframePositions"];
}

#pragma mark Easings

- (void)setContextKeyframeEasingType:(int)type {
    if (!self.contextKeyframe) return;
    if (self.contextKeyframe.easing.type == type) return;

    self.contextKeyframe.easing.type = type;
    [self redrawTimeline];

    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*keyframeeasing"];    
}

#pragma mark Adding keyframes

- (void)menuAddKeyframeNamed:(NSString *)prop {
    SequencerSequence* seq = self.currentSequence;
    
    NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
    for (SKNode *node in selectedNodes) {
        [node addDefaultKeyframeForProperty:prop atTime: seq.timelinePosition sequenceId:seq.sequenceId];
        node.seqExpanded = YES;
    }
    
    [self deleteDuplicateKeyframesForCurrentSequence];
}

- (BOOL)canInsertKeyframeNamed:(NSString *)prop {
    SKNode *node = [AppDelegate appDelegate].selectedSpriteKitNode;
    if (!node) return NO;
    if (!prop) return NO;

    if ([node shouldDisableProperty:prop]) return NO;

    return [[node.plugIn animatablePropertiesForSpriteKitNode:node] containsObject:prop];
}

#pragma mark - PC

- (NSArray *)filteredChildrenForNode:(SKNode *)node {
    NSMutableArray *children = [NSMutableArray array];
    for (SKNode *child in node.children) {
        if (child.hideFromUI) {
            [children addObjectsFromArray:[self filteredChildrenForNode:child]];
        }
        else {
            [children addObject:child];
        }
    }
    return children;
}

#pragma mark Destructor

- (void)dealloc {
    self.currentSequence = NULL;
    //self.sequences = NULL;
}

@end
