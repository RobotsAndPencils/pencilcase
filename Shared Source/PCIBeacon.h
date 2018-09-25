//
//  PCIBeacon.h
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2014-04-17.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PCIBeacon : NSObject

@property (copy, nonatomic) NSString *beaconName;
@property (copy, nonatomic) NSString *beaconUUID;
@property (copy, nonatomic) NSString *beaconMajorId;
@property (copy, nonatomic) NSString *beaconMinorId;

@property (copy, nonatomic) NSString *uuid;

- (instancetype)init;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
