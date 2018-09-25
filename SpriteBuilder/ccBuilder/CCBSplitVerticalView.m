//
//  CCBSplitVerticalView.m
//  SpriteBuilder
//
//  Created by Brandon on 2/20/2014.
//
//

#import "CCBSplitVerticalView.h"
#import "MainWindow.h"
#import "AppDelegate.h"

@interface CCBSplitVerticalView ()

@property (assign, nonatomic) CGFloat previousLeftWidth;
@property (assign, nonatomic) CGFloat previousRightWidth;

@end

@implementation CCBSplitVerticalView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - Public

- (void)toggleLeftView {
    if ([self isSubviewCollapsed:self.leftView]) {
        [self uncollapseLeftView];
    }
    else {
        [self collapseLeftView];
    }
}

- (void)showLeftView:(BOOL)show {
    if ([self isSubviewCollapsed:self.leftView] && show) {
        [self uncollapseLeftView];
    } else if (![self isSubviewCollapsed:self.leftView] && !show) {
        [self collapseLeftView];
    }
}

- (void)toggleRightView {
    if ([self isSubviewCollapsed:self.rightView]) {
        [self uncollapseRightView];
    }
    else {
        [self collapseRightView];
    }
}

- (void)showRightView:(BOOL)show {
    if ([self isSubviewCollapsed:self.rightView] && show) {
        [self uncollapseRightView];
    } else if (![self isSubviewCollapsed:self.rightView] && !show) {
        [self collapseRightView];
    }
}

#pragma mark - Private

- (NSColor *)dividerColor {
    return [NSColor colorWithDeviceRed:0.42 green:0.42 blue:0.42 alpha:1];
}

- (void)collapseLeftView {
    [self setPosition:0 ofDividerAtIndex:0];
}

- (void)uncollapseLeftView {
    CGFloat targetWidth = self.previousLeftWidth <= 0 ? 0 : self.previousLeftWidth;
    [self setPosition:targetWidth ofDividerAtIndex:0];
}

- (void)collapseRightView {
    [self setPosition:CGRectGetWidth(self.frame) ofDividerAtIndex:1];
}

- (void)uncollapseRightView {
    CGFloat targetWidth = self.previousRightWidth <= 0 ? 0 : self.previousRightWidth;
    [self setPosition:CGRectGetWidth(self.frame) - targetWidth ofDividerAtIndex:1];
}

#pragma mark - NSSplitViewDelegate

- (void)splitViewWillResizeSubviews:(NSNotification *)notification {
    MainWindow *win = (MainWindow *)self.window;
    [win disableUpdatesUntilFlush];
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return (subview == self.leftView || subview == self.rightView);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return 240.0;
    }
    else {
        return proposedMinimumPosition;
    }
}

- (CGFloat)splitView:(NSSplitView *)sv constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if ((self.leftView.isHidden && dividerIndex == 0) || (self.rightView.isHidden && dividerIndex == 1)) {
        return proposedMaximumPosition;
    }
    
    // Left split maximum width when open
    if (dividerIndex == 0) {
        return 400.0f;
    }

    CGFloat max = CGRectGetWidth(sv.frame) - 300.0;
    if (proposedMaximumPosition > max) {
        return max;
    }
    else {
        return proposedMaximumPosition;
    }
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification {
    self.previousLeftWidth = CGRectGetWidth(self.leftView.frame);
    self.previousRightWidth = CGRectGetWidth(self.rightView.frame);

    [[AppDelegate appDelegate].panelVisibilityControl setSelected:![self isSubviewCollapsed:self.leftView] forSegment:0];
    [[AppDelegate appDelegate].panelVisibilityControl setSelected:![self isSubviewCollapsed:self.rightView] forSegment:2];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
	return floorf(proposedPosition);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    return view == self.centerView;
}

@end
