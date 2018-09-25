//
//  NSString+RelativePath.m
//
//  Created by numata on 2010/01/12.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "NSString+RelativePath.h"


@implementation NSString (RelativePath)

- (NSString *)absolutePathFromBaseDirectoryPath:(NSString *)baseDirectoryPath
{
    if ([self hasPrefix:@"~"]) {
        return [self stringByExpandingTildeInPath];
    }
    
    NSString *theBasePath = [baseDirectoryPath stringByExpandingTildeInPath];

    if (![self hasPrefix:@"."]) {
        return [theBasePath stringByAppendingPathComponent:self];
    }
    
    NSMutableArray *pathComponents1 = [NSMutableArray arrayWithArray:[self pathComponents]];
    NSMutableArray *pathComponents2 = [NSMutableArray arrayWithArray:[theBasePath pathComponents]];

    while ([pathComponents1 count] > 0) {        
        NSString *topComponent1 = [pathComponents1 objectAtIndex:0];
        [pathComponents1 removeObjectAtIndex:0];

        if ([topComponent1 isEqualToString:@".."]) {
            if ([pathComponents2 count] == 1) {
                // Error
                return nil;
            }
            [pathComponents2 removeLastObject];
        } else if ([topComponent1 isEqualToString:@"."]) {
            // Do nothing
        } else {
            [pathComponents2 addObject:topComponent1];
        }
    }
    
    return [NSString pathWithComponents:pathComponents2];
}

@end

