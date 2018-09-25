//
//  NSFileManager+FileUtilities.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-02-10.
//
//

#import "NSFileManager+FileUtilities.h"

@implementation NSFileManager (FileUtilities)

+ (BOOL)pc_isFileInTrash:(NSURL *)fileUrl {
    BOOL isInTrash = NO;
    for (NSString *component in fileUrl.pathComponents) {
        if ([component isEqual:@".Trash"]) {
            isInTrash = YES;
        }
    }
    return isInTrash;
}

@end
