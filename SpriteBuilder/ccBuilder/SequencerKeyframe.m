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

#import "SequencerKeyframe.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframeEasing.h"

NSString *const kClipboardKeyFrames = @"com.cocosbuilder.keyframes";
NSString *const kClipboardChannelKeyframes = @"com.cocosbuilder.channelkeyframes";

@implementation SequencerKeyframe

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _easing = [SequencerKeyframeEasing easing];

    return self;
}

- (instancetype)initWithSerialization:(NSDictionary *)serialization {
    self = [super init];
    if (!self) {
        return nil;
    }

    _value = serialization[@"value"];
    _type = (CCBKeyframeType)[serialization[@"type"] intValue];
    _name = serialization[@"name"];
    _time = [serialization[@"time"] floatValue];
    _easing = [[SequencerKeyframeEasing alloc] initWithSerialization:serialization[@"easing"]];

    // fix possible broken easing/type combinations
    if (![self supportsFiniteTimeInterpolations]) {
        _easing.type = kCCBKeyframeEasingInstant;
    }

    return self;
}

- (NSDictionary *)serialization {
    NSMutableDictionary *mutableSerialization = [NSMutableDictionary dictionary];

    mutableSerialization[@"type"] = @(self.type);
    mutableSerialization[@"time"] = @(self.time);
    if (self.value) {
        mutableSerialization[@"value"] = self.value;
    }
    if (self.name) {
        mutableSerialization[@"name"] = self.name;
    }
    if (self.easing) {
        mutableSerialization[@"easing"] = [self.easing serialization];
    }

    return [mutableSerialization copy];
}

- (NSComparisonResult)compareTime:(id)cmp {
    SequencerKeyframe *keyframe = cmp;

    if (keyframe.time > self.time) return NSOrderedAscending;
    else if (keyframe.time < self.time) return NSOrderedDescending;
    else return NSOrderedSame;
}

- (void)setTime:(CGFloat)time {
    _time = time;
    [self.parent sortKeyframes];
}

- (BOOL)valueIsEqualTo:(SequencerKeyframe *)keyframe {
    if (self.type != keyframe.type) {
        return NO;
    }

    if (self.type == kCCBKeyframeTypeDegrees) {
        return ([self.value floatValue] == [keyframe.value floatValue]);
    }
    else if (self.type == kCCBKeyframeTypePosition
        || self.type == kCCBKeyframeTypeScaleLock) {
        return ([[self.value objectAtIndex:0] floatValue] == [[keyframe.value objectAtIndex:0] floatValue]
            && [[self.value objectAtIndex:1] floatValue] == [[keyframe.value objectAtIndex:1] floatValue]);
    }
    else if (self.type == kCCBKeyframeTypeByte) {
        return ([self.value intValue] == [keyframe.value intValue]);
    }
    else if (self.type == kCCBKeyframeTypeFloat) {
        return ([self.value floatValue] == [keyframe.value floatValue]);
    }
    else if (self.type == kCCBKeyframeTypeColor3) {
        int r0 = [[self.value objectAtIndex:0] intValue];
        int g0 = [[self.value objectAtIndex:1] intValue];
        int b0 = [[self.value objectAtIndex:2] intValue];

        int r1 = [[keyframe.value objectAtIndex:0] intValue];
        int g1 = [[keyframe.value objectAtIndex:1] intValue];
        int b1 = [[keyframe.value objectAtIndex:2] intValue];

        return (r0 == r1 && g0 == g1 && b0 == b1);
    }
    return NO;
}

- (BOOL)supportsFiniteTimeInterpolations {
    return (self.type != kCCBKeyframeTypeToggle && self.type != kCCBKeyframeTypeUndefined && self.type != kCCBKeyframeTypeSpriteFrame);
}

#pragma mark - Class methods

+ (CCBKeyframeType)keyframeTypeFromPropertyType:(NSString *)type {
    if ([type isEqualToString:@"Degrees"]) {
        return kCCBKeyframeTypeDegrees;
    }
    else if ([type isEqualToString:@"Position"]) {
        return kCCBKeyframeTypePosition;
    }
    else if ([type isEqualToString:@"ScaleLock"]) {
        return kCCBKeyframeTypeScaleLock;
    }
    else if ([type isEqualToString:@"Check"]) {
        return kCCBKeyframeTypeToggle;
    }
    else if ([type isEqualToString:@"Byte"]) {
        return kCCBKeyframeTypeByte;
    }
    else if ([type isEqualToString:@"Color3"]) {
        return kCCBKeyframeTypeColor3;
    }
    else if ([type isEqualToString:@"SpriteFrame"]) {
        return kCCBKeyframeTypeSpriteFrame;
    }
    else if ([type isEqualToString:@"FloatXY"]) {
        return kCCBKeyframeTypeFloatXY;
    }
    else if ([type isEqualToString:@"Float"]) {
        return kCCBKeyframeTypeFloat;
    }
    else {
        return kCCBKeyframeTypeUndefined;
    }
}

@end
