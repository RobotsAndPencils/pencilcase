//
//  PCBeaconManager.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-05-29.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCBeaconManager.h"
#import <RXCollections/RXCollection.h>
#import "PCIBeacon.h"
#import "PCSlideNode.h"
#import "PCJSContext.h"

@interface PCBeaconManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray *iBeaconList;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *rangedRegions;
@property (strong, nonatomic) NSMutableDictionary *beaconsRegionMemo;

@end

@implementation PCBeaconManager

#pragma mark - Public

- (void)startWithBeaconInfoDictionaries:(NSArray *)ibeaconInfos {
    [self cleanupIBeacons];

    self.beaconsRegionMemo = [NSMutableDictionary dictionary];

    self.locationManager = [self createLocationManager];
    if (!self.locationManager) return;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideDidLoad:) name:PCSlideLoadedEventNotification object:nil];

    self.iBeaconList = [ibeaconInfos rx_mapWithBlock:^id(NSDictionary *beaconInfo) {
        return [[PCIBeacon alloc] initWithDictionary:beaconInfo];
    }];

    self.rangedRegions = [self.iBeaconList rx_mapWithBlock:^id(PCIBeacon *beacon) {
        return [self startRangingBeacon:beacon];
    }];
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cleanupIBeacons];
}

- (PCIBeacon *)beaconWithUUID:(NSString *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor {
    return [self.iBeaconList rx_detectWithBlock:^BOOL(PCIBeacon *beacon) {
        // Case-insensitive because users can enter any case in PC Studio, but CLBeacons will report with uppercase UUIDs
        return ([beacon.beaconUUID caseInsensitiveCompare:uuid] == NSOrderedSame
                && [beacon.beaconMajorId integerValue] == major
                && [beacon.beaconMinorId integerValue] == minor);
    }];
}

#pragma mark - Setup

- (CLLocationManager *)createLocationManager {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return nil;
    }

    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    }

    return locationManager;
}

- (CLBeaconRegion *)startRangingBeacon:(PCIBeacon *)beacon {
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Monitoring not available");
        return nil;
    }

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beacon.beaconUUID];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:(CLBeaconMajorValue)[beacon.beaconMajorId integerValue] minor:(CLBeaconMinorValue)[beacon.beaconMinorId integerValue] identifier:beacon.uuid];
    if (!region) {
        PCLog(@"Failed to create region");
        return nil;
    };

    [self.locationManager startRangingBeaconsInRegion:region];
    return region;
}

- (void)updateProximityOfBeacon:(CLBeacon *)beacon inRegion:(CLRegion *)region {
    NSMutableDictionary *beaconsMemo = [self beaconsMemoForRegion:region];
    beaconsMemo[[self uniqueIDForBeacon:beacon]] = beacon;
    [self triggerIBeaconProximityDidChange:beacon proximity:[self stringForProximity:beacon.proximity]];
}

- (NSMutableDictionary *)beaconsMemoForRegion:(CLRegion *)region {
    NSMutableDictionary *beacons = self.beaconsRegionMemo[region];
    if (!beacons) {
        beacons = [NSMutableDictionary dictionary];
        self.beaconsRegionMemo[region] = beacons;
    }
    return beacons;
}

#pragma mark - Cleanup

- (void)cleanupIBeacons {
    [self stopRangingAllBeacons];
    self.iBeaconList = nil;
    self.beaconsRegionMemo = nil;
}

- (void)stopRangingAllBeacons {
    for (CLBeaconRegion *region in self.rangedRegions) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}

#pragma mark - Notifications

- (void)triggerIBeaconDidEnterRegion:(CLBeaconRegion *)beaconRegion {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"iBeaconEnteredRegion",
        PCJSContextEventNotificationArgumentsKey: @[ [beaconRegion.proximityUUID UUIDString] ]
    }];
}

- (void)triggerIBeaconDidExitRegion:(CLBeaconRegion *)beaconRegion {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"iBeaconExitedRegion",
        PCJSContextEventNotificationArgumentsKey: @[ [beaconRegion.proximityUUID UUIDString] ]
    }];
}

- (void)triggerIBeaconProximityDidChange:(CLBeacon *)beacon proximity:(NSString *)proximity {
    NSString *uuid = [beacon.proximityUUID UUIDString];
    CLBeaconMajorValue major = (CLBeaconMajorValue)[beacon.major integerValue];
    CLBeaconMinorValue minorValue = (CLBeaconMinorValue)[beacon.minor integerValue];
    PCIBeacon *pcBeacon = [self beaconWithUUID:uuid major:major minor:minorValue];

    if (!pcBeacon) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:@{
        PCJSContextEventNotificationEventNameKey: @"iBeaconChangedProximity",
        PCJSContextEventNotificationArgumentsKey: @[ pcBeacon, proximity ?: @"" ]
    }];
}

#pragma mark - Slide Notifications

- (void)slideDidLoad:(NSNotification *)notification {
    for (CLRegion *region in self.rangedRegions) {
        for (CLBeacon *beacon in [[self beaconsMemoForRegion:region] allValues]) {
            [self triggerIBeaconProximityDidChange:beacon proximity:[self stringForProximity:beacon.proximity]];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSMutableDictionary *beaconsMemo = [self beaconsMemoForRegion:region];
    for (CLBeacon *beacon in beacons) {
        CLBeacon *oldBeacon = beaconsMemo[[self uniqueIDForBeacon:beacon]];
        NSString *oldProximity = [self stringForProximity:oldBeacon.proximity];
        NSString *newProximity = [self stringForProximity:beacon.proximity];
        PCLog(@"Previous proximity: %@, New proximity: %@", oldProximity, newProximity);
        if (oldBeacon) {
            if (oldBeacon.proximity != beacon.proximity) {
                [self updateProximityOfBeacon:beacon inRegion:region];
            }
        } else {
            [self updateProximityOfBeacon:beacon inRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on ranging: Location services are not enabled.");
    }

    if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        NSLog(@"Couldn't turn on monitoring: Location services not authorized.");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location Manager Failed: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"Location Manager Ranging Region Failed: %@", error);
}

#pragma mark Helpers

- (BOOL)isProximity:(CLProximity)proximityA closerThanProximity:(CLProximity)proximityB {
    if (proximityA == CLProximityUnknown && proximityB != CLProximityUnknown) return NO;
    if (proximityB == CLProximityUnknown && proximityA != CLProximityUnknown) return YES;
    return proximityA < proximityB;
}

- (NSString *)uniqueIDForBeacon:(CLBeacon *)beacon {
    return [NSString stringWithFormat:@"%@ %@ %@", [beacon.proximityUUID UUIDString], beacon.major, beacon.minor];
}

- (NSString *)stringForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityImmediate:
            return @"immediate";
        case CLProximityNear:
            return @"near";
        case CLProximityFar:
            return @"far";
        case CLProximityUnknown:
        default:
            return @"unknown";
    }
}

@end
