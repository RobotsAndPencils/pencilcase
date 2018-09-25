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

#import "PositionPropertySetter.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "AppDelegate.h"
#import "PCDeviceResolutionSettings.h"
#import "SKNode+NodeInfo.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+Sequencer.h"
#import "PCStageScene.h"

@implementation PositionPropertySetter

+ (CGSize) getParentSize:(SKNode*) node
{
    PCStageScene *scene = (PCStageScene *)node.scene;
    
    // Get parent size
    CGSize parentSize;
    if (scene.rootNode == node)
    {
        // This is the document root node
        parentSize = scene.stageSize;
    }
    else if (node.parent)
    {
        // This node has a parent
        parentSize = node.parent.contentSize;
    }
    else
    {
        // This is a node loaded from a sub-ccb file (or the node graph isn't loaded yet)
        NSLog(@"No parent!!!");
        parentSize = CGSizeZero;
    }
    return parentSize;
}

+ (void)addScaleKeyframeForNode:(SKNode*)node {
    float scaleX = [PositionPropertySetter scaleXForNode:node prop:@"scale"];
    float scaleY = [PositionPropertySetter scaleYForNode:node prop:@"scale"];
    
    // Update animated value
    NSArray* animValue = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:scaleX],
                          [NSNumber numberWithFloat:scaleY],
                          NULL];
    
    [PositionPropertySetter addKeyframeForNode:node value:animValue property:@"scale"];
}

+ (void)addKeyframeForNode:(SKNode*)node value:(id)value property:(NSString*)prop {

    NodeInfo* nodeInfo = node.userObject;
    PlugInNode* plugIn = nodeInfo.plugIn;
    
    if ([plugIn isAnimatableProperty:prop spriteKitNode:node]) {
        SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
        int seqId = seq.sequenceId;
        SequencerNodeProperty* seqNodeProp = [node sequenceNodeProperty:prop sequenceId:seqId];
        
        if (seqNodeProp) {
            SequencerKeyframe* keyframe = [seqNodeProp keyframeAtTime:seq.timelinePosition];
            if (keyframe) {
                keyframe.value = value;
            } else { //use this if you want to add a record feature
                SequencerKeyframe* keyframe = [[SequencerKeyframe alloc] init];
                keyframe.time = seq.timelinePosition;
                keyframe.value = value;
                keyframe.type = kCCBKeyframeTypePosition;
                keyframe.name = seqNodeProp.propName;

                [seqNodeProp addKeyframe:keyframe];
                [[AppDelegate appDelegate] updateInspectorFromSelection];
            }
            
            [[SequencerHandler sharedHandler] redrawTimeline];
        }
        else {
            [nodeInfo.baseValues setObject:value forKey:prop];
        }
    }
}

+ (void)addPositionKeyframeForSpriteKitNode:(SKNode *)node {
    NSPoint newPos = node.position;

    // Update animated value
    NSArray *value = @[ @(newPos.x), @(newPos.y) ];

    NodeInfo *nodeInfo = node.userObject;
    PlugInNode *plugIn = nodeInfo.plugIn;

    if ([plugIn isAnimatableProperty:@"position" spriteKitNode:node]) {
        SequencerSequence *currentSequence = [SequencerHandler sharedHandler].currentSequence;
        int seqId = currentSequence.sequenceId;
        SequencerNodeProperty *sequencerNodeProperty = [node sequenceNodeProperty:@"position" sequenceId:seqId];

        if (sequencerNodeProperty) {
            SequencerKeyframe *keyframe = [sequencerNodeProperty keyframeAtTime:currentSequence.timelinePosition];
            if (keyframe) {
                keyframe.value = value;
            }

            BOOL sequenceIsDefault = (currentSequence.sequenceId == CardDefaultSequenceId);
            BOOL keyframeIsFirst = ([sequencerNodeProperty.keyframes indexOfObject:keyframe] == 0);
            if (sequenceIsDefault && keyframeIsFirst) {
                nodeInfo.baseValues[@"position"] = value;
            }

            [[SequencerHandler sharedHandler] redrawTimeline];
        }
        else {
            nodeInfo.baseValues[@"position"] = value;
        }
    }
}

+ (void)setPosition:(NSPoint)pos forSpriteKitNode:(SKNode *)node prop:(NSString *)prop {
    [node setValue:[NSValue valueWithPoint:pos] forKey:prop];
}

+ (NSPoint) positionForNode:(SKNode*)node prop:(NSString*)prop
{
    return [[node valueForKey:prop] pointValue];
}

+ (void) setSize:(NSSize)size forSpriteKitNode:(SKNode *)node prop:(NSString *)prop
{
    [node setValue:[NSValue valueWithSize:size] forKey:prop];
}

+ (NSSize) sizeForNode:(SKNode*)node prop:(NSString*)prop
{
    return [[node valueForKey:prop] sizeValue];
}

+ (void) setScaledX:(float)scaleX Y:(float)scaleY forSpriteKitNode:(SKNode*)node prop:(NSString*)prop
{
    [node setValue:@(scaleX) forKey:[prop stringByAppendingString:@"X"]];
    [node setValue:@(scaleY) forKey:[prop stringByAppendingString:@"Y"]];
}

+ (float) scaleXForNode:(SKNode*)node prop:(NSString*)prop
{
    NSNumber* scale = [node extraPropForKey:[prop stringByAppendingString:@"X"]];
    if(!scale)
        scale = [node valueForKey:[prop stringByAppendingString:@"X"]];
        
    if (!scale)
        return 1;
    
    return [scale floatValue];
}

+ (float) scaleYForNode:(SKNode*)node prop:(NSString*)prop
{
    NSNumber* scale = [node extraPropForKey:[prop stringByAppendingString:@"Y"]];
    
    if(!scale)
        scale = [node valueForKey:[prop stringByAppendingString:@"Y"]];

    if (!scale)
        return 1;
    return [scale floatValue];
}

+ (int) scaledFloatTypeForNode:(SKNode*)node prop:(NSString*)prop
{
    return [[node extraPropForKey:[NSString stringWithFormat:@"%@Type", prop]] intValue];
}

+ (void) setFloatScale:(float)f forNode:(SKNode*)node prop:(NSString*)prop
{
    float absF = f;

    [node setValue:@(absF) forKey:prop];
    
    [node setExtraProp:@(f) forKey:prop];
}

+ (float) floatScaleForNode:(SKNode*)node prop:(NSString*)prop
{
    NSNumber* scale = [node extraPropForKey:prop];
    if (!scale) return [[node valueForKey:prop] floatValue];
    return [scale floatValue];
}

@end
