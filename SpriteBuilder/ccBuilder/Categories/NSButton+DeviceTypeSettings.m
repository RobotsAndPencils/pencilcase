//
//  NSButton+DeviceTypeSettings.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-19.
//
//

#import "NSButton+DeviceTypeSettings.h"
#import <objc/runtime.h>

@implementation NSButton (DeviceTypeSettings)

- (void)setPc_deviceTarget:(PCDeviceTargetType)pc_deviceTarget {
    objc_setAssociatedObject(self, @selector(pc_deviceTarget), @(pc_deviceTarget), OBJC_ASSOCIATION_ASSIGN);
}

- (PCDeviceTargetType)pc_deviceTarget {
    return [objc_getAssociatedObject(self, @selector(pc_deviceTarget)) integerValue];
}

- (void)setPc_deviceOrientation:(PCDeviceTargetOrientation)pc_deviceOrientation {
    objc_setAssociatedObject(self, @selector(pc_deviceOrientation), @(pc_deviceOrientation), OBJC_ASSOCIATION_ASSIGN);
}

- (PCDeviceTargetOrientation)pc_deviceOrientation {
    return [objc_getAssociatedObject(self, @selector(pc_deviceOrientation)) integerValue];
}

- (void)setPc_configurationImageName:(NSString *)pc_configurationImageName{
    objc_setAssociatedObject(self, @selector(pc_configurationImageName), pc_configurationImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)pc_configurationImageName {
    return objc_getAssociatedObject(self, @selector(pc_configurationImageName));
}

@end
