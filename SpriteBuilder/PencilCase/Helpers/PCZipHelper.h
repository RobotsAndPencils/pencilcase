//
//  PCZipHelper.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-15.
//
//

#import <Foundation/Foundation.h>

@interface PCZipHelper : NSObject

/**
 Exports the contents of a .zip file to a folder
 @param absoluteSourceZipPath the absolute file path to the zip file on the computer
 @param absoluteDestinationPath the absolute path to the folder that the zip contents should be exported to
 */
+ (void)unzipFileAtPath:(NSString *)absoluteSourceZipPath toPath:(NSString *)absoluteDestinationPath;

@end
