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

#import "SequencerUtil.h"
#import "AppDelegate.h"
#import "PCResourceManager.h"
#import "ResourceManagerUtil.h"
#import "SKNode+NodeInfo.h"
#import "PlugInNode.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerNodeProperty.h"
#import "CCBWriterInternal.h"
#import "SKNode+Sequencer.h"
#import "PCNodeManager.h"
#import "ResourceManagerOutlineView.h"

@implementation SequencerUtil

+ (NSArray*) selectedResources
{
    NSMutableArray* selRes = [NSMutableArray array];
    
    NSOutlineView* outlineView = [AppDelegate appDelegate].resourceOutlineView;
    NSIndexSet* idxSet = [outlineView selectedRowIndexes];
    
    NSUInteger idx = [idxSet firstIndex];
    while (idx != NSNotFound)
    {
        [selRes addObject:[outlineView itemAtRow:idx]];
        idx = [idxSet indexGreaterThanIndex:idx];
    }
    
    return selRes;
}

+ (void) removeDuplicateKeyframesForSelection
{
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    
    // Find all affected seqNodeProps
    NSMutableSet* seqNodeProps = [NSMutableSet set];
    for (SequencerKeyframe* kf in keyframes)
    {
        [seqNodeProps addObject:kf.parent];
    }
    
    for (SequencerNodeProperty* seqNodeProp in seqNodeProps)
    {
        [seqNodeProp deleteDuplicateKeyframes];
    }
}

+ (BOOL) canCreateFramesFromSelectedResources
{
    // Check that all selected resources are images
    NSArray* selRes = [SequencerUtil selectedResources];
    
    for (id selectedObj in selRes)
    {
        if ([selectedObj isKindOfClass:[PCResource class]])
        {
            PCResource * res = selectedObj;
            if (res.type != PCResourceTypeImage)
            {
                return NO;
            }
        }
    }
    return YES;
}

+ (void) createFramesFromSelectedResources
{
    if (![SequencerUtil canCreateFramesFromSelectedResources]) return;
    
    SequencerSequence *sequence = [SequencerHandler sharedHandler].currentSequence;
    NSArray *selectedImages = [SequencerUtil selectedResources];
    
    CGFloat currentTime = sequence.timelinePosition;
    
    for (id item in selectedImages) {
        NSString *spriteUUID = @"";
        
        if ([item isKindOfClass:[PCResource class]]) {
            PCResource *resource = item;
            spriteUUID = resource.uuid;
        }
        
        // Create keyframe
        SequencerKeyframe* keyframe = [[SequencerKeyframe alloc] init];
        keyframe.time = currentTime;
        keyframe.type = kCCBKeyframeTypeSpriteFrame;
        keyframe.name = @"spriteFrame";
        keyframe.value = spriteUUID;
        keyframe.easing.type = kCCBKeyframeEasingInstant;
        
        // Add the keyframe
        NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
        for (SKNode *node in selectedNodes) {
            // Check that the selected object is a sprite
            if (![node.className isEqualToString:@"CCBPSKSprite"]){
                continue;
            }
            [node addKeyframe:keyframe forProperty:@"spriteFrame" atTime:currentTime sequenceId:sequence.sequenceId];
        }
        
        // Step one keyframe ahead
        currentTime = [sequence alignTimeToResolution:currentTime + 1 / sequence.timelineResolution];
    }
}

+ (BOOL) canAlignKeyframesToMarker
{
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    
    if (keyframes.count == 0) return NO;
    
    SequencerSequence* seq = [[SequencerHandler sharedHandler] currentSequence];
    for (SequencerKeyframe* kf in keyframes)
    {
        if (kf.time != seq.timelinePosition) return YES;
    }
    
    return NO;
}

+ (void) alignKeyframesToMarker
{
    BOOL canAlign = [SequencerUtil canAlignKeyframesToMarker];
    if (!canAlign) return;
    
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    SequencerSequence* seq = [[SequencerHandler sharedHandler] currentSequence];
    
    for (SequencerKeyframe* kf in keyframes)
    {
        kf.time = seq.timelinePosition;
    }
    
    [SequencerUtil removeDuplicateKeyframesForSelection];
    
    [[SequencerHandler sharedHandler] redrawTimeline];
    [[SequencerHandler sharedHandler] updatePropertiesToTimelinePosition];
    
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*alignKeyframesToMarker"];
}

+ (BOOL) canStretchSelectedKeyframes
{
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    
    if (keyframes.count < 2) return NO;
    return YES;
}

+ (void) stretchSelectedKeyframes:(float) factor
{
    BOOL canStrech = [SequencerUtil canStretchSelectedKeyframes];
    if (!canStrech) return;
    
    SequencerSequence* seq = [[SequencerHandler sharedHandler] currentSequence];
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    
    // Find time of first keyframe
    float timeFirst = MAXFLOAT;
    for (SequencerKeyframe* kf in keyframes)
    {
        if (kf.time < timeFirst) timeFirst = kf.time;
    }
    
    // Stretch the keyframes
    for (SequencerKeyframe* kf in keyframes)
    {
        float delta = kf.time - timeFirst;
        delta *= factor;
        float newTime = [seq alignTimeToResolution: timeFirst + delta];
        if (newTime > seq.timelineLength) newTime = seq.timelineLength;
        kf.time = newTime;
    }
    
    [SequencerUtil removeDuplicateKeyframesForSelection];
    
    [[SequencerHandler sharedHandler] redrawTimeline];
    [[SequencerHandler sharedHandler] updatePropertiesToTimelinePosition];
    
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*stretchSelectedKeyframes"];
}

+ (BOOL) canReverseSelectedKeyframes
{
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    
    if (keyframes.count < 2) return NO;
    return YES;
}

+ (void) reverseSelectedKeyframes
{
    BOOL canReverse = [SequencerUtil canReverseSelectedKeyframes];
    if (!canReverse) return;
    
    SequencerSequence* seq = [[SequencerHandler sharedHandler] currentSequence];
    NSArray* keyframes = [[SequencerHandler sharedHandler] selectedKeyframesForCurrentSequence];
    
    // Find time of first & last keyframe
    float timeFirst = MAXFLOAT;
    float timeLast = 0;
    for (SequencerKeyframe* kf in keyframes)
    {
        if (kf.time < timeFirst) timeFirst = kf.time;
        if (kf.time > timeLast) timeLast = kf.time;
    }
    
    // Reverse the keyframes
    for (SequencerKeyframe* kf in keyframes)
    {
        // Reset easing for the keyframe
        if (![kf supportsFiniteTimeInterpolations])
        {
            kf.easing.type = kCCBKeyframeEasingInstant;
        }
        else
        {
            kf.easing.type = kCCBKeyframeEasingLinear;
        }
        
        // Move keyframe
        float delta = kf.time - timeFirst;
        //float delta2 = reverseLen - delta;
        
        NSLog(@"first: %f last: %f delta2: %f", timeFirst, timeLast, delta);
        
        kf.time = [seq alignTimeToResolution: timeLast - delta];
    }
    
    [SequencerUtil removeDuplicateKeyframesForSelection];
    
    [[SequencerHandler sharedHandler] redrawTimeline];
    [[SequencerHandler sharedHandler] updatePropertiesToTimelinePosition];
    
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*reverseSelectedKeyframes"];    
}

@end
