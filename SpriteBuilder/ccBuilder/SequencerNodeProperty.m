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

#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerChannel.h"
#import "SKNode+NodeInfo.h"
#import "PlugInNode.h"
#import "SKNode+NodeInfo.h"
#import "CGPointUtilities.h"

@implementation SequencerNodeProperty

- (instancetype)initWithProperty:(NSString *)name node:(SKNode *)node {
    self = [super init];
    if (!self) {
        return nil;
    }

    _propName = [name copy];
    _keyframes = [[NSMutableArray alloc] init];

    // Setup type
    NSString *propType = [node.plugIn propertyTypeForProperty:name];
    _type = [SequencerKeyframe keyframeTypeFromPropertyType:propType];

    NSAssert(_type, @"Failed to find valid type for SequencerNodeProperty");

    return self;
}

- (instancetype)initWithChannel:(SequencerChannel *)channel {
    self = [super init];
    if (!self) {
        return nil;
    }

    _propName = nil;
    _keyframes = [[NSMutableArray alloc] init];
    _type = channel.keyframeType;

    return self;
}

- (instancetype)initWithSerialization:(NSDictionary *)serialization {
    self = [super init];
    if (!self) {
        return nil;
    }

    _propName = [serialization[@"name"] copy];
    _type = (CCBKeyframeType)[serialization[@"type"] intValue];

    NSArray *serKeyframes = serialization[@"keyframes"];
    _keyframes = [[NSMutableArray alloc] initWithCapacity:serKeyframes.count];
    for (id keyframeSer in serKeyframes) {
        SequencerKeyframe *keyframe = [[SequencerKeyframe alloc] initWithSerialization:keyframeSer];
        [_keyframes addObject:keyframe];
        keyframe.parent = self;
    }

    return self;
}

- (NSDictionary *)serialization {
    NSMutableDictionary *mutableSerialization = [NSMutableDictionary dictionary];

    if (self.propName) {
        mutableSerialization[@"name"] = self.propName;
    }
    mutableSerialization[@"type"] = @(self.type);

    NSMutableArray *serKeyframes = [NSMutableArray arrayWithCapacity:self.keyframes.count];
    for (SequencerKeyframe *keyframe in self.keyframes) {
        [serKeyframes addObject:[keyframe serialization]];
    }
    mutableSerialization[@"keyframes"] = serKeyframes;

    return [mutableSerialization copy];
}

- (void)addKeyframe:(SequencerKeyframe *)keyframe {
    keyframe.parent = self;
    [self.keyframes addObject:keyframe];
    [self sortKeyframes];
}

- (SequencerKeyframe *)keyframeBetweenMinTime:(CGFloat)minTime maxTime:(CGFloat)maxTime {
    for (SequencerKeyframe *keyframe in self.keyframes) {
        if (keyframe.time >= minTime && keyframe.time < maxTime) {
            return keyframe;
        }
    }
    return nil;
}

- (NSArray *)keyframesBetweenMinTime:(CGFloat)minTime maxTime:(CGFloat)maxTime {
    NSMutableArray *kfs = [NSMutableArray array];
    for (SequencerKeyframe *keyframe in self.keyframes) {
        if (keyframe.time >= minTime && keyframe.time < maxTime) {
            [kfs addObject:keyframe];
        }
    }
    return kfs;
}

- (SequencerKeyframe *)keyframeForInterpolationAtTime:(CGFloat)time {
    for (NSUInteger i = 0; i < [self.keyframes count] - 1; i++) {
        SequencerKeyframe *k0 = self.keyframes[i];
        SequencerKeyframe *k1 = self.keyframes[i + 1];

        if (time > k0.time && time < k1.time) return k0;
    }
    return nil;
}

- (void)sortKeyframes {
    // TODO: Optimize sorting (only sort once even if more than one keyframe is moved)
    [self.keyframes sortUsingSelector:@selector(compareTime:)];
}

- (BOOL)deleteDuplicateKeyframes {
    BOOL didDelete = NO;

    // Remove duplicates
    NSUInteger i = 0;
    while (i < (self.keyframes.count - 1)) {
        SequencerKeyframe *kf0 = self.keyframes[i];
        SequencerKeyframe *kf1 = self.keyframes[i + 1];

        if (kf0.time == kf1.time) {
            if (kf0.selected) {
                [self.keyframes removeObjectAtIndex:i + 1];
            }
            else {
                [self.keyframes removeObjectAtIndex:i];
            }

            didDelete = YES;
        }
        else {
            i++;
        }
    }

    return didDelete;
}

- (void)deleteKeyframesAfterTime:(CGFloat)time {
    NSArray *keyframesToDelete = [self.keyframes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"time > %f", time]];
    [self.keyframes removeObjectsInArray:keyframesToDelete];
}

- (BOOL)deleteSelectedKeyframes {
    NSArray *keyframesToDelete = [self.keyframes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
    [self.keyframes removeObjectsInArray:keyframesToDelete];
    return keyframesToDelete.count > 0;
}

- (id)valueAtTime:(CGFloat)time {
    NSUInteger numKeyframes = [self.keyframes count];

    if (numKeyframes == 0) {
        return nil;
    }

    if (numKeyframes == 1 && self.type == kCCBKeyframeTypeToggle) {
        SequencerKeyframe *keyframe = self.keyframes[0];
        return @(time >= keyframe.time);
    }

    if (numKeyframes == 1) {
        SequencerKeyframe *keyframe = self.keyframes[0];
        return keyframe.value;
    }

    SequencerKeyframe *keyframeFirst = self.keyframes[0];
    SequencerKeyframe *keyframeLast = self.keyframes[numKeyframes - 1];

    if (self.type == kCCBKeyframeTypeToggle) {
        if (time < keyframeFirst.time) {
            return @NO;
        }

        BOOL visible = YES;
        for (NSUInteger i = 1; i < [self.keyframes count]; i++) {
            SequencerKeyframe *kf = self.keyframes[i];

            if (time < kf.time) {
                return @(visible);
            }

            visible = !visible;
        }
        return @(visible);
    }

    if (time <= keyframeFirst.time) {
        return keyframeFirst.value;
    }

    if (time >= keyframeLast.time) {
        return keyframeLast.value;
    }

    // Time is between two keyframes, interpolate between them
    NSUInteger endFrameNum = 1;
    while ([(SequencerKeyframe *)self.keyframes[endFrameNum] time] < time) {
        endFrameNum++;
    }
    NSUInteger startFrameNum = endFrameNum - 1;

    SequencerKeyframe *keyframeStart = self.keyframes[startFrameNum];
    SequencerKeyframe *keyframeEnd = self.keyframes[endFrameNum];

    // Skip interpolations for toggle frames (special case)
    if (self.type == kCCBKeyframeTypeToggle) {
        BOOL val = (startFrameNum % 2 == 0);
        return @(val);
    }

    // Skip interpolation for spriteframes
    if (self.type == kCCBKeyframeTypeSpriteFrame) {
        if (time < keyframeEnd.time) return keyframeStart.value;
        else return keyframeEnd.value;
    }

    // interpolVal will be in the range 0.0 - 1.0
    CGFloat interpolVal = (time - keyframeStart.time) / (keyframeEnd.time - keyframeStart.time);

    // Support for easing
    interpolVal = [keyframeStart.easing easeValue:interpolVal];

    // Interpolate according to type
    if (self.type == kCCBKeyframeTypeDegrees) {
        CGFloat fStart = [keyframeStart.value floatValue];
        CGFloat fEnd = [keyframeEnd.value floatValue];

        CGFloat span = fEnd - fStart;

        return @(fStart + span * interpolVal);
    }
    else if (self.type == kCCBKeyframeTypePosition
        || self.type == kCCBKeyframeTypeScaleLock) {
        CGPoint pStart = CGPointZero;
        CGPoint pEnd = CGPointZero;

        pStart.x = [[keyframeStart.value objectAtIndex:0] floatValue];
        pStart.y = [[keyframeStart.value objectAtIndex:1] floatValue];

        pEnd.x = [[keyframeEnd.value objectAtIndex:0] floatValue];
        pEnd.y = [[keyframeEnd.value objectAtIndex:1] floatValue];

        CGPoint span = pc_CGPointSubtract(pEnd, pStart);

        CGPoint inter = pc_CGPointAdd(pStart, pc_CGPointMultiply(span, interpolVal));

        return @[ @(inter.x), @(inter.y) ];
    }
    else if (self.type == kCCBKeyframeTypeFloat) {
        CGFloat fStart = [keyframeStart.value floatValue];
        CGFloat fEnd = [keyframeEnd.value floatValue];

        CGFloat span = fEnd - fStart;

        return @(fStart + span * interpolVal);
    }
    else if (self.type == kCCBKeyframeTypeByte) {
        CGFloat fStart = [keyframeStart.value intValue];
        CGFloat fEnd = [keyframeEnd.value intValue];

        CGFloat span = fEnd - fStart;

        return @((int)(round(fStart + span * interpolVal)));
    }
    else if (self.type == kCCBKeyframeTypeColor3) {
        CGFloat rStart = [[keyframeStart.value objectAtIndex:0] floatValue];
        CGFloat gStart = [[keyframeStart.value objectAtIndex:1] floatValue];
        CGFloat bStart = [[keyframeStart.value objectAtIndex:2] floatValue];
        CGFloat aStart = [[keyframeStart.value objectAtIndex:3] floatValue];

        CGFloat rEnd = [[keyframeEnd.value objectAtIndex:0] floatValue];
        CGFloat gEnd = [[keyframeEnd.value objectAtIndex:1] floatValue];
        CGFloat bEnd = [[keyframeEnd.value objectAtIndex:2] floatValue];
        CGFloat aEnd = [[keyframeEnd.value objectAtIndex:3] floatValue];

        CGFloat rSpan = rEnd - rStart;
        CGFloat gSpan = gEnd - gStart;
        CGFloat bSpan = bEnd - bStart;
        CGFloat aSpan = aEnd - aStart;

        CGFloat r = rStart + rSpan * interpolVal;
        CGFloat g = gStart + gSpan * interpolVal;
        CGFloat b = bStart + bSpan * interpolVal;
        CGFloat a = aStart + aSpan * interpolVal;

        NSAssert(r >= 0 && r <= 1, @"Color value is out of range");
        NSAssert(g >= 0 && g <= 1, @"Color value is out of range");
        NSAssert(b >= 0 && b <= 1, @"Color value is out of range");
        NSAssert(a >= 0 && a <= 1, @"Color value is out of range");

        return @[ @(r), @(g), @(b), @(a) ];
    }
    else if (self.type == kCCBKeyframeTypeFloatXY) {
        CGFloat xStart = [[keyframeStart.value objectAtIndex:0] floatValue];
        CGFloat yStart = [[keyframeStart.value objectAtIndex:1] floatValue];

        CGFloat xEnd = [[keyframeEnd.value objectAtIndex:0] floatValue];
        CGFloat yEnd = [[keyframeEnd.value objectAtIndex:1] floatValue];

        CGFloat xSpan = xEnd - xStart;
        CGFloat ySpan = yEnd - yStart;

        CGFloat xVal = xStart + xSpan * interpolVal;
        CGFloat yVal = yStart + ySpan * interpolVal;

        return @[ @(xVal), @(yVal) ];
    }

    // Unsupported value type
    return nil;
}

- (BOOL)hasKeyframeAtTime:(CGFloat)time {
    for (SequencerKeyframe *keyframe in self.keyframes) {
        if (keyframe.time == time) return YES;
    }
    return NO;
}

- (SequencerKeyframe *)keyframeAtTime:(CGFloat)time {
    for (SequencerKeyframe *keyframe in self.keyframes) {
        if (keyframe.time == time) return keyframe;
    }
    return nil;
}

- (NSArray *)keyframesAtTime:(CGFloat)time {
    NSMutableArray *kfs = [NSMutableArray array];

    for (SequencerKeyframe *keyframe in self.keyframes) {
        if (keyframe.time == time) [kfs addObject:keyframe];
    }

    return kfs;
}

- (void)deselectKeyframes {
    for (SequencerKeyframe *keyframe in self.keyframes) {
        keyframe.selected = NO;
    }
}

- (SequencerNodeProperty *)duplicate {
    NSDictionary* serialization = [self serialization];
    SequencerNodeProperty *duplicate = [[SequencerNodeProperty alloc] initWithSerialization:serialization];
    return duplicate;
}

- (id)copyWithZone:(NSZone *)zone {
    NSDictionary* serialization = [self serialization];
    SequencerNodeProperty *copy = [[SequencerNodeProperty alloc] initWithSerialization:serialization];
    return copy;
}

/*
- (void) updateNode:(CCNode*)node toTime:(float)time
{
    id value = [self valueAtTime:time];
    NSAssert(value, @"Failed to fetch value!");
    
    if (type == kCCBKeyframeTypeDegrees)
    {
        [node setValue:value forKey:propName];
    }
}*/

@end
