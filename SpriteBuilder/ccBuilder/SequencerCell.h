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

#import <SpriteKit/SpriteKit.h>

@class SequencerChannel;

@interface SequencerCell : NSCell

@property (nonatomic, weak) SKNode *node;
@property (nonatomic, weak) SequencerChannel *channel;
@property (nonatomic, strong) NSImage *imgKeyframe;
@property (nonatomic, strong) NSImage *imgKeyframeSel;
@property (nonatomic, strong) NSImage *imgKeyframeLrg;
@property (nonatomic, strong) NSImage *imgKeyframeSelLrg;
@property (nonatomic, strong) NSImage *imgRowBg0;
@property (nonatomic, strong) NSImage *imgRowBg1;
@property (nonatomic, strong) NSImage *imgRowBgN;
@property (nonatomic, strong) NSImage *imgRowBgChannel;
@property (nonatomic, strong) NSImage *imgInterpol;
@property (nonatomic, strong) NSImage *imgEaseIn;
@property (nonatomic, strong) NSImage *imgEaseOut;
@property (nonatomic, strong) NSImage *imgInterpolVis;
@property (nonatomic, strong) NSImage *imgKeyframeL;
@property (nonatomic, strong) NSImage *imgKeyframeR;
@property (nonatomic, strong) NSImage *imgKeyframeLSel;
@property (nonatomic, strong) NSImage *imgKeyframeRSel;
@property (nonatomic, strong) NSImage *imgKeyframeHint;
@property (nonatomic, assign) BOOL imagesLoaded;

@end
