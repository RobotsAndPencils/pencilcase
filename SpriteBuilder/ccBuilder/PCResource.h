//
//  PCResource.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-08-18.
//
//

#import "PCFileSystemResource.h"

typedef NS_ENUM(NSInteger, PCResourceType) {
    PCResourceTypeNone,
    PCResourceTypeDirectory,
    PCResourceTypeImage,
    PCResourceTypeBMFont,
    PCResourceTypeTTF,
    PCResourceTypeCCBFile,
    PCResourceTypeJS,
    PCResourceTypeJSON,
    PCResourceTypeAudio,
    PCResourceTypeGeneratedSpriteSheetDef,
    PCResourceTypeVideo,
    PCResourceType3DModel,
};

@interface PCResource : NSResponder <NSPasteboardWriting, NSCoding, PCFileSystemResource>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) PCResourceType type;
@property (nonatomic, strong) id data;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGSize naturalSize;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, readonly) BOOL loadedWithNilPath;

@property (nonatomic, strong, readonly) NSURL *fileReferenceURL;
@property (nonatomic, copy, readonly) NSString *relativePath;


/**
 @returns the string matching the resource type, or PCResourceTypeNone if there is none.
 */
+ (PCResourceType)resourceTypeFromString:(NSString *)resourceTypeString;

/**
 @returns The path to the version of the resource in the resources-auto compiled folder. Used to show the resource in the app.
 */
- (NSString *)autoPath;

/**
 Convenience method that converts the file path of the resource to an absolute file path of the resource, processed for use on the target device
 @returns The converted absolute resource file path
 */
- (NSString *)absoluteFilePath;

/**
 Loads data related to the internal file resource this PCResource represents. Ex. Loads duration for a video file
 */
- (void)loadData:(dispatch_block_t)completion;

/**
 Finds a preview image for this resource, given the current resolution we are displaying
 @param resolution The resolution we are displaying
 @returns The preview image
 */
- (NSImage *)previewForResolution:(NSString*)resolution;

/**
 @returns Whether or not this resource should be visible to the user in the resource outline views
 */
- (BOOL)visibleToUser;

/**
 Inform the resource that it has been moved to a different directory
 @param originDirectory the absolute file path of the directory the resource originally lived in
 @param destinationDirectory the absolute file path of the directory that the resource now lives in
 */
- (void)updateFromDirectoryAtPath:(NSString *)originDirectory toDirectoryAtPath:(NSString *)destinationDirectory;

@end
