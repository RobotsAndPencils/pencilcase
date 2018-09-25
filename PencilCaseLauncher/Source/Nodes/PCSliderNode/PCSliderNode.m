//
//  PCSliderNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-12.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCSliderNode.h"
#import "PCOverlayView.h"
#import "SKNode+LifeCycle.h"
#import "PCJSContext.h"
#import "SKNode+JavaScript.h"

@interface PCSliderNode ()

@property (strong, nonatomic) UISlider *overlaySlider;
@property (strong, nonatomic) UIView *sliderContainerView;

@end

@implementation PCSliderNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.overlaySlider = [[UISlider alloc] init];
        [self.overlaySlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];

        self.sliderContainerView = [[UIView alloc] init];
        self.sliderContainerView.backgroundColor = [UIColor clearColor];
        [self.sliderContainerView addSubview:self.overlaySlider];
    }
    return self;
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    self.overlaySlider.userInteractionEnabled = self.userInteractionEnabled;
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Actions

- (void)sliderValueChanged {
    self.currentValue = self.overlaySlider.value;

    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"valueChanged",
        PCJSContextEventNotificationArgumentsKey: @[ self ]
    }];
}

#pragma mark - Properties

- (void)setMinimumValue:(CGFloat)minimumValue {
    if (_minimumValue != minimumValue) {
        _minimumValue = minimumValue;
        self.overlaySlider.minimumValue = minimumValue;
    }
}

- (void)setMaximumValue:(CGFloat)maximumValue {
    if (_maximumValue != maximumValue) {
        _maximumValue = maximumValue;
        self.overlaySlider.maximumValue = maximumValue;
    }
}

- (void)setCurrentValue:(CGFloat)currentValue {
    if (_currentValue != currentValue) {
        _currentValue = currentValue;
        self.overlaySlider.value = currentValue;
    }
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.overlaySlider.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.sliderContainerView;
}

@end
