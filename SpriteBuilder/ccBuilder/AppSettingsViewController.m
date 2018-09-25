//
//  AppSettingsViewController.m
//  PencilCase
//
//  Created by Brandon on 1/9/2014.
//  Copyright (c) 2014 Robots And Pencils. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "AppDelegate.h"

@implementation AppSettingsViewController

- (void)loadView {
    [super loadView];

    self.inspectorView.layer.backgroundColor = [[NSColor whiteColor] CGColor];

    [self.inspectorView addInspectorView:self.generalInspectorView expanded:YES];
    [self.inspectorView addInspectorView:self.iconInspectorView expanded:YES];
    [self.inspectorView addInspectorView:self.thirdPartyInspectorView expanded:YES];
}

@end
