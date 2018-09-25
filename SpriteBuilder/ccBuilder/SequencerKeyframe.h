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

#import <Foundation/Foundation.h>

@class SequencerNodeProperty;
@class SequencerKeyframeEasing;

typedef NS_ENUM(NSUInteger, CCBKeyframeType) {
    // Node properties
    kCCBKeyframeTypeUndefined = 0,
    kCCBKeyframeTypeToggle,
    kCCBKeyframeTypeDegrees,
    kCCBKeyframeTypePosition,
    kCCBKeyframeTypeScaleLock,
    kCCBKeyframeTypeByte,
    kCCBKeyframeTypeColor3,
    kCCBKeyframeTypeSpriteFrame,
    kCCBKeyframeTypeFloatXY,
    kCCBKeyframeTypeColor4,
    kCCBKeyframeTypeFloat,

    // Channels
    kCCBKeyframeTypeSoundEffects,
    kCCBKeyframeTypeCallbacks,
};

extern NSString *const kClipboardKeyFrames;
extern NSString *const kClipboardChannelKeyframes;

@interface SequencerKeyframe : NSObject

@property (nonatomic, strong) id value;
@property (nonatomic, assign) CCBKeyframeType type;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) CGFloat timeAtDragStart;
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, weak) SequencerNodeProperty *parent;
@property (nonatomic, strong) SequencerKeyframeEasing *easing;

- (instancetype)initWithSerialization:(NSDictionary *)serialization;
- (NSDictionary *)serialization;

- (BOOL)valueIsEqualTo:(SequencerKeyframe *)keyframe;
- (BOOL)supportsFiniteTimeInterpolations;

- (NSComparisonResult)compareTime:(id)cmp;

+ (CCBKeyframeType)keyframeTypeFromPropertyType:(NSString *)type;

@end