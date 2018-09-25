//
// Created by Brandon Evans on 14-11-20.
//

#import <Foundation/Foundation.h>

@interface NSUUID (UUIDWithString)

// Shorthand for [[NSUUID alloc] initWithUUIDString:string];
+ (NSUUID *)pc_UUIDWithString:(NSString *)uuidString;

@end