//
// Created by Brandon Evans on 15-01-09.
//

@import JavaScriptCore;
#import "PCIBeacon.h"

@protocol PCIBeaconJSExport <JSExport>

@property (copy, nonatomic) NSString *beaconUUID;
@property (strong, nonatomic) NSNumber *beaconMajorId;
@property (strong, nonatomic) NSNumber *beaconMinorId;

- (id)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isEqual:(id)otherBeacon;

@end

@interface PCIBeacon (JSExport) <PCIBeaconJSExport>
@end