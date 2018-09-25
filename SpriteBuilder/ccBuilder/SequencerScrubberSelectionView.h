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

@class SequencerKeyframe;

typedef NS_ENUM(NSInteger, CCBSeqMouseState) {
    CCBSeqMouseStateNone = 0,
    CCBSeqMouseStateScrubbing,
    CCBSeqMouseStateSelecting,
    CCBSeqMouseStateKeyframe
};

typedef NS_ENUM(NSInteger, CCBSeqAutoScrollHorizontal) {
    CCBSeqAutoScrollHorizontalNone = 0,
    CCBSeqAutoScrollHorizontalLeft,
    CCBSeqAutoScrollHorizontalRight
};

typedef NS_ENUM(NSInteger, CCBSeqAutoScrollVertical) {
    CCBSeqAutoScrollVerticalNone = 0,
    CCBSeqAutoScrollVerticalUp,
    CCBSeqAutoScrollVerticalDown
};

typedef NS_ENUM(NSInteger, CCBSequencerSelectedRow) {
    CCBSequencerSelectedRowNone = -1,
    CCBSequencerSelectedRowNoneAbove = -2,
    CCBSequencerSelectedRowNoneBelow = -3
};

extern const CGFloat CCBSeqScrubberHeight;

@interface SequencerScrubberSelectionView : NSView {
    NSImage *imgScrubHandle;
    NSImage *imgScrubLine;

    NSInteger mouseState;
    NSInteger autoScrollHorizontalDirection;
    NSInteger autoScrollVerticalDirection;
    NSPoint lastMousePosition;

    // Current selection
    CGFloat xStartSelectTime;
    CGFloat xEndSelectTime;
    NSInteger yStartSelectRow;
    NSInteger yStartSelectSubRow;
    NSInteger yEndSelectRow;
    NSInteger yEndSelectSubRow;

    SequencerKeyframe *mouseDownKeyframe;
    NSPoint mouseDownPosition;
    NSInteger mouseDownRelPositionX;
    BOOL didAutoScroll;
}

@property (nonatomic, strong) NSEvent *lastDragEvent;

- (void)addKeyframeAtRow:(NSInteger)row sub:(NSInteger)sub time:(CGFloat)time;

@end
