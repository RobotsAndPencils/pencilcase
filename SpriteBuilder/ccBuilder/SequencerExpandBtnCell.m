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

#import "SequencerExpandBtnCell.h"
#import "SequencerHandler.h"

@implementation SequencerExpandBtnCell

- (void) loadImages
{
    if (!self.expandedImage && !self.collapsedImage) {
        self.expandedImage = [NSImage imageNamed:@"seq-btn-expand.png"];
        self.collapsedImage = [NSImage imageNamed:@"seq-btn-collapse.png"];
    }
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self loadImages];
    return self;
}

- (id) initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    [self loadImages];
    return self;
}

- (id) initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    [self loadImages];
    return self;
}

- (id) init
{
    self = [super init];
    [self loadImages];
    return self;
}

- (BOOL) trackMouse:(NSEvent *)theEvent
             inRect:(NSRect)cellFrame
             ofView:(NSView *)controlView
       untilMouseUp:(BOOL)untilMouseUp
{
    // Deal with the click however you need to here, for example in a slider cell you can use the mouse x
    // coordinate to set the floatValue.
    
    // Dragging won't work unless you still make the call to the super class...
    return [super trackMouse: theEvent inRect: cellFrame ofView:
            controlView untilMouseUp: untilMouseUp];
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (!self.imagesLoaded)
    {
        self.imgRowBgChannel = [NSImage imageNamed:@"seq-row-channel-bg.png"];
        self.imagesLoaded = YES;
    }
    
    if (!self.node )
    {
        NSRect rowRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height - kCCBSeqDefaultRowHeight, cellFrame.size.width, kCCBSeqDefaultRowHeight);
        [self.imgRowBgChannel drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
    
    if (self.canExpand)
    {
        CGFloat smallOffset = self.node ? 0 : 1; //A small offset for sound rows.
        CGRect targetRect = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, self.expandedImage.size.width, self.expandedImage.size.height);

        if (self.isExpanded)
        {
            [self.collapsedImage drawInRect:targetRect fromRect:NSMakeRect(0, 0 + smallOffset, 16, 16) operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
        }
        else
        {
            [self.expandedImage drawInRect:targetRect fromRect:NSMakeRect(0, 0 + smallOffset, 16, 16) operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    SequencerExpandBtnCell *copy = [super copyWithZone:zone];
    copy.collapsedImage = [self.collapsedImage copyWithZone:zone];
    copy.expandedImage = [self.expandedImage copyWithZone:zone];
    return copy;
}

@end
