
//
//  AppSettingsViewController.h
//  PencilCase
//
//  Created by Brandon on 1/9/2014.
//  Copyright (c) 2014 Robots And Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JUInspectorViewContainer.h"

@interface AppSettingsViewController : NSViewController <NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet JUInspectorViewContainer *inspectorView;
@property (nonatomic, strong) IBOutlet JUInspectorView *generalInspectorView;
@property (nonatomic, strong) IBOutlet JUInspectorView *iconInspectorView;
@property (nonatomic, strong) IBOutlet JUInspectorView *thirdPartyInspectorView;

@property (nonatomic, strong) IBOutlet NSArrayController *iBeaconArrayController;

@end
