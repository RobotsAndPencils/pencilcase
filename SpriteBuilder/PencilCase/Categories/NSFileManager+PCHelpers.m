//
//  NSFileManager+PCHelpers.m
//  RoboCase
//
//  Created by Paul Thorsteinson on 2015-01-05.
//  Copyright (c) 2015 Robots and Pencils Inc. All rights reserved.
//

#import "NSFileManager+PCHelpers.h"
#import "NSError+PencilCaseErrors.h"

@implementation NSFileManager (PCPHelpers)

- (NSUInteger)pc_getDirectoryFileSize:(NSURL *)directoryUrl {
    NSUInteger result = 0;
    NSArray *properties = @[NSURLLocalizedNameKey,NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey];
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directoryUrl includingPropertiesForKeys:properties options:(NSDirectoryEnumerationSkipsHiddenFiles) error:nil];
    
    for (NSURL *fileSystemItem in directoryContents) {
        BOOL directory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:fileSystemItem.path isDirectory:&directory];
        if (!directory) {
            result += [[[[NSFileManager defaultManager] attributesOfItemAtPath:fileSystemItem.path error:nil] objectForKey:NSFileSize] unsignedIntegerValue];
        }
        else {
            result += [self pc_getDirectoryFileSize:fileSystemItem];
        }
    }
    
    return result;
}

- (NSString *)pc_md5Directory:(NSString *)absolutePath error:(NSError **)error {
    // http://stackoverflow.com/questions/1657232/how-can-i-calculate-an-md5-checksum-of-a-directory
    // find [ABS_PATH] -type f ! -iname ".*" -exec md5 {} + | perl -pe 's/\Q[ABS_PATH]\E//' | md5
    // First we find every file in the directory ignoring those that start with a . and exec md5 on them
    //   find [ABS_PATH] -type f ! -iname ".*" -exec md5 {} +
    // Then we user perl to replace the part of the path we don't care about from the output (up to and including this folder)
    //    perl -pe 's/\Q[ABS_PATH]\E//'
    // And then we md5 that full output string

    // Must escape the perl regex delimiter "/" by replace with "/\".
    // The \Q\E takes care of everything else (like a filename with a "+")
    NSString *escapedAbsolutePath = [absolutePath stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
    // Escape single quotes in the absolute path that will appear in the Perl script and would otherwise close the expression early
    escapedAbsolutePath = [escapedAbsolutePath stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"];

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSString *taskFormatString = @"find \"%@\" -type f ! -iname \".*\" -exec /sbin/md5 {} + | perl -pe 's/\\Q%@\\E//' | /sbin/md5";
    NSString *taskCommand = [NSString stringWithFormat:taskFormatString, absolutePath, escapedAbsolutePath];
    task.arguments = @[ @"-c", taskCommand ];
    task.standardOutput = [NSPipe pipe];
    task.standardError = [NSPipe pipe];

    [task launch];
    [task waitUntilExit];

    NSFileHandle *outHandle = [[task standardOutput] fileHandleForReading];
    NSData *data = [outHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSFileHandle *errorHandle = [[task standardError] fileHandleForReading];
    NSData *errorData = [errorHandle readDataToEndOfFile];
    NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];

    NSLog(@"Checksum task finished with status: %@ stdout: %@ stderr: %@", @([task terminationStatus]), outputString, errorString);

    if ([task terminationStatus] != 0) {
        if (error) {
            *error = [NSError pc_resourceChecksumErrorWithDescription:errorString];
        }
        return nil;
    }

    return [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
