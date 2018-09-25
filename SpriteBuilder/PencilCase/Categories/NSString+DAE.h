//
//  NSString+FilePath.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-09.
//
//

#import <Foundation/Foundation.h>

@interface NSString (DAE)

/**
 Determines if the given string is a file path to an XML File. WARNING: This operation opens the file to inspect it and may be slow!
 @returns whether or not the file located at the absolute file path represented by this string is a valid xml file.
 */
- (BOOL)pc_isFilePathToXmlFile;

/**
 *  Parse through the xml dae file and find images that it is using
 *  @param modelPath path to dae file
 *  @return list of paths to the images
 */
+ (NSArray *)pc_fetchTextureImagePathsFor3DModelAt:(NSString *)modelPath;

@end
