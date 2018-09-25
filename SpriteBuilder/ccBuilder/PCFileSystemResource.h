//
//  PCFileSystemResource.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-16.
//
//

#import <Foundation/Foundation.h>

/**
 A protocol that contains the functionality shared between PCResource and PCResourceDirectory
 */
@protocol PCFileSystemResource <NSObject>

/**
 @returns The path to the last directory in the resources file path. Will just return the resources path if the resource is a directory.
 */
- (NSString *)directoryPath;

@end
