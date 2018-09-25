//
//  NSString+ComputerModel.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-12.
//
//

#import "NSString+SystemInformation.h"
#include <sys/types.h>
#include <sys/sysctl.h>

//Based on http://stackoverflow.com/questions/8299087/getting-the-machine-type-and-other-hardware-details-through-cocoa-api
@implementation NSString (SystemInformation)

+ (NSString *)pc_computerModel {
    size_t length = 0;
    sysctlbyname("hw.model", NULL, &length, NULL, 0);

    if (!length) return @"Unknown Mac";

    char *model = malloc(length * sizeof(char));
    sysctlbyname("hw.model", model, &length, NULL, 0);
    NSString *modelString = [NSString stringWithUTF8String:model];
    free(model);
    return modelString;
}

+ (NSString *)pc_systemVersion {
    return [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"];
}

+ (NSString *)pc_systemName {
    return [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductName"];
}

@end
