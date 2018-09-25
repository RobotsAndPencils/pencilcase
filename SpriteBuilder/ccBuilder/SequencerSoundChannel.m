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
#import "SequencerSoundChannel.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"

@implementation SequencerSoundChannel
@synthesize isEpanded;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.displayName = @"Sound effects";
    
    return self;
}

- (id) initWithSerialization:(id)ser
{
    self = [super initWithSerialization:ser];
    if (self)
    {
        NSNumber * isExpandedData = [ser objectForKey:@"isExpanded"];
        if(isExpandedData)
        {
            self.isEpanded = [isExpandedData boolValue];
        }
    }
    
    return self;
}

- (SequencerKeyframe*) defaultKeyframe
{
    SequencerKeyframe *keyFrame = [[SequencerKeyframe alloc] init];
    
    keyFrame.value = @[@"", @1, @0, @1];
    keyFrame.type = kCCBKeyframeTypeSoundEffects;
    keyFrame.name = nil;
    keyFrame.easing = [[SequencerKeyframeEasing alloc] init];
    keyFrame.easing.type = kCCBKeyframeEasingInstant;
    
    return keyFrame;
}


- (NSDictionary *)serialize {
    NSMutableDictionary *mutableSerialization = [[super serialize] mutableCopy];
    mutableSerialization[@"isExpanded"] = @(isEpanded);
    return [mutableSerialization copy];
}

@end
