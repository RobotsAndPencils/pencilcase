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

#import "CCBSplitHorizontalView.h"
#import "MainWindow.h"
#import "AppDelegate.h"

@interface CCBSplitHorizontalView ()

@property (assign, nonatomic) CGFloat previousBottomHeight;

@end

@implementation CCBSplitHorizontalView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (NSColor *)dividerColor {
    return [NSColor colorWithDeviceRed:0.42 green:0.42 blue:0.42 alpha:1];
}

- (BOOL)isBottomViewVisible {
    return ![self isSubviewCollapsed:self.bottomView];
}

- (void)toggleBottomView {
    if ([self isSubviewCollapsed:self.bottomView]) {
        [self uncollapseBottomView];
    } else if (![self isSubviewCollapsed:self.bottomView]) {
        [self collapseBottomView];
    }
}

- (void)toggleBottomView:(BOOL)show; {
    if ([self isSubviewCollapsed:self.bottomView] && show) {
        [self uncollapseBottomView];
    } else if (![self isSubviewCollapsed:self.bottomView] && !show) {
        [self collapseBottomView];
    }
}

- (void)collapseBottomView {
    [self setPosition:CGRectGetHeight(self.frame) ofDividerAtIndex:0];
}

- (void)uncollapseBottomView {
    CGFloat targetHeight = self.previousBottomHeight <= 0 ? 0 : self.previousBottomHeight;
    [self setPosition:CGRectGetHeight(self.frame) - targetHeight ofDividerAtIndex:0];
}

#pragma mark - NSSplitViewDelegate

- (void)splitViewWillResizeSubviews:(NSNotification *)notification {
    MainWindow *win = (MainWindow *)self.window;
    [win disableUpdatesUntilFlush];
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {

    return (subview == self.bottomView);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    return YES;
}

- (CGFloat)splitView:(NSSplitView *)sv constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {

    if (self.bottomView.isHidden) {
        return proposedMaximumPosition;
    }

    CGFloat max = sv.frame.size.height - 62;
    if (proposedMaximumPosition > max) return max;
    else return proposedMaximumPosition;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification {
    [[AppDelegate appDelegate].panelVisibilityControl setSelected:self.isBottomViewVisible forSegment:1];
    self.previousBottomHeight = CGRectGetHeight(self.bottomView.frame);
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    static CGFloat minCocosSize = 50.0;

    if (self.bottomView.isHidden) {
        [self.topView setFrameSize:[sender frame].size];
        return;
    }

    // keep timeline view intact
    NSSize newSize = sender.frame.size;
    CGFloat timeLineHeight = self.bottomView.frame.size.height;
    CGFloat cocosViewHeight = newSize.height - timeLineHeight - [sender dividerThickness];
    if (cocosViewHeight < minCocosSize) {
        cocosViewHeight = minCocosSize;
        timeLineHeight = newSize.height - cocosViewHeight - [sender dividerThickness];
    }

    [self.bottomView setFrameOrigin:NSMakePoint(self.bottomView.frame.origin.x, newSize.height - timeLineHeight)];
    [self.bottomView setFrameSize:NSMakeSize(newSize.width, timeLineHeight)];
    [self.topView setFrameSize:NSMakeSize(newSize.width, cocosViewHeight)];

    [self.bottomView setNeedsDisplay:YES];
    [self.topView setNeedsDisplay:YES];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    return floor(proposedPosition);
}

@end
