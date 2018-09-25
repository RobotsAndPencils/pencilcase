//
//  NSButton+DeviceTypeSettings.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-19.
//
//]

#import <Foundation/Foundation.h>
#import "PCProjectSettings.h"

@interface NSButton (DeviceTypeSettings)

@property (assign, nonatomic) PCDeviceTargetType pc_deviceTarget;
@property (assign, nonatomic) PCDeviceTargetOrientation pc_deviceOrientation;
@property (copy, nonatomic) NSString *pc_configurationImageName;

@end