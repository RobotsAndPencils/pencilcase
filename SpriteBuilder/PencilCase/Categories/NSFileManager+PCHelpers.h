//
//  NSFileManager+PCPHelpers.h
//  RoboCase
//
//  Created by Paul Thorsteinson on 2015-01-05.
//  Copyright (c) 2015 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (PCHelpers)

- (NSUInteger)pc_getDirectoryFileSize:(NSURL *)directoryUrl;

/**
 *  Calculates the MD5 hash of a directory of files
 *
 *  @param absolutePath absolute path to the directory
 *  @param error        upon completion, an error that occured during calculation, if any
 *
 *  @return The MD5 hash or nil if there was an error
 */
- (NSString *)pc_md5Directory:(NSString *)absolutePath error:(NSError **)error;

@end
