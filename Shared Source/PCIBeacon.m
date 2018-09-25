//
//  PCIBeacon.m
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2014-04-17.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCIBeacon.h"

@implementation PCIBeacon

- (id)init {
    self = [super init];
    if (self) {
        _beaconName = @"name";
        _beaconUUID = @"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
        _beaconMajorId = @"0";
        _beaconMinorId = @"0";

        _uuid = [[NSUUID UUID] UUIDString];
    } return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _beaconName = dict[@"beaconName"];
        _beaconUUID = dict[@"beaconUUID"];
        _beaconMajorId = dict[@"beaconMajorId"];
        _beaconMinorId = dict[@"beaconMinorId"];

        _uuid = dict[@"uuid"];
    } return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![[other class] isEqual:[self class]]) return NO;

    PCIBeacon *otherBeacon = (PCIBeacon *)other;
    BOOL sameUUID = [otherBeacon.beaconUUID isEqualToString:self.beaconUUID];
    BOOL sameMajor = [otherBeacon.beaconMajorId isEqualToString:self.beaconMajorId];
    BOOL sameMinor = [otherBeacon.beaconMinorId isEqualToString:self.beaconMinorId];

    return sameUUID && sameMajor && sameMinor;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dictRep = @{
        @"beaconName" : self.beaconName,
        @"beaconUUID" : self.beaconUUID,
        @"beaconMajorId" : self.beaconMajorId,
        @"beaconMinorId" : self.beaconMinorId,
        @"uuid" : self.uuid
    };
    return dictRep;
}

@end
