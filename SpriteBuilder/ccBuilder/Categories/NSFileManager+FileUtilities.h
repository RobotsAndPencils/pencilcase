//
//  NSFileManager+FileUtilities.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-02-10.
//
//

#import <Foundation/Foundation.h>

@interface NSFileManager (FileUtilities)

+ (BOOL)pc_isFileInTrash:(NSURL *)fileUrl;

@end
