/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
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

#import "CCBAnimationManager.h"
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"
#import "CCBReader.h"
#import "CCBKeyframe.h"
#import "OALSimpleAudio.h"
#import <objc/runtime.h>
#import "PCResourceManager.h"

#import "CCBReader_Private.h"

#import "SKNode+CocosCompatibility.h"
#import "SKNode+PhysicsExport.h"
#import "SKTTimingFunctions.h"
#import "PCJSContext.h"
#import "SKNode+Animation.h"
#import "PCConstants.h"

static NSInteger ccbAnimationManagerID = 0;

@interface CCBAnimationManager ()

@property (strong, nonatomic) NSMutableDictionary *sequenceSounds;

@end

@implementation CCBAnimationManager

@synthesize rootContainerSize;
@synthesize delegate;
@synthesize lastCompletedSequenceName;

- (id)init {
    self = [super init];
    if (!self)
        return NULL;

    _animationManagerId = ccbAnimationManagerID;
    ccbAnimationManagerID++;

    _sequences = [[NSMutableArray alloc] init];
    _nodeSequences = [[NSMutableDictionary alloc] init];
    self.baseValues = [[NSMutableDictionary alloc] init];
    _sequenceSounds = [[NSMutableDictionary alloc] init];

    return self;
}

- (CGSize)containerSize:(SKNode *)node {
    if (node)
        return node.contentSize;
    else
        return rootContainerSize;
}

- (void)addNode:(SKNode *)node andSequences:(NSDictionary *)seq {
    NSValue *nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    self.nodeSequences[nodePtr] = seq;
}

- (void)moveAnimationsFromNode:(SKNode *)fromNode toNode:(SKNode *)toNode {
    NSValue *fromNodePtr = [NSValue valueWithPointer:(__bridge const void *)(fromNode)];
    NSValue *toNodePtr = [NSValue valueWithPointer:(__bridge const void *)(toNode)];

    // Move base values
    id baseValue = self.baseValues[fromNodePtr];
    if (baseValue) {
        self.baseValues[toNodePtr] = baseValue;
        [self.baseValues removeObjectForKey:fromNodePtr];
    }

    // Move keyframes
    NSDictionary *seqs = self.nodeSequences[fromNodePtr];
    if (seqs) {
        self.nodeSequences[toNodePtr] = seqs;
        [self.nodeSequences removeObjectForKey:fromNodePtr];
    }
}

- (void)setBaseValue:(id)value forNode:(SKNode *)node propertyName:(NSString *)propName {
    NSValue *nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];

    NSMutableDictionary *props = self.baseValues[nodePtr];
    if (!props) {
        props = [NSMutableDictionary dictionary];
        self.baseValues[nodePtr] = props;
    }

    props[propName] = value;
}

- (id)baseValueForNode:(SKNode *)node propertyName:(NSString *)propName {
    NSValue *nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];

    NSMutableDictionary *props = self.baseValues[nodePtr];
    return props[propName];
}

- (int)sequenceIdForSequenceNamed:(NSString *)name {
    for (CCBSequence *seq in self.sequences) {
        if ([seq.name isEqualToString:name]) {
            return seq.sequenceId;
        }
    }
    return -1;
}

- (CCBSequence *)sequenceFromSequenceId:(int)seqId {
    for (CCBSequence *seq in self.sequences) {
        if (seq.sequenceId == seqId)
            return seq;
    }
    return NULL;
}

- (SKAction *)actionFromKeyframe:(CCBKeyframe *)keyframeFrom toKeyframe:(CCBKeyframe *)keyframeTo propertyName:(NSString *)propertyName node:(SKNode *)node {
    float duration = keyframeTo.time - keyframeFrom.time;

    if ([propertyName isEqualToString:@"rotation"]) {
        CGFloat radians = DEGREES_TO_RADIANS([keyframeTo.value floatValue]);
        return [SKAction rotateToAngle:radians duration:duration];
    } else if ([propertyName isEqualToString:@"opacity"]) {
        return [SKAction fadeAlphaTo:[keyframeTo.value floatValue] duration:duration];
    } else if ([propertyName isEqualToString:@"color"]) {
        SKColor *color = keyframeTo.value;
        return [SKAction colorizeWithColor:color colorBlendFactor:1 duration:duration];
    } else if ([propertyName isEqualToString:@"visible"]) {
        if ([keyframeTo.value boolValue]) {
            return [SKAction sequence:@[ [SKAction waitForDuration:duration], [SKAction unhide] ]];
        } else {
            return [SKAction sequence:@[ [SKAction waitForDuration:duration], [SKAction hide] ]];
        }
    } else if ([propertyName isEqualToString:@"spriteFrame"]) {
        return [SKAction sequence:@[ [SKAction waitForDuration:duration], [SKAction setTexture:keyframeTo.value resize:YES] ]];
    } else if ([propertyName isEqualToString:@"position"]) {
        // Get position type
        //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];

        id value = keyframeTo.value;

        // Get relative position
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];

        //CGSize containerSize = [self containerSize:node.parent];

        //CGPoint absPos = [node absolutePositionFromRelative:CGPointMake(x,y) type:type parentSize:containerSize propertyName:name];

        SKAction *moveAction = [SKAction moveTo:CGPointMake(x, y) duration:duration];
        return moveAction;
    } else if ([propertyName isEqualToString:@"scale"]) {
        // Get position type
        //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];

        id value = keyframeTo.value;

        // Get relative scale
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];

        return [SKAction scaleXTo:x y:y duration:duration];
    } else if ([propertyName isEqualToString:@"xRotation3D"] ||[propertyName isEqualToString:@"yRotation3D"] ||[propertyName isEqualToString:@"zRotation3D"]) {
        return [node pc_animateKey:propertyName toFloat:[keyframeTo.value floatValue] duration:duration];
    } else {
        NSLog(@"CCBReader: Failed to create animation for property: %@", propertyName);
    }
    return NULL;
}

- (void)setAnimatedProperty:(NSString *)name forNode:(SKNode *)node toValue:(id)value tweenDuration:(float)tweenDuration {
    if (tweenDuration > 0) {
        // Create a fake keyframe to generate the action from
        CCBKeyframe *kf1 = [[CCBKeyframe alloc] init];
        kf1.value = value;
        kf1.time = tweenDuration;
        kf1.easingType = kCCBKeyframeEasingLinear;

        // Animate
        SKAction *action = [self actionFromKeyframe:nil toKeyframe:kf1 propertyName:name node:node];
        [node runAction:action];
    } else {
        // Just set the value

        if ([name isEqualToString:@"position"]) {
            // Get position type
            //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];

            // Get relative position
            float x = [[value objectAtIndex:0] floatValue];
            float y = [[value objectAtIndex:1] floatValue];
#ifdef PC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:CGPointMake(x, y)] forKey:name];
#elif defined(PC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithPoint:CGPointMake(x, y)] forKey:name];
#endif

            //[node setRelativePosition:CGPointMake(x,y) type:type parentSize:[self containerSize:node.parent] propertyName:name];
        } else if ([name isEqualToString:@"scale"]) {
            // Get scale type
            //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];

            // Get relative scale
            float x = [[value objectAtIndex:0] floatValue];
            float y = [[value objectAtIndex:1] floatValue];

            [node setValue:@(x) forKey:[name stringByAppendingString:@"X"]];
            [node setValue:@(y) forKey:[name stringByAppendingString:@"Y"]];

            //[node setRelativeScaleX:x Y:y type:type propertyName:name];
        } else if ([name isEqualToString:@"skew"]) {
            node.skewX = [[value objectAtIndex:0] floatValue];
            node.skewY = [[value objectAtIndex:1] floatValue];
        } else {
            [node setValue:value forKey:name];
        }
    }
}

- (void)setFirstFrameForNode:(SKNode *)node sequenceProperty:(CCBSequenceProperty *)seqProp tweenDuration:(float)tweenDuration {
    NSArray *keyframes = [seqProp keyframes];

    if (keyframes.count == 0) {
        // Use base value (no animation)
        /**
         RNP: We are disabling this. It resets all values to a base value at the start of a timeline. Even if that property isn't being animated in the timeline. We don't want this.
         **/
        // id baseValue = [self baseValueForNode:node propertyName:seqProp.name];
        // NSAssert1(baseValue, @"No baseValue found for property (%@)", seqProp.name);
        // [self setAnimatedProperty:seqProp.name forNode:node toValue:baseValue tweenDuration:tweenDuration];
    } else {
        // Use first keyframe
        CCBKeyframe *keyframe = keyframes.firstObject;
        [self setAnimatedProperty:seqProp.name forNode:node toValue:keyframe.value tweenDuration:tweenDuration];
    }
}

- (void)easeAction:(SKAction *)action easingType:(int)easingType easingOpt:(float)easingOpt {
    if (easingType == kCCBKeyframeEasingLinear) {
        action.timingMode = SKActionTimingLinear;
    } else if (easingType == kCCBKeyframeEasingInstant) {
        [action setTimingFunction:^float(float p) {
            if (p < 1) {
                return 0;
            }
            return 1;
        }];
    } else if (easingType == kCCBKeyframeEasingCubicIn) {
        action.timingMode = SKActionTimingEaseIn;
    } else if (easingType == kCCBKeyframeEasingCubicOut) {
        action.timingMode = SKActionTimingEaseOut;
    } else if (easingType == kCCBKeyframeEasingCubicInOut) {
        action.timingMode = SKActionTimingEaseInEaseOut;
    } else if (easingType == kCCBKeyframeEasingBackIn) {
        action.timingFunction = SKTTimingFunctionBackEaseIn;
    } else if (easingType == kCCBKeyframeEasingBackOut) {
        action.timingFunction = SKTTimingFunctionBackEaseOut;
    } else if (easingType == kCCBKeyframeEasingBackInOut) {
        action.timingFunction = SKTTimingFunctionBackEaseInOut;
    } else if (easingType == kCCBKeyframeEasingBounceIn) {
        action.timingFunction = SKTTimingFunctionBounceEaseIn;
    } else if (easingType == kCCBKeyframeEasingBounceOut) {
        action.timingFunction = SKTTimingFunctionBounceEaseOut;
    } else if (easingType == kCCBKeyframeEasingBounceInOut) {
        action.timingFunction = SKTTimingFunctionBounceEaseInOut;
    } else if (easingType == kCCBKeyframeEasingElasticIn) {
        action.timingFunction = SKTTimingFunctionElasticEaseIn;
    } else if (easingType == kCCBKeyframeEasingElasticOut) {
        action.timingFunction = SKTTimingFunctionElasticEaseOut;
    } else if (easingType == kCCBKeyframeEasingElasticInOut) {
        action.timingFunction = SKTTimingFunctionElasticEaseInOut;
    } else {
        NSLog(@"CCBReader: Unkown easing type %d", easingType);
    }
}

- (void)runActionsForNode:(SKNode *)node sequenceProperty:(CCBSequenceProperty *)sequenceProperty tweenDuration:(CGFloat)tweenDuration sequenceID:(NSInteger)sequenceID {
    NSArray *keyframes = sequenceProperty.keyframes;
    NSUInteger keyframeCount = keyframes.count;

    if (keyframeCount <= 1) {
        return;
    }

    NSMutableArray *actions = [NSMutableArray array];

    CCBKeyframe *firstKeyframe = keyframes.firstObject;
    CGFloat timeToFirstKeyframe = firstKeyframe.time + tweenDuration;

    if (timeToFirstKeyframe > 0) {
        [actions addObject:[SKAction waitForDuration:timeToFirstKeyframe]];
    }

    // This loop will only go to the second-last keyframe because the last is accessed inside the loop and there's nowhere
    // to animate *to* from the last one:
    //
    // ------[]==========[]====[]===============[]--------
    //
    for (NSUInteger keyframeIndex = 0; keyframeIndex < keyframeCount - 1; keyframeIndex++) {
        CCBKeyframe *keyframeFrom = keyframes[keyframeIndex];
        CCBKeyframe *keyframeTo = keyframes[keyframeIndex + 1];

        SKAction *action = [self actionFromKeyframe:keyframeFrom toKeyframe:keyframeTo propertyName:sequenceProperty.name node:node];
        if (!action) {
            continue;
        }

        // Apply easing
        [self easeAction:action easingType:keyframeFrom.easingType easingOpt:keyframeFrom.easingOpt];

        // For position keyframes, we need to prepend and append block actions that change the dynamicism of the
        // node's physics body so that it animates properly.
        // If this isn't done then the physics engine and actions compete to change the node's position.
        if ([sequenceProperty.name isEqualToString:@"position"]) {

            // Set the body to static before the first position action
            if (keyframeIndex == 0) {
                [node positionActionStarted];
            }

            // Set the body to its original dynamicism after the last position action
            // Note that we're checking for the index to be the second-last keyframe because we it'll never be the last
            if (keyframeIndex == keyframeCount - 2) {
                SKAction *dynamicAction = [SKAction runBlock:^{
                    [node positionAnimationEnded];
                }];
                action = [SKAction sequence:@[ action, dynamicAction ]];
            }
        }

        [actions addObject:action];
    }

    SKAction *sequencedActions = [SKAction sequence:actions];
    NSString *sequenceKey = [self keyForSequenceID:sequenceID property:sequenceProperty];
    [node runAction:sequencedActions withKey:sequenceKey];
}

- (SKAction *)actionForCallbackChannel:(CCBSequenceProperty *)channel {
    float lastKeyframeTime = 0;
    NSMutableArray* actions = [NSMutableArray array];
    
    for (CCBKeyframe* keyframe in channel.keyframes) {
        float timeSinceLastKeyframe = keyframe.time - lastKeyframeTime;
        lastKeyframeTime = keyframe.time;
        if (timeSinceLastKeyframe > 0) {
            // add a delay for the amount of time between custom events actions
            [actions addObject:[SKAction waitForDuration:timeSinceLastKeyframe]];
        }
        
        NSString* callbackEventName = keyframe.value[0];
        if (PCIsEmpty(callbackEventName)) continue;

        SKAction *callbackAction = [SKAction runBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:@{
                PCJSContextEventNotificationEventNameKey:callbackEventName
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:PCEventNotification object:nil userInfo:@{PCEventNotificationCustomEventName:callbackEventName}];
        }];
        [actions addObject:callbackAction];
    }
    
    if (!actions.count) return NULL;
    
    return [SKAction sequence:actions];
}

- (SKAction *)actionForSoundChannel:(CCBSequenceProperty *)channel sequenceId:(NSInteger)sequenceId {
    float lastKeyframeTime = 0;
    NSMutableArray *actions = [NSMutableArray array];

    __weak __typeof(self) weakSelf = self;
    for (CCBKeyframe *keyframe in channel.keyframes) {
        float timeSinceLastKeyframe = keyframe.time - lastKeyframeTime;
        lastKeyframeTime = keyframe.time;
        if (timeSinceLastKeyframe > 0) {
            [actions addObject:[SKAction waitForDuration:timeSinceLastKeyframe]];
        }

        NSString *soundFile = [PCResourceManager sharedInstance].resources[keyframe.value[0]];
        if (!soundFile) {
            NSLog(@"Invalid or missing UUID for sound: %@", keyframe.value[0]);
            continue;
        }

        float pitch = [keyframe.value[1] floatValue];
        float pan = [keyframe.value[2] floatValue];
        float gain = [keyframe.value[3] floatValue];
        [actions addObject:[SKAction runBlock:^{
            id<ALSoundSource> soundSource = [[OALSimpleAudio sharedInstance] playEffect:soundFile volume:gain pitch:pitch pan:pan loop:NO];
            [weakSelf addSound:soundSource toSequenceId:sequenceId];
        }]];
    }

    return actions.count ? [SKAction sequence:actions] : nil;
}

- (void)runAnimationsForSequenceId:(int)seqId tweenDuration:(float)tweenDuration completion:(void (^)())completion {
    NSAssert(seqId != -1, @"Sequence id %d couldn't be found", seqId);

    [self stopAnimationForSequenceId:seqId];

    for (NSValue *nodePtr in self.nodeSequences) {
        SKNode *node = [nodePtr pointerValue];

        NSDictionary *seqs = self.nodeSequences[nodePtr];
        NSDictionary *seqNodeProps = seqs[@(seqId)];

        // Reset nodes that have sequence node properties, and run actions on them
        for (NSString *propName in seqNodeProps) {
            CCBSequenceProperty *seqProp = seqNodeProps[propName];

            [self setFirstFrameForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration];
            [self runActionsForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration sequenceID:seqId];
        }
    }

    // Make callback at end of sequence
    CCBSequence *seq = [self sequenceFromSequenceId:seqId];
    __weak CCBAnimationManager *weakSelf = self;
    SKAction *sequenceCompleteAction = [SKAction runBlock:^{
        [weakSelf sequenceCompleted:seq.sequenceId];

        if (completion) completion();
    }];

    SKAction *completeAction = [SKAction sequence:@[ [SKAction waitForDuration:seq.duration + tweenDuration], sequenceCompleteAction ]];
    [self.rootNode runAction:completeAction withKey:[self keyForSequenceID:seqId]];

    if (seq.callbackChannel) {
        // Build callback SKActions for custom javascript events in time line
        SKAction *action = [self actionForCallbackChannel:seq.callbackChannel];
        if (action) {
            [self.rootNode runAction:action];
        }
    }
    
    if (seq.soundChannel) {
        // Build sound actions for channel
        SKAction *action = [self actionForSoundChannel:seq.soundChannel sequenceId:seqId];
        if (action) {
            [self.rootNode runAction:action withKey:[self keyForSoundSequenceID:seqId]];
        }
    }
}

- (NSString *)keyForSequenceID:(NSInteger)sequenceID property:(CCBSequenceProperty *)property {
    return [NSString stringWithFormat:@"%d%@", sequenceID, property.name];
}

- (NSString *)keyForSequenceID:(NSInteger)sequenceID {
    return [NSString stringWithFormat:@"%d", sequenceID];
}

- (NSString *)keyForSoundSequenceID:(NSInteger)sequenceID {
    return [NSString stringWithFormat:@"Sound%d", sequenceID];
}

- (void)runAnimationsForSequenceNamed:(NSString *)name tweenDuration:(float)tweenDuration completion:(void (^)())completion {
    int seqId = [self sequenceIdForSequenceNamed:name];
    if (seqId < 0) return;
    [self runAnimationsForSequenceId:seqId tweenDuration:tweenDuration completion:completion];
}

- (void)runAnimationsForSequenceNamed:(NSString *)name completion:(void (^)())completion {
    [self runAnimationsForSequenceNamed:name tweenDuration:0 completion:completion];
}

- (void)stopAnimationForSequenceNamed:(NSString *)name {
    NSInteger seqId = [self sequenceIdForSequenceNamed:name];
    [self stopAnimationForSequenceId:seqId];
}

- (void)stopAnimationForSequenceId:(NSInteger)seqId {
    NSAssert(seqId != -1, @"Sequence id %d couldn't be found", seqId);

    for (NSValue *nodePtr in self.nodeSequences) {
        SKNode *node = nodePtr.pointerValue;
        NSDictionary *seqs = self.nodeSequences[nodePtr];
        NSDictionary *sequenceNodeProperties = seqs[@(seqId)];

        BOOL didReleaseAnimationHandle = NO;
        for (NSString *propertyName in sequenceNodeProperties) {
            NSString *sequenceKey = [self keyForSequenceID:seqId property:sequenceNodeProperties[propertyName]];
            if ([node actionForKey:sequenceKey]) {
                if (!didReleaseAnimationHandle && [propertyName isEqualToString:@"position"]) {
                    [node positionAnimationEnded];
                    didReleaseAnimationHandle = YES;
                }
                [node removeActionForKey:sequenceKey];
            }
        }
    }

    [self stopSoundsForSequenceId:seqId];
    [self.rootNode removeActionForKey:[self keyForSequenceID:seqId]];
}

- (void)sequenceCompleted:(NSInteger)seqId {
    // Play next sequence
    NSPredicate *sequenceIdPredicate = [NSPredicate predicateWithFormat:@"sequenceId == %d", seqId];
    NSArray *sequenceListWithId = [self.sequences filteredArrayUsingPredicate:sequenceIdPredicate];

    if ([sequenceListWithId count] == 0)
        return;

    [self stopSoundsForSequenceId:seqId];
    
    CCBSequence *completedSequence = sequenceListWithId.firstObject;
    int nextSeqId = completedSequence.chainedSequenceId;
    lastCompletedSequenceName = completedSequence.name;

    // Trigger JS Context global event
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"timelineFinished",
        PCJSContextEventNotificationArgumentsKey: @[ lastCompletedSequenceName ]
    }];

    // Callbacks
    if (delegate && [delegate respondsToSelector:@selector(completedAnimationSequenceNamed:)]) {
        [delegate completedAnimationSequenceNamed:lastCompletedSequenceName];
    }
    if (self.block) {
        self.block(self);
    }

    // Run next sequence if callbacks did not start a new sequence
    if (nextSeqId != -1) {
        [self runAnimationsForSequenceId:nextSeqId tweenDuration:0 completion:nil];
    }
}

#pragma mark - Sound management

- (void)addSound:(id<ALSoundSource>)sound toSequenceId:(NSInteger)sequenceId {
    NSNumber *key = @(sequenceId);
    NSMutableArray *activeSounds = self.sequenceSounds[key];
    if (!activeSounds) {
        activeSounds = [NSMutableArray array];
        self.sequenceSounds[key] = activeSounds;
    }
    [activeSounds addObject:sound];
}

- (void)stopSoundsForSequenceId:(NSInteger)sequenceId {
    [self.sequenceSounds[@(sequenceId)] makeObjectsPerformSelector:@selector(stop)];
    [self.sequenceSounds[@(sequenceId)] removeAllObjects];
    [self.rootNode removeActionForKey:[self keyForSoundSequenceID:sequenceId]];
}

@end
