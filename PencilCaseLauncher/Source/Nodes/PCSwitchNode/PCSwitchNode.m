//
//  PCSwitchNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-11.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <PencilCaseLauncher/PCJSContext.h>
#import "PCSwitchNode.h"
#import "PCOverlayView.h"
#import "SKNode+LifeCycle.h"

@interface PCSwitchNode ()

@property (strong, nonatomic) UISwitch *overlaySwitch;
@property (strong, nonatomic) UIView *switchContainerView;

@end

@implementation PCSwitchNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.overlaySwitch = [[UISwitch alloc] init];
        [self.overlaySwitch addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
        self.switchContainerView = [[UIView alloc] init];
        self.switchContainerView.backgroundColor = [UIColor clearColor];
        [self.switchContainerView addSubview:self.overlaySwitch];
    }
    return self;
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Actions

- (void)switchValueChanged {
    self.isOn = self.overlaySwitch.isOn;
    [self dispatchToggle];
}

#pragma mark - Private

- (void)dispatchToggle {
    NSString *state = self.isOn ? @"on" : @"off";
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"toggled",
        PCJSContextEventNotificationArgumentsKey: @[ self, state ]
    }];
}

#pragma mark - Properties

- (void)setIsOn:(BOOL)isOn {
    if (isOn != _isOn) {
        _isOn = isOn;
        self.overlaySwitch.on = isOn;
    }
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.overlaySwitch.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.switchContainerView;
}

@end
