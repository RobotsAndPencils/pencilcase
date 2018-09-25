//
//  PCResource.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-08-18.
//
//

#import "PCResourceManager.h"
#import "AVAsset+Metadata.h"
#import "PCProjectSettings.h"
#import "AppDelegate.h"
#import "CCBFileUtil.h"
#import "ResourceManagerOutlineHandler.h"
#import "ResourceManagerUtil.h"
#import "PCResource.h"
#import "Constants.h"
#import "PCResourceManager.h"
#import "NSString+FileUtilities.h"

@interface PCResource()

@property (nonatomic, strong, readwrite) NSURL *fileReferenceURL;
@property (nonatomic, readwrite) BOOL loadedWithNilPath;

@end

@implementation PCResource

- (id)init {
    if ((self = [super init])) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }
    return self;
}

#pragma mark - NScoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.type = (enum PCResourceType) [coder decodeIntForKey:@"type"];
        self.data = [coder decodeObjectForKey:@"data"];
        //There is an issue that shipped where it's possible for the users to save their project with no path encoded. This is a huge problem but if we don't handle it in some way, not only did they end up with an invalid resource, but they can never open their project ever again. At this point we are loading and the project is already broken beyond repair, so we mark the resource as invalid so that we can clean it out after load and they can at least recover the rest of their project.
        NSString *rawPath = [coder decodeObjectForKey:@"filePath"];
        if (!rawPath) {
            self.loadedWithNilPath = YES;
        }
        self.filePath = [ResourceManagerUtil projectPathFromRelativePath:rawPath];

        self.duration = [coder decodeDoubleForKey:@"duration"];
        self.naturalSize = [coder decodeSizeForKey:@"naturalSize"];
        self.uuid = [coder decodeObjectForKey:@"uuid"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:self.data forKey:@"data"];
    [coder encodeObject:[ResourceManagerUtil relativePathFromPathInProject:self.filePath] forKey:@"filePath"];
    [coder encodeDouble:self.duration forKey:@"duration"];
    [coder encodeSize:self.naturalSize forKey:@"naturalSize"];
    [coder encodeObject:self.uuid forKey:@"uuid"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"PCResource %p\n"
                                       "  type: %ld\n"
                                       "  filePath: %@\n"
                                       "  uuid: %@",
                                       &self, self.type, self.filePath, self.uuid];
}

#pragma mark - Implementation

- (void)loadData:(dispatch_block_t)completion {
    switch (self.type) {
        case PCResourceTypeVideo: {
            if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) return;

            PCProjectSettings *settings = [AppDelegate appDelegate].currentProjectSettings;

            // Get any cached values
            CGSizeMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) [settings valueForResource:self andKey:@"naturalSize"], &_naturalSize);
            _duration = [[settings valueForResource:self andKey:@"duration"] doubleValue];

            // Update values from the file
            NSURL *url = [NSURL fileURLWithPath:self.filePath];
            AVAsset *asset = [AVAsset assetWithURL:url];

            if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] == 0) return;

            [asset fetchMetadataWithCompletion:^(CGSize naturalSize, NSTimeInterval duration) {
                if (!CGSizeEqualToSize(self.naturalSize, naturalSize)) {
                    self.naturalSize = CGSizeMake(naturalSize.width, naturalSize.height);
                }
                if (self.duration != duration) {
                    self.duration = duration;
                }

                // Cache the new values
                [settings setValue:CFBridgingRelease(CGSizeCreateDictionaryRepresentation(self.naturalSize)) forResource:self andKey:@"naturalSize"];
                [settings setValue:@(duration) forResource:self andKey:@"duration"];

                completion();
            }];
            break;
        }
        case PCResourceTypeDirectory:
            // Ignore changed directories
            completion();
            break;
        default:
            self.data = nil;
            completion();
            break;
    }
}

- (NSImage *)previewForResolution:(NSString *)res {
    if (self.type == PCResourceTypeImage) {
        NSImage *img = [[NSImage alloc] initWithContentsOfURL:self.fileReferenceURL];
        return img;
    }

    return nil;
}

- (NSComparisonResult)compare:(id)obj {
    PCResource *res = obj;

    if (res.type < self.type) {
        return NSOrderedDescending;
    }
    else if (res.type > self.type) {
        return NSOrderedAscending;
    }
    else {
        return [[self.filePath lastPathComponent] compare:[res.filePath lastPathComponent] options:NSNumericSearch | NSForcedOrderingSearch | NSCaseInsensitiveSearch];
    }
}

#pragma mark - Pasteboard

- (id)pasteboardPropertyListForType:(NSString *)pbType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if ([pbType isEqualToString:PCPasteboardTypeResource]) {
        [dict setObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
        [dict setObject:self.filePath forKey:@"filePath"];
        return dict;
    }
    else if ([pbType isEqualToString:PCPasteboardTypeTexture]) {
        [dict setObject:self.uuid forKey:@"spriteFile"];
        return dict;
    }
    else if ([pbType isEqualToString:PCPasteboardTypeCCB]) {
        [dict setObject:self.relativePath forKey:@"ccbFile"];
        return dict;
    }
    else if ([pbType isEqualToString:PCPasteboardTypeWAV]) {
        [dict setObject:self.relativePath forKey:@"wavFile"];
        return dict;
    }
    else if ([pbType isEqualToString:PCPasteboardTypeMOV]) {
        [dict setObject:self.relativePath forKey:@"movFile"];
        return dict;
    }
    else if ([pbType isEqualToString:PCPasteboardType3DModel]) {
        [dict setObject:self.relativePath forKey:@"daeFile"];
        return dict;
    }
    
    return NULL;
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    NSMutableArray *pbTypes = [NSMutableArray arrayWithObject:PCPasteboardTypeResource];
    if (self.type == PCResourceTypeImage) {
        [pbTypes addObject:PCPasteboardTypeTexture];
    }
    else if (self.type == PCResourceTypeCCBFile) {
        [pbTypes addObject:PCPasteboardTypeCCB];
    }
    else if (self.type == PCResourceTypeAudio) {
        [pbTypes addObject:PCPasteboardTypeWAV];
    }
    else if (self.type == PCResourceTypeVideo) {
        [pbTypes addObject:PCPasteboardTypeMOV];
    }
    else if (self.type == PCResourceType3DModel) {
        [pbTypes addObject:PCPasteboardType3DModel];
    }

    return pbTypes;
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)pbType pasteboard:(NSPasteboard *)pasteboard {
    if ([pbType isEqualToString:PCPasteboardTypeResource]) return NSPasteboardWritingPromised;
    if ([pbType isEqualToString:PCPasteboardTypeCCB] && self.type == PCResourceTypeCCBFile) return NSPasteboardWritingPromised;
    if ([pbType isEqualToString:PCPasteboardTypeTexture] && self.type == PCResourceTypeImage) return NSPasteboardWritingPromised;
    if ([pbType isEqualToString:PCPasteboardTypeWAV] && self.type == PCResourceTypeAudio) return NSPasteboardWritingPromised;
    if ([pbType isEqualToString:PCPasteboardTypeMOV] && self.type == PCResourceTypeVideo) return NSPasteboardWritingPromised;
    if ([pbType isEqualToString:PCPasteboardType3DModel] && self.type == PCResourceType3DModel) return NSPasteboardWritingPromised;
    return 0;
}

#pragma mark - FilePaths

- (void)setFilePath:(NSString *)filePath {
    if (!filePath) return;

    if (self.type == PCResourceTypeDirectory) {
        PCResourceDirectory *directory = self.data;
        [self recreateDirectoryIfNecessaryAtPath:filePath];
        NSURL *referenceURL = [[NSURL fileURLWithPath:filePath isDirectory:YES] fileReferenceURL];
        directory.directoryReferenceURL = referenceURL;
    }

    NSURL *referenceURL = [[NSURL fileURLWithPath:filePath isDirectory:NO] fileReferenceURL];
    self.fileReferenceURL = referenceURL;
}

- (NSString *)filePath {
    return self.fileReferenceURL.path;
}

- (NSString *)relativePath {
    return [ResourceManagerUtil relativePathFromAbsolutePath:self.filePath];
}

// Returns the full filepath for this resource inside resources-auto
- (NSString *)autoPath {
    return self.filePath;
}

- (NSString *)directoryPath {
    return (self.type == PCResourceTypeDirectory) ? self.filePath : [self.filePath stringByDeletingLastPathComponent];
}

- (NSString *)absoluteFilePath {
    //our file path is an absolute path to the resource in the project, but when loading we want an absolute path to the resource in the library
    NSString *filePath = [[PCResourceManager sharedManager] toAbsolutePath:[ResourceManagerUtil relativePathFromAbsolutePath:self.filePath]];
    if (self.type != PCResourceTypeImage) return filePath;

    NSString *extension = [filePath pathExtension];
    NSString *filePathWithoutFilename = [filePath stringByDeletingLastPathComponent];
    filePath = [[filePathWithoutFilename stringByAppendingPathComponent:self.uuid] stringByAppendingPathExtension:extension];

    NSString *filePathForCurrentResolution = ([[NSScreen mainScreen] backingScaleFactor] < 2.f) ? [filePath pc_sdFilePath] : [filePath pc_retinaFilePath];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePathForCurrentResolution] ? filePathForCurrentResolution : filePath;
}

#pragma mark - Helpers

/**
 @discussion Because our project has strong expectations of what our file system is like, we want to give it as few ways to fail as possible. Unfortunately, because we expect all folders that we say to exist to exist, we run into a problem with git - if any of those folders are empty, git will not include them in a commit, so anyone who checks out that .pcase project will be unable to open it. This method provides a workaround, by creating a folder for a resource directory if (and only if!) that directory has no resources, and the directory is missing.
 @param filePath an absolute file path to where the resource folder should exist
 */
- (void)recreateDirectoryIfNecessaryAtPath:(NSString *)filePath {
    PCResourceDirectory *directory = self.data;
    if (directory.resources.count) return;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]) return;

    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"Could not re-create directory at path %@", filePath);
    }
}



- (BOOL)visibleToUser {
    BOOL editedImage = [self.filePath rangeOfString:PCEditedImageSuffix].location != NSNotFound;
    BOOL posterFrame = [self.filePath rangeOfString:PCVideoPlayerPosterSuffix].location != NSNotFound;

    return !editedImage && !posterFrame;
}

- (void)updateFromDirectoryAtPath:(NSString *)originDirectory toDirectoryAtPath:(NSString *)destinationDirectory {
    PCResourceDirectory *originalResourceDirectory = [[PCResourceManager sharedManager] resourceDirectoryForPath:originDirectory];
    PCResourceDirectory *destinationResourceDirectory = [[PCResourceManager sharedManager] resourceDirectoryForPath:destinationDirectory];
    if (originalResourceDirectory != destinationResourceDirectory) {
        [originalResourceDirectory removeResource:self];
        self.filePath = [destinationResourceDirectory.directoryPath stringByAppendingPathComponent:[self.filePath lastPathComponent]];
        [destinationResourceDirectory addResource:self];
    }
}

+ (PCResourceType)resourceTypeFromString:(NSString *)resourceTypeString {
    static NSDictionary *resourceTypeMapping = nil;
    static dispatch_once_t dispatchToken;
    dispatch_once(&dispatchToken, ^{
        resourceTypeMapping = @{
                                 @"Video" : @(PCResourceTypeVideo),
                                 @"Directory" : @(PCResourceTypeDirectory),
                                 @"Image" : @(PCResourceTypeImage),
                                 @"Font" : @(PCResourceTypeTTF),
                                 @"Audio" : @(PCResourceTypeAudio),
                                 @"3D Model" : @(PCResourceType3DModel)
                               };
    });

    return resourceTypeMapping[resourceTypeString] ? [resourceTypeMapping[resourceTypeString] intValue] : PCResourceTypeNone;
}

#pragma mark - IKImageBrowserItem
//This code is not referenced by our own code but used in the media browser.

- (NSString *)imageUID {
    return self.relativePath;
}

- (NSString *)imageRepresentationType {
    if (self.type == PCResourceTypeAudio) {
        return IKImageBrowserNSImageRepresentationType;
    } else {
        return IKImageBrowserPathRepresentationType;
    }
}

- (id)imageRepresentation {
    NSFileManager *fm = [NSFileManager defaultManager];

    switch (self.type) {
        case PCResourceTypeAudio: {
            NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:self.filePath];
            return icon;
        }
        case PCResourceTypeImage: {
            NSString *autoPath = [self autoPath];
            if ([fm fileExistsAtPath:autoPath]) {
                return autoPath;
            }
        }
        case PCResourceTypeCCBFile: {
            NSString *previewPath = [self.filePath stringByAppendingPathExtension:@"ppng"];
            if ([fm fileExistsAtPath:previewPath]) {
                return previewPath;
            }
        }
        case PCResourceTypeVideo: {
            if ([fm fileExistsAtPath:self.filePath]) {
                return self.filePath;
            }
        }
        case PCResourceType3DModel: {
            if ([fm fileExistsAtPath:self.filePath]) {
                return self.filePath;
            }
        }
        default:
            return nil;
    }
}

- (NSUInteger)imageVersion {
    NSFileManager *fm = [NSFileManager defaultManager];

    switch (self.type) {
        case PCResourceTypeImage: {
            NSString *autoPath = [self autoPath];
            if ([fm fileExistsAtPath:autoPath]) {
                NSDate *fileDate = [CCBFileUtil modificationDateForFile:autoPath];
                return (NSUInteger)[fileDate timeIntervalSinceReferenceDate];
            }
        }
        case PCResourceTypeCCBFile: {
            NSString *previewPath = [self.filePath stringByAppendingPathExtension:@"ppng"];
            if ([fm fileExistsAtPath:previewPath]) {
                NSDate *fileDate = [CCBFileUtil modificationDateForFile:previewPath];
                return (NSUInteger)[fileDate timeIntervalSinceReferenceDate];
            }
        }
        default:
            return 0;
    }
}

- (NSString *)imageTitle {
    return [[self.filePath lastPathComponent] stringByDeletingPathExtension];
}

- (BOOL)isSelectable {
    return YES;
}

@end