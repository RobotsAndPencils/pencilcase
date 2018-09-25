//
//  SKNode(Sequencer) 
//  SpriteBuilder
//
//  Created by brandon on 14-06-26.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

// Header
#import "SKNode+Sequencer.h"

// Categories
#import "SKNode+NodeInfo.h"
#import "SKNode+CocosCompatibility.h"

// Project
#import "PCStageScene.h"
#import "PlugInNode.h"
#import "SequencerSequence.h"
#import "SequencerHandler.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerKeyframe.h"
#import "ResourcePropertySetter.h"
#import "CCBReaderInternal.h"
#import "AppDelegate.h"
#import "CCBWriterInternal.h"
#import "SequencerNodeProperty.h"
#import "PositionPropertySetter.h"
#import "NodeInfo.h"

@implementation SKNode (Sequencer)

- (SequencerNodeProperty *)sequenceNodeProperty:(NSString *)name sequenceId:(int)seqId {
    NodeInfo *info = self.userObject;
    NSDictionary *dict = info.animatableProperties[@(seqId)];
    return dict[name];
}

- (id)valueForProperty:(NSString *)name atTime:(CGFloat)time sequenceId:(int)seqId {
    SequencerNodeProperty *seqNodeProp = [self sequenceNodeProperty:name sequenceId:seqId];

    CCBKeyframeType keyframeType = [SequencerKeyframe keyframeTypeFromPropertyType:[self.plugIn propertyTypeForProperty:name]];

    // Check that keyframeType is supported
    NSAssert(keyframeType != kCCBKeyframeTypeUndefined, @"Unsupported keyframe type (%@)",[self.plugIn propertyTypeForProperty:name]);

    if (seqNodeProp) {
        id sequenceValue = [seqNodeProp valueAtTime:time];
        if (sequenceValue) return sequenceValue;
    }

    // Check for base value
    NodeInfo *info = self.userObject;

    id baseValue = info.baseValues[name];
    if (baseValue) return baseValue;

    // Just use standard value
    if (keyframeType == kCCBKeyframeTypeDegrees) {
        return @([[self valueForKey:name] floatValue]);
    }
    else if (keyframeType == kCCBKeyframeTypeByte || keyframeType == kCCBKeyframeTypeFloat) {
        return [self valueForKey:name];
    }
    else if (keyframeType == kCCBKeyframeTypePosition) {
        NSPoint pos = self.position;
        return @[ @(pos.x), @(pos.y) ];
    }
    else if (keyframeType == kCCBKeyframeTypeScaleLock) {
        return @[ @(self.xScale), @(self.yScale) ];
    }
    else if (keyframeType == kCCBKeyframeTypeToggle) {
        return [self valueForKey:name];
    }
    else if (keyframeType == kCCBKeyframeTypeColor3) {
        NSColor *color = [self valueForKey:name];
        return [CCBWriterInternal serializeNSColor:color];
    }
    else if (keyframeType == kCCBKeyframeTypeSpriteFrame) {
        NSString *sprite = [self extraPropForKey:name];
        return PCIsEmpty(sprite) ? @"" : sprite;
    }
    else if (keyframeType == kCCBKeyframeTypeFloatXY) {
        float x = [[self valueForKey:[name stringByAppendingString:@"X"]] floatValue];
        float y = [[self valueForKey:[name stringByAppendingString:@"Y"]] floatValue];
        return @[ @(x), @(y) ];
    }

    return nil;
}

- (void)deleteSequenceId:(int)seqId {
    NodeInfo *info = self.userObject;
    [info.animatableProperties removeObjectForKey:@(seqId)];

    // Also remove for children
    for (SKNode *child in self.children) {
        [child deleteSequenceId:seqId];
    }
}

- (BOOL)deleteSelectedKeyframesForSequenceId:(int)sequenceId {
    BOOL deletedKeyframe = NO;
    NodeInfo *info = self.userObject;

    NSMutableDictionary *animatedProperties = info.animatableProperties[@(sequenceId)];
    if (animatedProperties) {
        NSMutableArray *emptyProperties = [NSMutableArray array];
        for (NSString *propertyName in animatedProperties) {
            SequencerNodeProperty *nodeProperty = animatedProperties[propertyName];
            deletedKeyframe |= [nodeProperty deleteSelectedKeyframes];

            if (nodeProperty.keyframes.count == 0) {
                [emptyProperties addObject:propertyName];
            }
        }

        // Remove empty sequence node properties
        for (NSString *propertyName in emptyProperties) {
            [animatedProperties removeObjectForKey:propertyName];
        }
    }

    // Also remove keyframes for children
    for (SKNode *child in self.children) {
        if ([child deleteSelectedKeyframesForSequenceId:sequenceId]) {
            deletedKeyframe = YES;
        }
    }

    return deletedKeyframe;
}

- (BOOL)deleteDuplicateKeyframesForSequenceId:(int)seqId {
    BOOL deletedKeyframe = NO;

    NodeInfo *info = self.userObject;
    NSMutableDictionary *seq = info.animatableProperties[@(seqId)];
    if (seq) {
        NSEnumerator *seqEnum = [seq objectEnumerator];
        SequencerNodeProperty *seqNodeProp;
        while ((seqNodeProp = [seqEnum nextObject])) {
            if ([seqNodeProp deleteDuplicateKeyframes]) {
                deletedKeyframe = YES;
            }
        }
    }

    // Also remove keyframes for children
    for (SKNode *child in self.children) {
        if ([child deleteDuplicateKeyframesForSequenceId:seqId]) {
            deletedKeyframe = YES;
        }
    }
    return deletedKeyframe;
}

- (void)deselectAllKeyframes {
    NodeInfo *info = self.userObject;

    NSEnumerator *animPropEnum = [info.animatableProperties objectEnumerator];
    NSDictionary *seq;
    while ((seq = [animPropEnum nextObject])) {
        NSEnumerator *seqEnum = [seq objectEnumerator];
        SequencerNodeProperty *prop;
        while ((prop = [seqEnum nextObject])) {
            [prop deselectKeyframes];
        }
    }
}

- (void)addSelectedKeyframesToArray:(NSMutableArray *)keyframes {
    NodeInfo *info = self.userObject;

    NSEnumerator *animPropEnum = [info.animatableProperties objectEnumerator];
    NSDictionary *seq;
    while ((seq = [animPropEnum nextObject])) {
        NSEnumerator *seqEnum = [seq objectEnumerator];
        SequencerNodeProperty *prop;
        while ((prop = [seqEnum nextObject])) {
            for (SequencerKeyframe *keyframe in prop.keyframes) {
                if (keyframe.selected) {
                    [keyframes addObject:keyframe];
                }
            }
        }
    }
}

- (void)updateProperty:(NSString *)propName time:(float)time sequenceId:(int)seqId {
    CCBKeyframeType type = [SequencerKeyframe keyframeTypeFromPropertyType:[self.plugIn propertyTypeForProperty:propName]];
    if (type == kCCBKeyframeTypeUndefined) {
        return;
    }

    id value = [self valueForProperty:propName atTime:time sequenceId:seqId];

    if (type == kCCBKeyframeTypeDegrees) {
        [self setValue:value forKey:propName];
    }
    else if (type == kCCBKeyframeTypePosition) {
        NSPoint pos = NSZeroPoint;
        pos.x = [value[0] floatValue];
        pos.y = [value[1] floatValue];

        [PositionPropertySetter setPosition:pos forSpriteKitNode:self prop:propName];
    }
    else if (type == kCCBKeyframeTypeScaleLock) {
        float x = [value[0] floatValue];
        float y = [value[1] floatValue];
        [PositionPropertySetter setScaledX:x Y:y forSpriteKitNode:self prop:propName];
    }
    else if (type == kCCBKeyframeTypeToggle) {
        [self setValue:value forKey:propName];
    }
    else if (type == kCCBKeyframeTypeColor3) {
        NSColor *color = [CCBReaderInternal deserializeNSColor:value];
        [self setValue:color forKey:propName];
    }
    else if (type == kCCBKeyframeTypeSpriteFrame) {
        [ResourcePropertySetter setResourceWithUUID:value forProperty:propName onNode:self];
    }
    else if (type == kCCBKeyframeTypeByte
        || type == kCCBKeyframeTypeFloat) {
        [self setValue:value forKey:propName];
    }
    else if (type == kCCBKeyframeTypeFloatXY) {
        float x = [value[0] floatValue];
        float y = [value[1] floatValue];

        [self setValue:@(x) forKey:[propName stringByAppendingString:@"X"]];
        [self setValue:@(y) forKey:[propName stringByAppendingString:@"Y"]];
    }
}

- (void)addKeyframe:(SequencerKeyframe *)keyframe forProperty:(NSString *)name atTime:(float)time sequenceId:(int)seqId {
    // Check so we are not adding a keyframe out of bounds
    NSArray *seqs = [AppDelegate appDelegate].currentDocument.sequences;
    SequencerSequence *seq;
    for (SequencerSequence *seqt in seqs) {
        if (seqt.sequenceId == seqId) {
            seq = seqt;
            break;
        }
    }
    if (time > seq.timelineLength) return;

    //If not supported as animatable type, don't add.
    if (![[self.plugIn animatablePropertiesForSpriteKitNode:self] containsObject:name]) {
        return;
    }

    // Make sure timeline is enabled for this property
    [self enableSequenceNodeProperty:name sequenceId:seqId];

    // Add the keyframe
    SequencerNodeProperty *seqNodeProp = [self sequenceNodeProperty:name sequenceId:seqId];
    keyframe.parent = seqNodeProp;
    [seqNodeProp addKeyframe:keyframe];

    // Update property inspector
    [[AppDelegate appDelegate] updateInspectorFromSelection];
    [[SequencerHandler sharedHandler] redrawTimeline];
    [self updateProperty:name time:[SequencerHandler sharedHandler].currentSequence.timelinePosition sequenceId:seqId];
    
    // Save undo state
    [[AppDelegate appDelegate] saveUndoStateDidChangePropertySkipSameCheck:@"*addkeyframe"];
}

- (void)enableSequenceNodeProperty:(NSString *)name sequenceId:(int)seqId {
    // Check if animations are already enabled for this node property
    if ([self sequenceNodeProperty:name sequenceId:seqId]) {
        return;
    }

    // Get the right seqence, create one if neccessary
    NodeInfo *info = self.userObject;
    NSMutableDictionary *sequences = info.animatableProperties[@(seqId)];
    if (!sequences) {
        sequences = [NSMutableDictionary dictionary];
        info.animatableProperties[@(seqId)] = sequences;
    }

    id baseValue = [self valueForProperty:name atTime:0 sequenceId:seqId];

    SequencerNodeProperty *seqNodeProp = [[SequencerNodeProperty alloc] initWithProperty:name node:self];
    if (!info.baseValues[name]) {
        info.baseValues[name] = baseValue;
    }

    sequences[name] = seqNodeProp;
}

- (SequencerKeyframe *)addDefaultKeyframeForProperty:(NSString *)name atTime:(CGFloat)time sequenceId:(int)seqId {
    // Get property type
    NSString *propType = [self.plugIn propertyTypeForProperty:name];
    CCBKeyframeType keyframeType = [SequencerKeyframe keyframeTypeFromPropertyType:propType];

    // Ensure that the keyframe type is supported
    if (keyframeType == kCCBKeyframeTypeUndefined) {
        return nil;
    }

    // Ensure that the keyframe type is animated
    if (![[self.plugIn animatablePropertiesForSpriteKitNode:self] containsObject:name]) {
        return nil;
    }

    // Do not add keyframes for disabled properties
    if ([self shouldDisableProperty:name])
        return nil;

    // Create keyframe
    SequencerKeyframe *keyframe = [[SequencerKeyframe alloc] init];
    keyframe.time = time;
    keyframe.type = keyframeType;
    keyframe.name = name;

    if (![keyframe supportsFiniteTimeInterpolations]) {
        keyframe.easing.type = kCCBKeyframeEasingInstant;
    }

    if (keyframeType == kCCBKeyframeTypeToggle) {
        // Values for toggle keyframes are ignored (each keyframe toggles the state)
        keyframe.value = @YES;
    }
    else {
        // Get the interpolated value
        keyframe.value = [self valueForProperty:name atTime:time sequenceId:seqId];
    }

    [self addKeyframe:keyframe forProperty:name atTime:time sequenceId:seqId];
    return keyframe;
}

- (void)duplicateKeyframesFromSequenceId:(int)fromSeqId toSequenceId:(int)toSeqId {
    NodeInfo *info = self.userObject;

    NSMutableDictionary *fromNodeProps = info.animatableProperties[@(fromSeqId)];
    if (fromNodeProps) {
        for (NSString *propName in fromNodeProps) {
            SequencerNodeProperty *fromSeqNodeProp = fromNodeProps[propName];
            SequencerNodeProperty *toSeqNodeProp = [fromSeqNodeProp duplicate];

            [self enableSequenceNodeProperty:propName sequenceId:toSeqId];

            NSMutableDictionary *toNodeProps = info.animatableProperties[@(toSeqId)];
            [toNodeProps setObject:toSeqNodeProp forKey:propName];
        }
    }


    // Also do for children
    for (SKNode *child in self.children) {
        [child duplicateKeyframesFromSequenceId:fromSeqId toSequenceId:toSeqId];
    }
}

- (void)updatePropertiesTime:(float)time sequenceId:(int)seqId {
    NSArray *animatableProps = [self.plugIn animatablePropertiesForSpriteKitNode:self];
    for (NSString *propName in animatableProps) {
        [self updateProperty:propName time:time sequenceId:seqId];
    }
}

- (void)deleteKeyframesAfterTime:(float)time sequenceId:(int)seqId {

    NodeInfo *info = self.userObject;
    NSMutableDictionary *seq = info.animatableProperties[@(seqId)];

    if (seq) {

        NSEnumerator *seqEnum = [seq objectEnumerator];
        SequencerNodeProperty *seqNodeProp;
        NSMutableArray *emptyProps = [NSMutableArray array];

        while ((seqNodeProp = [seqEnum nextObject])) {
            [seqNodeProp deleteKeyframesAfterTime:time];

            if (seqNodeProp.keyframes.count == 0) {
                [emptyProps addObject:seqNodeProp.propName];
            }
        }

        // Remove empty seq node props
        for (NSString *propName in emptyProps) {
            [seq removeObjectForKey:propName];
        }
    }
    // Also remove keyframes for children
    for (SKNode *child in self.children) {
        [child deleteKeyframesAfterTime:time sequenceId:seqId];
    }
    
    [[AppDelegate appDelegate] saveUndoStateDidChangePropertySkipSameCheck:@"*deletekeyframes"];
}

- (NSArray *)keyframesForProperty:(NSString *)prop {
    NSMutableArray *keyframes = [NSMutableArray array];

    NodeInfo *info = self.userObject;

    NSEnumerator *animPropEnum = [info.animatableProperties objectEnumerator];
    NSDictionary *seq;
    while ((seq = [animPropEnum nextObject])) {
        SequencerNodeProperty *seqNodeProp = seq[prop];
        if (seqNodeProp) {
            [keyframes addObjectsFromArray:seqNodeProp.keyframes];
        }
    }
    return keyframes;
}

- (BOOL)hasKeyframesForProperty:(NSString *)prop {
    NodeInfo *info = self.userObject;

    NSEnumerator *animPropEnum = [info.animatableProperties objectEnumerator];
    NSDictionary *seq;
    while ((seq = [animPropEnum nextObject])) {
        SequencerNodeProperty *seqNodeProp = seq[prop];
        if (seqNodeProp) {
            if ([seqNodeProp.keyframes count]) return YES;
        }
    }
    return NO;
}

- (BOOL)shouldDisableProperty:(NSString *)prop {
    // Disable properties on root node
    if (self == [PCStageScene scene].rootNode) {
        if ([prop isEqualToString:@"position"]) return YES;
        else if ([prop isEqualToString:@"scale"]) return YES;
        else if ([prop isEqualToString:@"rotation"]) return YES;
        else if ([prop isEqualToString:@"tag"]) return YES;
        else if ([prop isEqualToString:@"visible"]) return YES;
        else if ([prop isEqualToString:@"skew"]) return YES;
    }

    // Disable position property for nodes handled by layouts
    return NO;
}

- (id)serializeAnimatedProperties {
    NodeInfo *info = self.userObject;
    NSMutableDictionary *animatableProps = info.animatableProperties;
    if (!animatableProps.count) {
        return nil;
    }

    NSMutableDictionary *serAnimatableProps = [NSMutableDictionary dictionaryWithCapacity:animatableProps.count];
    for (NSNumber *seqId in animatableProps) {
        NSMutableDictionary *properties = animatableProps[seqId];
        NSMutableDictionary *serProperties = [NSMutableDictionary dictionaryWithCapacity:animatableProps.count];

        for (NSString *propName in properties) {
            BOOL useFlashSkews = [self usesFlashSkew];
            if (useFlashSkews && [propName isEqualToString:@"rotation"]) continue;
            if (!useFlashSkews && [propName isEqualToString:@"rotationX"]) continue;
            if (!useFlashSkews && [propName isEqualToString:@"rotationY"]) continue;

            SequencerNodeProperty *seqNodeProp = properties[propName];
            [serProperties setObject:[seqNodeProp serialization] forKey:propName];
        }

        [serAnimatableProps setObject:serProperties forKey:[seqId stringValue]];
    }

    return serAnimatableProps;
}

- (void)loadAnimatedPropertiesFromSerialization:(id)ser {
    NodeInfo *info = self.userObject;

    if (!ser) {
        info.animatableProperties = [NSMutableDictionary dictionary];
        return;
    }

    NSMutableDictionary *serAnimatableProps = ser;
    NSMutableDictionary *animatableProps = [NSMutableDictionary dictionaryWithCapacity:serAnimatableProps.count];

    for (NSString *seqId in serAnimatableProps) {
        NSMutableDictionary *serProperties = serAnimatableProps[seqId];
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:serProperties.count];

        for (NSString *propName in serProperties) {
            SequencerNodeProperty *seqNodeProp = [[SequencerNodeProperty alloc] initWithSerialization:serProperties[propName]];
            [properties setObject:seqNodeProp forKey:propName];
        }

        NSNumber *seqIdNum = @([seqId intValue]);

        [animatableProps setObject:properties forKey:seqIdNum];
    }

    info.animatableProperties = animatableProps;
}

#pragma mark - Updating Animatable Properties

- (void)updateAnimateablePropertyValue:(id)value propName:(NSString *)propertyName {
    [self updateAnimateablePropertyValue:value propName:propertyName andCreateKeyFrameIfNone:NO withType:0];
}

- (void)updateAnimateablePropertyValue:(id)value propName:(NSString *)propertyName andCreateKeyFrameIfNone:(BOOL)createKeyframe withType:(int)type {
    PlugInNode *plugIn = self.plugIn;
    NodeInfo *nodeInfo = self.userObject;
    SequencerHandler *sequenceHandler = [SequencerHandler sharedHandler];
    
    if (![plugIn isAnimatableProperty:propertyName spriteKitNode:self]) {
        return;
    }

    SequencerSequence *currentSequence = sequenceHandler.currentSequence;
    SequencerNodeProperty *sequencerNodeProperty = [self sequenceNodeProperty:propertyName sequenceId:currentSequence.sequenceId];
    
    if (sequencerNodeProperty) {
        SequencerKeyframe *keyframe = [sequencerNodeProperty keyframeAtTime:currentSequence.timelinePosition];
        if (keyframe) {
            keyframe.value = value;
        }
        else if (createKeyframe) {
            keyframe = [[SequencerKeyframe alloc] init];
            keyframe.time = currentSequence.timelinePosition;
            keyframe.value = value;
            keyframe.type = type;
            keyframe.name = sequencerNodeProperty.propName;

            [sequencerNodeProperty addKeyframe:keyframe];
        }

        BOOL sequenceIsDefault = (currentSequence.sequenceId == CardDefaultSequenceId);
        BOOL keyframeIsFirst = ([sequencerNodeProperty.keyframes indexOfObject:keyframe] == 0);
        if (sequenceIsDefault && keyframeIsFirst) {
            nodeInfo.baseValues[propertyName] = value;
        }
        
        [sequenceHandler redrawTimeline];
    }
    else {
        NodeInfo *nodeInfo = self.userObject;
        [nodeInfo.baseValues setObject:value forKey:propertyName];
    }
}

- (void)updateAnimateablePropertyAndAllKeyFrames:(NSString *)propertyName currentValue:(id)currentValue updateBlock:(id (^)(id currentValue))updateBlock {
    PlugInNode *plugIn = self.plugIn;
    SequencerHandler *sequenceHandler = [SequencerHandler sharedHandler];
    
    if ([plugIn isAnimatableProperty:propertyName spriteKitNode:self]) {
        NSArray *sequences = [AppDelegate appDelegate].currentDocument.sequences;
        
        // Iterate over all keyframes and call update block on them.
        for (SequencerSequence *sequence in sequences) {
            int sequenceID = sequence.sequenceId;
            SequencerNodeProperty *sequenceNodeProperty = [self sequenceNodeProperty:propertyName sequenceId:sequenceID];
            
            if (sequenceNodeProperty) {
                for (SequencerKeyframe *keyframe in sequenceNodeProperty.keyframes) {
                    keyframe.value = updateBlock(keyframe.value);
                    
                }
                [sequenceHandler redrawTimeline];
            }
        }
        
        // Update base value
        NodeInfo *nodeInfo = self.userObject;
        if (nodeInfo.baseValues[propertyName]) {
            nodeInfo.baseValues[propertyName] = updateBlock(nodeInfo.baseValues[propertyName]);
        }
    }
}

- (NSArray *)allSequencerIds {
    NodeInfo *info = self.userObject;
    return [info.animatableProperties allKeys];
}

- (void)remapSequencersWithMapping:(NSDictionary *)newSequenceMap {
    NodeInfo *info = self.userObject;
    NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
    for (NSNumber *originalKey in info.animatableProperties.allKeys) {
        NSNumber *newKey = newSequenceMap[originalKey] ?: originalKey;
        newDictionary[newKey] = info.animatableProperties[originalKey];
    }
    info.animatableProperties = newDictionary;
}

@end
