//
//  NSString+FileUtilities.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-02.
//
//

#import <Foundation/Foundation.h>

@interface NSString (FileUtilities)

- (BOOL)pc_isHiddenFile;

+ (NSArray *)pc_imageExtensions;
+ (NSArray *)pc_audioExtensions;
+ (NSArray *)pc_3DExtensions;
+ (NSArray *)pc_cardExtensions;

- (BOOL)pc_isImageFileExtension;
- (BOOL)pc_isAudioFileExtension;
- (BOOL)pc_is3DFileExtension;
- (BOOL)pc_isCardFileExtension;

/**
 Appends @2x before the path extension. 
 @discussion Checks for existence of @2x. If it exists, just returns the file name.
 */
- (NSString *)pc_retinaFilePath;

/**
 Removes @2x from end of file name if it exists
 */
- (NSString *)pc_sdFilePath;

/**
 @discussion not used except for to resolve a potential issue customers may have run into due to a regression that shipped
 @return the file path with a suffix of @2x@2x, regardless of if the file path has an @2x suffix or not already. 
 */
- (NSString *)pc_doubleRetinaPath;

@end
