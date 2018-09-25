//
//  PCBeaconManager.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-05-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class PCIBeacon;

@interface PCBeaconManager : NSObject

- (void)startWithBeaconInfoDictionaries:(NSArray *)ibeaconInfos;
- (void)stop;

/**
 * Returns the matching PCIBeacon object, or nil if not found
 */
- (PCIBeacon *)beaconWithUUID:(NSString *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;

@end
