//
//  PCBeaconManagerTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-12.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PCBeaconManager.h"
#import "PCJSContext.h"
#import "PCIBeacon.h"

@interface PCBeaconManager (Tests) <CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray *iBeaconList;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *rangedRegions;
@property (strong, nonatomic) NSMutableDictionary *beaconsRegionMemo;

- (NSString *)uniqueIDForBeacon:(CLBeacon *)beacon;
- (void)triggerIBeaconProximityDidChange:(CLBeacon *)beacon proximity:(NSString *)proximity;
- (PCIBeacon *)beaconWithUUID:(NSString *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;

@end

SPEC_BEGIN(PCBeaconManagerTests)

__block PCBeaconManager *beaconManager;
__block PCIBeacon *beacon;
__block CLBeaconRegion *region;
__block CLBeacon *rangedBeacon;
beforeEach(^{
    beaconManager = [PCBeaconManager new];
    NSUUID *uuid = [NSUUID UUID];
    beacon = [[PCIBeacon alloc] initWithDictionary:@{
        @"beaconName": @"Test Beacon",
        @"beaconUUID": [uuid UUIDString],
        @"beaconMajorId": @2,
        @"beaconMinorId": @3
    }];
    region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:2 minor:3 identifier:[uuid UUIDString]];

    rangedBeacon = [[CLBeacon alloc] init];
    [rangedBeacon stub:@selector(proximityUUID) andReturn:region.proximityUUID];
    [rangedBeacon stub:@selector(major) andReturn:@2];
    [rangedBeacon stub:@selector(minor) andReturn:@3];
    [rangedBeacon stub:@selector(proximity) andReturn:theValue(CLProximityNear)];

    beaconManager.iBeaconList = @[ beacon ];
});

context(@"When a beacon is ranged", ^{
    context(@"for the first time", ^{
        it(@"should trigger a JS event notification with the correct arguments", ^{
            [[PCJSContextEventNotificationName should] bePostedWithObject:nil andUserInfo:@{
                PCJSContextEventNotificationEventNameKey: @"iBeaconChangedProximity",
                PCJSContextEventNotificationArgumentsKey: @[ beacon, @"near" ]
            }];

            [beaconManager locationManager:beaconManager.locationManager didRangeBeacons:@[ rangedBeacon ] inRegion:region];
        });
    });

    context(@"for the second time", ^{
        beforeEach(^{
            NSString *uniqueId = [beaconManager uniqueIDForBeacon:rangedBeacon];
            beaconManager.beaconsRegionMemo = [NSMutableDictionary dictionary];
            beaconManager.beaconsRegionMemo[region] = [@{ uniqueId : rangedBeacon } mutableCopy];
        });

        context(@"with a different proximity", ^{
            __block CLBeacon *newRangedBeacon;
            beforeEach(^{
                newRangedBeacon = [CLBeacon new];
                [newRangedBeacon stub:@selector(proximityUUID) andReturn:region.proximityUUID];
                [newRangedBeacon stub:@selector(major) andReturn:@2];
                [newRangedBeacon stub:@selector(minor) andReturn:@3];
                [newRangedBeacon stub:@selector(proximity) andReturn:theValue(CLProximityFar)];
            });

            it(@"should trigger a JS event notification with the correct arguments", ^{
                [[PCJSContextEventNotificationName should] bePostedWithObject:nil andUserInfo:@{
                    PCJSContextEventNotificationEventNameKey: @"iBeaconChangedProximity",
                    PCJSContextEventNotificationArgumentsKey: @[ beacon, @"far" ]
                }];

                [beaconManager locationManager:beaconManager.locationManager didRangeBeacons:@[ newRangedBeacon ] inRegion:region];
            });
        });

        context(@"with the same proximity", ^{
            __block CLBeacon *newRangedBeacon;
            beforeEach(^{
                newRangedBeacon = [CLBeacon new];
                [newRangedBeacon stub:@selector(proximityUUID) andReturn:region.proximityUUID];
                [newRangedBeacon stub:@selector(major) andReturn:@2];
                [newRangedBeacon stub:@selector(minor) andReturn:@3];
                [newRangedBeacon stub:@selector(proximity) andReturn:theValue(CLProximityNear)];
            });

            it(@"should not trigger a JS event notification", ^{
                [[PCJSContextEventNotificationName shouldNot] bePostedWithObject:nil andUserInfo:@{
                    PCJSContextEventNotificationEventNameKey: @"iBeaconChangedProximity",
                    PCJSContextEventNotificationArgumentsKey: @[ beacon, @"near" ]
                }];

                [beaconManager locationManager:beaconManager.locationManager didRangeBeacons:@[ newRangedBeacon ] inRegion:region];
            });
        });
    });
});

context(@"When beacon proximity changes", ^{
    context(@"and the beacon can't be looked up", ^{
        it(@"shouldn't throw an exception", ^{
            [[theBlock(^{
                [beaconManager triggerIBeaconProximityDidChange:nil proximity:@"near"];
            }) shouldNot] raise];
        });
    });
});

context(@"When looking up PCIBeacons", ^{
    __block NSString *uuid;
    __block NSInteger major;
    __block NSInteger minor;
    beforeEach(^{
        uuid = [[NSUUID UUID] UUIDString];
        major = 2;
        minor = 3;
    });

    context(@"and the registered PCIBeacon has an upper-case UUID", ^{
        beforeEach(^{
            beacon = [[PCIBeacon alloc] initWithDictionary:@{
                @"beaconName": @"Test Beacon",
                @"beaconUUID": uuid,
                @"beaconMajorId": @(major),
                @"beaconMinorId": @(minor)
            }];

            beaconManager.iBeaconList = @[ beacon ];
        });

        it(@"should return the matching beacon", ^{
            [[[beaconManager beaconWithUUID:uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor] shouldNot] beNil];
        });
    });

    context(@"and the registered PCIBeacon has a lower-case UUID", ^{
        beforeEach(^{
            beacon = [[PCIBeacon alloc] initWithDictionary:@{
                @"beaconName": @"Test Beacon",
                @"beaconUUID": uuid.lowercaseString,
                @"beaconMajorId": @(major),
                @"beaconMinorId": @(minor)
            }];

            beaconManager.iBeaconList = @[ beacon ];
        });

        it(@"should return the matching beacon", ^{
            [[[beaconManager beaconWithUUID:uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor] shouldNot] beNil];
        });
    });
});

SPEC_END
