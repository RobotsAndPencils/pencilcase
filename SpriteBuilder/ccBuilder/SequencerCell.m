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

#import "PCResourceManager.h"
#import "SequencerCell.h"
#import "SequencerHandler.h"
#import "PlugInNode.h"
#import "SequencerNodeProperty.h"
#import "SequencerSequence.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerTimelineDrawDelegate.h"
#import "SequencerChannel.h"
#import "SequencerSoundChannel.h"
#import "SoundFileImageController.h"
#import "SKNode+Sequencer.h"
#import "SKNode+NodeInfo.h"
#import "ResourceManagerUtil.h"

@implementation SequencerCell

@synthesize node;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    return self;
}

- (void) drawPropertyRowToggle:(int) row property:(NSString*)propName withFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    // Draw background
    NSRect rowRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y-1+row*kCCBSeqDefaultRowHeight, cellFrame.size.width, kCCBSeqDefaultRowHeight+1);
    if (row == 0)
    {
        [self.imgRowBg0 drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }
    else if (row == 1)
    {
        [self.imgRowBg1 drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }
    else
    {
        [self.imgRowBgN drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }

    
    SequencerNodeProperty* nodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
    
    if (nodeProp)
    {        
        // Draw keyframes & and visibility
        NSArray* keyframes = nodeProp.keyframes;
        
        for (int i = 0; i < [keyframes count]; i++)
        {
            SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
            SequencerKeyframe* keyframeNext = NULL;
            if (i < [keyframes count]-1)
            {
                keyframeNext = [keyframes objectAtIndex:i+1];
            }
            float interpolDuration;
            int xPos = [seq timeToPosition:keyframe.time];
            
            // Draw visibility
            if ((i % 2) == 0)
            {
                // Draw interpolation line
                int xPosNext = 0;
                if (keyframeNext)
                {
                    xPosNext = [seq timeToPosition:keyframeNext.time];
                    interpolDuration = keyframeNext.time - keyframe.time;
                }
                else
                {
                    xPosNext = [seq timeToPosition:seq.timelineLength];
                    interpolDuration = seq.timelineLength-keyframe.time;
                }
                
                NSRect interpolRect = NSMakeRect(cellFrame.origin.x + xPos, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+1, xPosNext-xPos, 13);
                
                BOOL didDrawInterpolation = NO;
                
                if ([node conformsToProtocol:@protocol(SequencerTimelineDrawDelegate)]) {
                    SKNode<SequencerTimelineDrawDelegate> *delegate = (SKNode<SequencerTimelineDrawDelegate> *) node;
                    if ([delegate canDrawInterpolationForProperty:nodeProp.propName]) {
                        
                        id endValue = (keyframeNext) ? keyframeNext.value : nil;
                        [delegate drawInterpolationInRect:interpolRect forProperty:nodeProp.propName withStartValue:keyframe.value endValue:endValue andDuration:interpolDuration];
                        didDrawInterpolation = YES;
                    }
                }
                
                if (!didDrawInterpolation) {
                    [self.imgInterpolVis drawInRect:interpolRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:YES hints:nil];
                }
            }
            
            // Draw keyframes
            
            NSImage* img = NULL;
            if (i % 2 == 0)
            {
                if (keyframe.selected)
                {
                    img = self.imgKeyframeLSel;
                }
                else
                {
                    img = self.imgKeyframeL;
                }
            }
            else
            {
                if (keyframe.selected)
                {
                    img = self.imgKeyframeRSel;
                }
                else
                {
                    img = self.imgKeyframeR;
                }
            }

            CGRect targetRect = CGRectMake(cellFrame.origin.x + xPos-3, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+1, img.size.width, img.size.height);
            [img drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
        }
    }
}

- (BOOL) shouldDrawSelectedKeyframe:(SequencerKeyframe*)kf forNodeProp:(SequencerNodeProperty*)nodeProp
{
    if (kf.type == kCCBKeyframeTypeCallbacks
        || kf.type == kCCBKeyframeTypeSoundEffects)
    {
        NSArray* kfsAtTime = [nodeProp keyframesAtTime:kf.time];
        for (SequencerKeyframe* kfAtTime in kfsAtTime)
        {
            if (kfAtTime.selected) return YES;
        }
        
        return NO;
    }
    else
    {
        return kf.selected;
    }
}

-(void)drawSoundFileKeyframe:(SequencerSequence*)seq forKeyframe:(SequencerKeyframe*)keyframe withFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    NSString * fileName = (NSString*)(NSArray*)[ResourceManagerUtil relativePathForResourceWithUUID:keyframe.value[0]];
    
    if([fileName isEqualToString:@""])
        return;
    
    PCResourceManager * resourceManager = [PCResourceManager sharedManager];
    NSString* absFile = [resourceManager toAbsolutePath:fileName];
    if(absFile == nil)
        return;
    
    float pitch =[((NSNumber*)(NSArray*)keyframe.value[1]) floatValue];
    SoundFileImageController * soundFileController = [SoundFileImageController sharedInstance];
    float duration = [soundFileController getFileDuration:absFile];
    float repitchedDuration = duration / pitch;
    
    
    int xStarPos = [seq timeToPosition:keyframe.time];
    int xFinishPos = [seq timeToPosition:keyframe.time + repitchedDuration];
    
    cellFrame.size.width = xFinishPos - xStarPos;
    cellFrame.origin.x = cellFrame.origin.x + xStarPos;
    
    [soundFileController drawFrame:absFile withFrame:cellFrame];
}

- (void) drawPropertyRowForSeq:(SequencerSequence*) seq nodeProp:(SequencerNodeProperty*)nodeProp row:(int)row withFrame:(NSRect)cellFrame inView:(NSView*)controlView isChannel:(BOOL) isChannel
{
    BOOL isExpanded = NO;
    BOOL isSoundChannel = NO;
    if(isChannel)
    {
        if([self.channel isKindOfClass:[SequencerSoundChannel class]])
        {
            SequencerSoundChannel * soundChannel = (SequencerSoundChannel*)self.channel;
            isExpanded = soundChannel.isEpanded;
            isSoundChannel = YES;
        }
    }
    
    
    // Draw background
    NSRect rowRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + row*kCCBSeqDefaultRowHeight, cellFrame.size.width, kCCBSeqDefaultRowHeight);
    
    if (isChannel)
    {
        rowRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height - kCCBSeqDefaultRowHeight, cellFrame.size.width, kCCBSeqDefaultRowHeight);

        
        [self.imgRowBgChannel drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }
    else if (row == 0)
    {
        [self.imgRowBg0 drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }
    else if (row == 1)
    {
        [self.imgRowBg1 drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }
    else
    {
        [self.imgRowBgN drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }
    
    if (nodeProp)
    {
        // Draw keyframes & interpolation lines
        NSArray* keyframes = nodeProp.keyframes;
        for (int i = 0; i < [keyframes count]; i++)
        {
            SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
            SequencerKeyframe* keyframeNext = NULL;
            if (i + 1 < [keyframes count])
            {
                keyframeNext = [keyframes objectAtIndex:i+1];
            }
            
            int xPos = [seq timeToPosition:keyframe.time];
            
            // Dim interpolation if keyframes are equal
            float fraction = 1;
            if ([keyframe valueIsEqualTo:keyframeNext])
            {
                fraction = 0.5f;
            }
            
            if (keyframeNext && keyframe.easing.type != kCCBKeyframeEasingInstant)
            {
                // Draw interpolation line
                int xPosNext = [seq timeToPosition:keyframeNext.time];
                
                NSRect interpolRect = NSMakeRect(cellFrame.origin.x + xPos, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+5, xPosNext-xPos, 7);
                
                BOOL didDrawInterpolation = NO;
                
                if ([node conformsToProtocol:@protocol(SequencerTimelineDrawDelegate)]) {
                    SKNode<SequencerTimelineDrawDelegate> *delegate = (SKNode<SequencerTimelineDrawDelegate> *) node;
                    if ([delegate canDrawInterpolationForProperty:nodeProp.propName]) {
                        
                        id endValue = (keyframeNext) ? keyframeNext.value : nil;
                        [delegate drawInterpolationInRect:interpolRect forProperty:nodeProp.propName withStartValue:keyframe.value endValue:endValue andDuration:(keyframeNext.time-keyframe.time)];
                        didDrawInterpolation = YES;
                    }
                }
                
                if (!didDrawInterpolation) {
                    [self.imgInterpol drawInRect:interpolRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:YES hints:nil];
                }
                
                BOOL easeIn = keyframe.easing.hasEaseIn;
                BOOL easeOut = keyframe.easing.hasEaseOut;
                
                if (easeIn || easeOut)
                {
                    // Draw ease in/out
                    NSGraphicsContext* gc = [NSGraphicsContext currentContext];
                    [gc saveGraphicsState];
                    [NSBezierPath clipRect:interpolRect];
                    
                    if (easeIn)
                    {
                        CGRect targetRect = CGRectMake(cellFrame.origin.x + xPos + 5, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+7, self.imgEaseIn.size.width, self.imgEaseIn.size.height);
                        [self.imgEaseIn drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:YES hints:nil];
                    }
                    
                    if (easeOut)
                    {
                        CGRect targetRect = CGRectMake(cellFrame.origin.x + xPosNext - 18, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+7, self.imgEaseOut.size.width, self.imgEaseOut.size.height);
                        [self.imgEaseOut drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:YES hints:nil];
                    }
                
                    [gc restoreGraphicsState];
                }
            }
            
            //Draw audio image
            if(isSoundChannel)
            {
                [self drawSoundFileKeyframe:seq forKeyframe:keyframe withFrame:cellFrame inView:controlView];
            }
            
            // Draw keyframe
            NSImage* img = NULL;
            if ([self shouldDrawSelectedKeyframe:keyframe forNodeProp:nodeProp])
            {
                img = (isSoundChannel && isExpanded) ? self.imgKeyframeSelLrg : self.imgKeyframeSel;
            }
            else
            {
                img = (isSoundChannel && isExpanded) ? self.imgKeyframeLrg : self.imgKeyframe;
            }
            
            if (isChannel)
            {
                CGRect targetRect = CGRectMake(cellFrame.origin.x + xPos-3, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row, img.size.width, img.size.height);
                [img drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
            }
            else
            {
                CGRect targetRect = CGRectMake(cellFrame.origin.x + xPos-3, cellFrame.origin.y+kCCBSeqDefaultRowHeight*row+2, img.size.width, img.size.height);
                [img drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
            }
        }
    }
    
    if(isSoundChannel)
    {
        [self drawSoundDragAndDrop:seq withFrame:cellFrame];
    }
}

- (void) drawSoundDragAndDrop:(SequencerSequence*) seq withFrame:(NSRect)cellFrame
{
    if(!seq.soundChannel.needDragAndDropRedraw)
        return;
    
    seq.soundChannel.needDragAndDropRedraw = NO;
    
    int xPos = [seq timeToPosition:seq.soundChannel.dragAndDropTimeStamp];

    
    CGColorRef blueColor = [[NSColor blackColor] CGColor];
    
    NSGraphicsContext * graphicsContext = [NSGraphicsContext currentContext];
    CGContextRef context = [graphicsContext graphicsPort];
    
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, xPos + cellFrame.origin.x, cellFrame.origin.y );

    CGContextAddLineToPoint(context, xPos + cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height - 2);
    
    CGContextSetStrokeColorWithColor(context, blueColor);
    CGContextStrokePath(context);

}

- (void) drawPropertyRow:(int) row property:(NSString*)propName withFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    SequencerNodeProperty* nodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
    
    [self drawPropertyRowForSeq:seq nodeProp:nodeProp row:row withFrame:cellFrame inView:controlView isChannel:NO];
}

- (void) drawCollapsedProps:(NSArray*)props withFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    // Create a set with the times of keyframes
    NSMutableSet* keyframeTimes = [NSMutableSet set];
    for (NSString* propName in props)
    {
        SequencerNodeProperty* nodeProp = [node sequenceNodeProperty:propName sequenceId:seq.sequenceId];
        
        NSArray* keyframes = nodeProp.keyframes;
        for (SequencerKeyframe* kf in keyframes)
        {
            [keyframeTimes addObject:[NSNumber numberWithFloat: kf.time]];
        }
    }
    
    // Draw the keyframes
    for (NSNumber* timeVal in keyframeTimes)
    {
        float time = [timeVal floatValue];
        int xPos = [seq timeToPosition:time];

        CGRect targetRect = CGRectMake(cellFrame.origin.x + xPos -3,cellFrame.origin.y+3, self.imgKeyframeHint.size.width, self.imgKeyframeHint.size.height);
        [self.imgKeyframeHint drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSGraphicsContext* gc = [NSGraphicsContext currentContext];
    [gc saveGraphicsState];
    
    NSRect clipRect = cellFrame;
    clipRect.origin.y -= 1;
    clipRect.size.height += 1;
    clipRect.size.width += TIMELINE_PAD_PIXELS;
    [NSBezierPath clipRect:clipRect];
    
    if (!self.imagesLoaded)
    {
        self.imgKeyframe = [NSImage imageNamed:@"seq-keyframe.png"];
        self.imgKeyframeSel = [NSImage imageNamed:@"seq-keyframe-sel.png"];
        self.imgRowBg0 = [NSImage imageNamed:@"seq-row-0-bg.png"];
        self.imgRowBg1 = [NSImage imageNamed:@"seq-row-1-bg.png"];
        self.imgRowBgN = [NSImage imageNamed:@"seq-row-n-bg.png"];
        self.imgRowBgChannel = [NSImage imageNamed:@"seq-row-channel-bg.png"];
        self.imgInterpol = [NSImage imageNamed:@"seq-keyframe-interpol.png"];
        self.imgEaseIn = [NSImage imageNamed:@"seq-keyframe-easein.png"];
        self.imgEaseOut = [NSImage imageNamed:@"seq-keyframe-easeout.png"];
        self.imgInterpolVis = [NSImage imageNamed:@"seq-keyframe-interpol-vis.png"];
        self.imgKeyframeL = [NSImage imageNamed:@"seq-keyframe-l.png"];
        self.imgKeyframeR = [NSImage imageNamed:@"seq-keyframe-r.png"];
        self.imgKeyframeLSel = [NSImage imageNamed:@"seq-keyframe-l-sel.png"];
        self.imgKeyframeRSel = [NSImage imageNamed:@"seq-keyframe-r-sel.png"];
        self.imgKeyframeHint = [NSImage imageNamed:@"seq-keyframe-hint.png"];
        self.imgKeyframeLrg = [NSImage imageNamed:@"seq-keyframe-x4.png"];
        self.imgKeyframeSelLrg = [NSImage imageNamed:@"seq-keyframe-x4-sel.png"];
    }
    
    if (node)
    {
        NSArray* props = [node.plugIn animatablePropertiesForSpriteKitNode:node];
        for (int i = 0; i < [props count]; i++)
        {
            if (i==0 || (node.seqExpanded)) {
                NSString *propName = [props objectAtIndex:i];
                NSString *propType = [node.plugIn propertyTypeForProperty:propName];
                if ([@"Check" isEqualToString:propType]) {
                    [self drawPropertyRowToggle:i property:[props objectAtIndex:i] withFrame:cellFrame inView:controlView];
                } else {
                    [self drawPropertyRow:i property:[props objectAtIndex:i] withFrame:cellFrame inView:controlView];
                }
            }
        }
        // collapsed props are all animatable exept the first one!
        NSArray *collapsedProps = [props subarrayWithRange:NSMakeRange(1, [props count]-1)];
        [self drawCollapsedProps:collapsedProps withFrame:cellFrame inView:controlView];
    }
    else if (self.channel)
    {
        [self drawPropertyRowForSeq:[SequencerHandler sharedHandler].currentSequence nodeProp:self.channel.seqNodeProp row:0 withFrame:cellFrame inView:controlView isChannel:YES];
    }
    else
    {
        NSLog(@"Undefined row type!");
    }
    
    [gc restoreGraphicsState];
}


@end
