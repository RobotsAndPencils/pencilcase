//
//  PCView.m
//  Zoom
//
//  Created by Cody Rayment on 2014-03-20.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCView.h"

@interface PCView()

@property (assign, nonatomic) IBInspectable NSInteger tag;

@end

@implementation PCView

@synthesize anchorPoint = _anchorPoint;
@synthesize tag = _tag;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.pc_userInteractionEnabled = YES;
    self.anchorPoint = CGPointZero;
}

- (NSView *)hitTest:(NSPoint)aPoint {
    if (!self.pc_userInteractionEnabled) return nil;
    return [super hitTest:aPoint];
}

- (BOOL)wantsDefaultClipping {
    return NO;
}

#pragma mark - Layer Update

- (BOOL)wantsLayer {
    return YES;
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)updateLayer {
    self.layer.anchorPoint = self.anchorPoint;
    self.layer.backgroundColor = self.pc_backgroundColor.CGColor;
}

#pragma mark - Properties

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    if (!CGPointEqualToPoint(_anchorPoint, anchorPoint)) {
        _anchorPoint = anchorPoint;
        [self.layer setNeedsDisplay];
    }
}

@end
