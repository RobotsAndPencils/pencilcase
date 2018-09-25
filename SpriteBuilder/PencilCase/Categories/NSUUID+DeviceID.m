//
//  NSUUID+DeviceID.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-12.
//
//

#import "NSUUID+DeviceID.h"
#import "PCApplicationSupport.h"

@implementation NSUUID (DeviceID)

+ (NSString *)pc_uniqueGlobalDeviceIdentifier {
    NSString *UUIDString = [NSString stringWithContentsOfFile:[PCApplicationSupport deviceIdentifierApplicationSupportFilePath] encoding:NSUTF8StringEncoding error:nil];

    @synchronized (self) {
        if (!UUIDString) {
            UUIDString = [[NSUUID UUID] UUIDString];
            [UUIDString writeToFile:[PCApplicationSupport deviceIdentifierApplicationSupportFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }

    return UUIDString;
}

@end
