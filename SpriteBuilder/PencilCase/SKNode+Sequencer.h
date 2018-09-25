//
//  SKNode(Sequencer) 
//  SpriteBuilder
//
//  Created by brandon on 14-06-26.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SequencerNodeProperty;
@class SequencerKeyframe;

@interface SKNode (Sequencer)

- (SequencerNodeProperty *)sequenceNodeProperty:(NSString *)name sequenceId:(int)seqId;
- (void)enableSequenceNodeProperty:(NSString *)name sequenceId:(int)seqId;
- (void)duplicateKeyframesFromSequenceId:(int)fromSeqId toSequenceId:(int)toSeqId;
- (id)valueForProperty:(NSString *)name atTime:(CGFloat)time sequenceId:(int)seqId;
- (void)deleteSequenceId:(int)seqId;

/**
 * Deletes selected keyframes for this node and its children. Doesn't register undo for changes at any point. Returns whether any keyframes were deleted.
 */
- (BOOL)deleteSelectedKeyframesForSequenceId:(int)sequenceId;

- (BOOL)deleteDuplicateKeyframesForSequenceId:(int)seqId;
- (void)deleteKeyframesAfterTime:(float)time sequenceId:(int)seqId;
- (void)deselectAllKeyframes;
- (void)addSelectedKeyframesToArray:(NSMutableArray *)keyframes;
- (void)updateProperty:(NSString *)propName time:(float)time sequenceId:(int)seqId;
- (void)updatePropertiesTime:(float)time sequenceId:(int)seqId;
- (SequencerKeyframe *)addDefaultKeyframeForProperty:(NSString *)name atTime:(CGFloat)time sequenceId:(int)seqId;
- (void)addKeyframe:(SequencerKeyframe *)keyframe forProperty:(NSString *)name atTime:(float)time sequenceId:(int)seqId;
- (NSArray *)keyframesForProperty:(NSString *)prop;
- (BOOL)hasKeyframesForProperty:(NSString *)prop;
- (BOOL)shouldDisableProperty:(NSString *)prop;
- (id)serializeAnimatedProperties;
- (void)loadAnimatedPropertiesFromSerialization:(id)ser;
- (void)updateAnimateablePropertyValue:(id)value propName:(NSString *)propertyName;
- (void)updateAnimateablePropertyValue:(id)value propName:(NSString *)propertyName andCreateKeyFrameIfNone:(BOOL)createKeyframe withType:(int)type;
- (void)updateAnimateablePropertyAndAllKeyFrames:(NSString *)propertyName currentValue:(id)currentValue updateBlock:(id (^)(id currentValue))updateBlock;

/**
 @returns An array of all sequencer ids that this node has keyframes on
 */
- (NSArray *)allSequencerIds;

/**
 Given a dictionary in the form { originalId : newId }, re-map the sequencers to new timelines
 @param newSequenceMap A dictionary in the form { originalId : newId }
 */
- (void)remapSequencersWithMapping:(NSDictionary *)newSequenceMap;

@end
