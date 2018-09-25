//
//  NSArray+SearchUtil.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-09.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (SearchUtil)

/**
 Given an array of file paths, determines if any of them end with the given extension.
 @param pathExtension The path extension to seek, for example, `dae`
 @returns YES if any of the files contain the provided extension. No otherwise.
 */
- (BOOL)pc_containsFileWithExtension:(NSString *)pathExtension;

@end
