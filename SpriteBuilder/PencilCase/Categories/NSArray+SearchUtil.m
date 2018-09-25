//
//  NSArray+SearchUtil.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-09.
//
//

#import "NSArray+SearchUtil.h"

@implementation NSArray (SearchUtil)

- (BOOL)pc_containsFileWithExtension:(NSString *)pathExtension {
    for (NSString *string in self) {
        if ([[string pathExtension] caseInsensitiveCompare:pathExtension] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

@end
