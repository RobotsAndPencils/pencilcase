//
//  PCThenBackgroundView.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-11.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCThenBackgroundView.h"
#import "BehavioursStyleKit.h"

@implementation PCThenBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    [BehavioursStyleKit drawThenWithFrame:self.bounds sourceHighlightColor:self.sourceHighlightColor topConnected:self.topConnected bottomConnected:self.bottomConnected isSelected:self.selected isNextThenSelected:self.nextThenSelected isSourceHighlighted:self.isSourceHighlighted hideTopConnector:self.hideTopConnector hideBottomConnector:self.hideBottomConnector];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self setNeedsDisplay:YES];
}

- (void)setHideBottomConnector:(BOOL)hideBottomConnector {
    _hideBottomConnector = hideBottomConnector;
    [self setNeedsDisplay:YES];
}

- (void)setHideTopConnector:(BOOL)hideTopConnector {
    _hideTopConnector = hideTopConnector;
    [self setNeedsDisplay:YES];
}

- (void)setBottomConnected:(BOOL)bottomConnected {
    _bottomConnected = bottomConnected;
    [self setNeedsDisplay:YES];
}

- (void)setTopConnected:(BOOL)topConnected {
    _topConnected = topConnected;
    [self setNeedsDisplay:YES];
}

- (void)setIsSourceHighlighted:(BOOL)isSourceHighlighted {
    _isSourceHighlighted = isSourceHighlighted;
    [self setNeedsDisplay:YES];
}

- (void)setSourceHighlightColor:(NSColor *)sourceHighlightColor {
    _sourceHighlightColor = sourceHighlightColor;
    [self setNeedsDisplay:YES];
}

- (void)setNextThenSelected:(BOOL)nextThenSelected {
    _nextThenSelected = nextThenSelected;
    [self setNeedsDisplay:YES];
}

@end
