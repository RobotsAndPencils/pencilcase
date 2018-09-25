//
// Created by Brandon Evans on 14-11-20.
//

#import "NSUUID+UUIDWithString.h"

@implementation NSUUID (UUIDWithString)

+ (NSUUID *)pc_UUIDWithString:(NSString *)uuidString {
    return [[NSUUID alloc] initWithUUIDString:uuidString];
}

@end