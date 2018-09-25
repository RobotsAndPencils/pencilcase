/*
* CocosBuilder: http://www.cocosbuilder.com
*
* Copyright (c) 2012 Zynga Inc.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

#import <Underscore.m/Underscore.h>
#import <PencilCaseLauncher/PCDeviceResolutionSettings.h>

#import "PCResourceManager.h"
#import "PCResourceManager+Migration.h"
#import "PCResourceManagerDictionaryKeys.h"
#import "ResourceManagerUtil.h"
#import "ResourceManagerOutlineHandler.h"

#import "CCBDocument.h"
#import "CCBFileUtil.h"
#import "CCBPublisher.h"
#import "CCBReaderInternal.h"

#import "AppDelegate.h"
#import "PCProjectSettings.h"
#import "PCDeviceResolutionSettings.h"
#import "SoundFileImageController.h"

#import "SKNode+NodeInfo.h"
#import "ResourceManagerUtil.h"

#import "NSArray+SearchUtil.h"
#import "NSString+DAE.h"
#import "NSError+PencilCaseErrors.h"
#import "NSImage+PNGRepresentation.h"
#import "NSString+FileNameFormatting.h"
#import "PCTemplate.h"
#import "PCTemplateLibrary.h"
#import "NSString+FileUtilities.h"

// This is needed since in order to make an NSFont it needs a size, and when checking for equality
CGFloat const PCResourceManagerInternalFontSize = 20.0;

NSString *const PCEditedImageSuffix = @"PencilCaseEditedImage";
NSString *const PCVideoPlayerPosterSuffix = @"-PencilCasePosterFrame";
NSString *const PCResourceFolderName = @"resources";
NSInteger const defaultDuplicateResourceIndex = 2;

static NSString *const PCMacArchiveMetadataFolder = @"__MACOSX";
static NSString *const PCResourceConfigFileName = @"resources.pcrm";


@interface PCResourceManager ()

@property (nonatomic, strong, readwrite) NSArray *supportedFonts;
@property (nonatomic, strong, readwrite) NSMutableArray *directories;
@property (assign, nonatomic) NSInteger batchOperationCount;

@end


@implementation PCResourceManager

#define kIgnoredExtensionsKey @"ignoredDirectoryExtensions"

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kIgnoredExtensionsKey : @[@"git", @"svn", @"xcodeproj", @"ppng", @"ccb"] }];
}

+ (PCResourceManager *)sharedManager {
    static dispatch_once_t onceToken;
    static PCResourceManager *resourceManager = nil;
    dispatch_once(&onceToken, ^{
        resourceManager = [[PCResourceManager alloc] init];
    });

    return resourceManager;
}

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.directories = [[NSMutableArray alloc] init];
    resourceObserver = [[NSMutableArray alloc] init];

    [self loadFontListTTF];

    return self;
}

- (void)loadFontListTTF {
    NSArray *fontNames = [[NSFontManager sharedFontManager] availableFontFamilies];
    self.supportedFonts = Underscore.array(fontNames).map(^NSFont *(NSString *fontName) {
        
        // find the path to the font file on the system
        CTFontDescriptorRef fontRef = CTFontDescriptorCreateWithNameAndSize ((CFStringRef)fontName, PCResourceManagerInternalFontSize);
        CFURLRef url = (CFURLRef)CTFontDescriptorCopyAttribute(fontRef, kCTFontURLAttribute);
        NSString *fontPath = [NSString stringWithString:[(__bridge NSURL *)url path]];
        CFRelease(fontRef);
        CFRelease(url);

        NSString *fontExt = [fontPath pathExtension];
        
        // only allow certain font files as there are some with xattr that won't be able to copy to device
        if ([fontExt isEqualToString:@"ttf"] || [fontExt isEqualToString:@"ttc"] || [fontExt isEqualToString:@"otf"] ||
            [fontName isEqualToString:@"Helvetica"] || [fontName isEqualToString:@"Helvetica Neue"]){
            return [NSFont fontWithName:fontName size:PCResourceManagerInternalFontSize];
        }
        else {
            return nil;
        }
        
    }).unwrap;
}

- (BOOL)isFontAvailable:(NSString *)fontName {
    for (NSFont *font in self.supportedFonts) {
        if ([font.familyName isEqualToString:fontName]) return YES;
    }
    return NO;
}

#pragma mark - Saving, Loading

- (void)save {
    if (![AppDelegate appDelegate].currentProjectSettings) return;
    if (self.batchOperationCount > 0) return;

    NSString *projectResourcesSavePath = [[AppDelegate appDelegate].currentProjectSettings.projectDirectory stringByAppendingPathComponent:PCResourceConfigFileName];
    NSDictionary *saveDictionary = @{ PCDirectoriesKey : self.directoriesWithRelativePaths,
                                      PCRootDirectoryKey : self.rootDirectory ? [ResourceManagerUtil relativePathFromPathInProject:self.rootDirectory.directoryPath] : @"",
                                      PCRootResourceDirectoryKey : self.rootResourceDirectory ? [ResourceManagerUtil relativePathFromPathInProject:self.rootResourceDirectory.directoryPath] : @"" };
    [NSKeyedArchiver archiveRootObject:saveDictionary toFile:projectResourcesSavePath];
}

- (BOOL)loadFromLocalDirectories:(NSDictionary *)directoriesWithLocalKeys localRootDirectory:(NSString *)rootDirectoryWithLocalPath localRootResourceDirectory:(NSString *)localRootResourceDirectory {
    if (!directoriesWithLocalKeys || !rootDirectoryWithLocalPath) return NO;
    directoriesWithLocalKeys = [self removeAllNilPathDirectories:[directoriesWithLocalKeys mutableCopy]];

    // validate the directory path exists in case pathways are corrupted
    if (![self validateResourceDirectoriesExist:directoriesWithLocalKeys.allValues]) return NO;

    [self removeAllDirectories];
    [self addDirectoriesFromDictionaryWithRelativePaths:directoriesWithLocalKeys];
    self.rootDirectory = [self resourceDirectoryForPath:[ResourceManagerUtil projectPathFromRelativePath:rootDirectoryWithLocalPath]];
    self.rootResourceDirectory = [self resourceDirectoryForPath:[ResourceManagerUtil projectPathFromRelativePath:localRootResourceDirectory]];
    [self save];
    
    return YES;
}

- (NSDictionary *)removeAllNilPathDirectories:(NSMutableDictionary *)directoriesWithLocalKeys {
    for (NSString *key in directoriesWithLocalKeys.allKeys) {
        PCResourceDirectory *resourceDirectory = directoriesWithLocalKeys[key];
        if (resourceDirectory.loadedWithNilPath) {
            [directoriesWithLocalKeys removeObjectForKey:key];
        }
    }
    return directoriesWithLocalKeys;
}

- (BOOL)reloadForProject:(PCProjectSettings *)projectSettings {
    NSString *projectResourcesSavePath = [projectSettings.projectDirectory stringByAppendingPathComponent:PCResourceConfigFileName];
    NSDictionary *resourcesDictionaryRaw = [NSKeyedUnarchiver unarchiveObjectWithFile:projectResourcesSavePath];
    NSDictionary *resourcesDictionary = [PCResourceManager migrateResourceDictionaryFrom:resourcesDictionaryRaw];
    return [self loadFromLocalDirectories:resourcesDictionary[PCDirectoriesKey] localRootDirectory:resourcesDictionary[PCRootDirectoryKey] localRootResourceDirectory:resourcesDictionary[PCRootResourceDirectoryKey]];
}

/**
 With an array of PCResourceDirectory, validate that the directories and files exists
 @param pcResourceDirectories array of resources directories
 @return whether the directory and files exists
 */
- (BOOL)validateResourceDirectoriesExist:(NSArray *)pcResourceDirectories {
    for (PCResourceDirectory *directory in pcResourceDirectories) {
        if (!directory.directoryReferenceURL || ![[NSFileManager defaultManager] fileExistsAtPath:[directory directoryPath]])
            return NO;
		for (PCResource *resource in directory.resources) {
			// skip the checking for resources type that may not have file urls
			if (resource.type == PCResourceTypeDirectory ||
			    resource.type == PCResourceTypeNone ||
			    resource.type == PCResourceTypeBMFont)
				continue;
			if (!resource.fileReferenceURL || ![[NSFileManager defaultManager] fileExistsAtPath:[resource filePath]])
				return NO;
		}
	}
	return YES;
}

#pragma mark - Batching changes

- (void)beginChangeBatch {
    self.batchOperationCount++;
}

- (void)endChangeBatch {
    NSAssert(self.batchOperationCount > 0, @"Cannot end change batch if no change batch in progress");
    self.batchOperationCount--;
    if (0 == self.batchOperationCount ) {
        [self save];
    }
}

#pragma mark - Directories

- (NSDictionary *)directoriesWithRelativePaths {
    NSDictionary *relativeDirectories = Underscore.array(self.directories).reduce([NSMutableDictionary dictionary], ^(NSMutableDictionary *memo, PCResourceDirectory *directory){
        NSString *relativeDirectoryPath = [ResourceManagerUtil relativePathFromPathInProject:directory.directoryPath];

        // This shouldn't normally occur, but if there's a resource directory here that shouldn't be (erroneously added?) we need to skip it
        if (relativeDirectoryPath) {
            memo[relativeDirectoryPath] = directory;
        }
        return memo;
    });
    return relativeDirectories;
}

- (void)addDirectoriesFromDictionaryWithRelativePaths:(NSDictionary *)dictionaryWithRelativePaths {
    for (NSString *relativePathKey in dictionaryWithRelativePaths) {
        [self.directories addObject:dictionaryWithRelativePaths[relativePathKey]];
    }
}

- (PCResource *)addDirectoryNamed:(NSString *)directoryName toDirectory:(PCResourceDirectory *)resourceDirectory addingSuffixOnNameCollision:(BOOL)addSuffixOnNameCollision error:(NSError **)error {
    NSAssert(resourceDirectory, @"This method assumes that the directory is being added to an existing directory, not creating a root directory.");

    NSString *fullDirectoryPath = [resourceDirectory.directoryPath stringByAppendingPathComponent:directoryName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullDirectoryPath]) {
        if (!addSuffixOnNameCollision) {
            if (error) {
                *error = [NSError pc_createDirectoryNameCollisionError];
            }
            return nil;
        }
        fullDirectoryPath = [PCResourceManager appendNumberToExistingFileName:[resourceDirectory.directoryPath stringByAppendingPathComponent:directoryName]];
    }

    NSError *createDirectoryError;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:fullDirectoryPath withIntermediateDirectories:NO attributes:nil error:&createDirectoryError];
    if (!success) {
        if (error) {
            *error = createDirectoryError;
        }
        return nil;
    }

    PCResource *result = [self addResourceWithAbsoluteFilePath:fullDirectoryPath inDirectory:resourceDirectory];
    [self resourceListChanged];
    return result;
}

- (void)removeDirectory:(PCResourceDirectory *)directory {
    if (!directory) return;

    // Remove sub directories
    NSArray *resources = directory.resources;
    for (PCResource *resource in resources) {
        if (resource.type == PCResourceTypeDirectory) {
            [self removeDirectory:(PCResourceDirectory *)resource.data];
        }
    }

    [self.directories removeObject:directory];
}

- (void)removeAllDirectories {
    [self.directories removeAllObjects];
    [self resourceListChanged];
}

#pragma mark - Resolutions

- (NSArray *)resolutionSpecificSuffixes {
    return @[@"@2x", @"-phone", @"-tablet", @"-tablethd", @"-phonehd", @"-html5", @""];
}

- (NSArray *)resolutionSpecificDirectories {
    return @[@""];
}

- (BOOL)isResolutionDependentFile:(NSString *)file {
    if ([[file pathExtension] isEqualToString:@"ccb"]) return NO;

    NSString *fileNoExt = [file stringByDeletingPathExtension];

    NSArray *resolutionSpecificSuffixes = [self resolutionSpecificSuffixes];

    for (NSString *ext in resolutionSpecificSuffixes) {
        if ([fileNoExt hasSuffix:ext]) return YES;
    }

    __block BOOL regexMatch = NO;
    [[NSString pc_resolutionDependentStringRegex] enumerateMatchesInString:fileNoExt options:NSMatchingReportCompletion range:NSMakeRange(0, fileNoExt.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        regexMatch = YES;
    }];

    return regexMatch;
}

- (PCResourceType)getResourceTypeForFile:(NSString *)file {
    NSString *ext = [[file pathExtension] lowercaseString];
    NSFileManager *fm = [NSFileManager defaultManager];

    BOOL isDirectory;
    [fm fileExistsAtPath:file isDirectory:&isDirectory];

    if (isDirectory) {
        // Bitmap fonts are directories, but with an extension
        if ([ext isEqualToString:@"bmfont"]) {
            return PCResourceTypeBMFont;
        }

        // Hide resolution directories
        if ([[self resolutionSpecificDirectories] containsObject:[file lastPathComponent]]) {
            return PCResourceTypeNone;
        }
        else {
            return PCResourceTypeDirectory;
        }
    }
    
    if ([ext isEqualToString:@"png"]
             || [ext isEqualToString:@"psd"]
             || [ext isEqualToString:@"jpg"]
             || [ext isEqualToString:@"jpeg"]
             || [ext isEqualToString:@"tga"]) {
        return PCResourceTypeImage;
    }
    else if ([ext isEqualToString:@"fnt"]) {
        return PCResourceTypeBMFont;
    }
    else if ([ext isEqualToString:@"ttf"]) {
        return PCResourceTypeTTF;
    }
    else if ([ext isEqualToString:@"ccb"]) {
        return PCResourceTypeCCBFile;
    }
    else if ([ext isEqualToString:@"js"]) {
        return PCResourceTypeJS;
    }
    else if ([ext isEqualToString:@"json"]) {
        return PCResourceTypeJSON;
    }
    else if ([ext isEqualToString:@"wav"]
            || [ext isEqualToString:@"mp3"]
            || [ext isEqualToString:@"m4a"]
            || [ext isEqualToString:@"caf"]) {
        return PCResourceTypeAudio;
    }
    else if ([ext isEqualToString:@"mp4"]
            || [ext isEqualToString:@"mov"]) {
        return PCResourceTypeVideo;
    }
    else if ([ext isEqualToString:@"dae"]) {
        return PCResourceType3DModel;
    }
    else if ([ext isEqualToString:@"ccbspritesheet"]) {
        return PCResourceTypeGeneratedSpriteSheetDef;
    }
    return PCResourceTypeNone;
}

#pragma mark - Resource Management

- (PCResource *)addResourceWithAbsoluteFilePath:(NSString *)file {
    return [self addResourceWithAbsoluteFilePath:file inDirectory:[self resourceDirectoryForPath:[file stringByDeletingLastPathComponent]]];
}

- (PCResource *)addResourceWithAbsoluteFilePath:(NSString *)file inDirectory:(PCResourceDirectory *)directory {
    PCResource *resource = [[PCResource alloc] init];
    resource.type = [[PCResourceManager sharedManager] getResourceTypeForFile:file];
    // Check if it is a directory
    if (resource.type == PCResourceTypeDirectory) {
        resource.data = [self addDirectory:file];
    }
    resource.filePath = file;
    [directory addResource:resource];

    // Load basic resource data if neccessary
    [resource loadData:^{
        [self save];
    }];

    return resource;
}

- (void)addResourcesForFilesInDirectory:(NSString *)absoluteDirectoryPath {
    void(^doWork)(void) = ^{
        NSError *error;
        NSArray *allResources = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absoluteDirectoryPath error:&error];
        if (error) {
            NSLog(@"Could not add resources - unable to find resources");
            return;
        }

        for (NSString *fileName in allResources) {
            if ([fileName isEqualToString:PCMacArchiveMetadataFolder]) continue;
            NSString *absoluteFilePath = [absoluteDirectoryPath stringByAppendingPathComponent:fileName];
            PCResource *resource = [self addResourceWithAbsoluteFilePath:absoluteFilePath];
            if (resource.type == PCResourceTypeDirectory) {
                [self addResourcesForFilesInDirectory:resource.filePath];
            }
        }
    };

    [self beginChangeBatch];
    doWork();
    [self endChangeBatch];
}

- (PCResourceDirectory *)addDirectory:(NSString *)directoryPath {
    PCResourceDirectory *existingDirectory = [self resourceDirectoryForPath:directoryPath];
    if (existingDirectory) {
        return nil;
    }

    PCResourceDirectory *directory = [[PCResourceDirectory alloc] init];
    directory.directoryReferenceURL = [[NSURL fileURLWithPath:directoryPath isDirectory:YES] fileReferenceURL];
    [self.directories addObject:directory];
    return directory;
}

- (PCResource *)importResourceAtAbsolutePath:(NSString *)absolutePath intoDirectoryAtAbsolutePath:(NSString *)destinationDirectory appendSuffixIfFileExists:(BOOL)appendSuffix {
    __block PCResource *resource;
    [self importFile:absolutePath intoDir:destinationDirectory appendSuffixIfFileExists:appendSuffix fileImportCallback:^(BOOL importSuccess, NSString *resultantFilePath) {
        if (!resource) {
            resource = importSuccess ? [self addResourceWithAbsoluteFilePath:resultantFilePath] : [self resourceForPath:resultantFilePath];
        }
    }];
    [self resourceListChanged];
    return resource;
}

- (BOOL)importResourcesAtAbsolutePaths:(NSArray *)absolutePaths intoDirectoryAtAbsolutePath:(NSString *)destinationDirectory appendSuffixIfFileExists:(BOOL)appendSuffix {
    __block BOOL importedFile = NO;

    for (NSString *sourceFilePath in absolutePaths) {
        [self importFile:sourceFilePath intoDir:destinationDirectory appendSuffixIfFileExists:appendSuffix fileImportCallback:^(BOOL importSuccess, NSString *resourceFilePath) {
            if (importSuccess) {
                [self addResourceWithAbsoluteFilePath:resourceFilePath];
                importedFile = YES;
            }
        }];
    }

    if (importedFile) {
        [self resourceListChanged];
    }

    return importedFile;
}

- (BOOL)moveFilesForImageAtPath:(NSString *)sourcePath toDirectory:(NSString *)destinationDirectory {
    // Move all resolutions
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [sourcePath lastPathComponent];
    for (NSString *resolutionDirectory in [self resolutionSpecificDirectories]) {
        NSString *sourceDirectory = [sourcePath stringByDeletingLastPathComponent];
        NSString *sourceResolutionDirectory = [sourceDirectory stringByAppendingPathComponent:resolutionDirectory];
        NSString *sourceResolutionFile = [sourceResolutionDirectory stringByAppendingPathComponent:fileName];

        if (![fileManager fileExistsAtPath:sourceResolutionFile]) continue;

        // Create dir if it's not existing already
        NSString *destinationResolutionDirectory = [destinationDirectory stringByAppendingPathComponent:resolutionDirectory];
        NSError *createDirectoryError;
        BOOL success = [fileManager createDirectoryAtPath:destinationResolutionDirectory withIntermediateDirectories:YES attributes:nil error:&createDirectoryError];
        if (!success && createDirectoryError) {
            PCLog(@"Error creating directory (%@): %@", destinationResolutionDirectory, createDirectoryError);
            // If it's not possible to create the destination directory then return early
            return NO;
        }

        // Move the file
        NSString *destinationResolutionFile = [destinationResolutionDirectory stringByAppendingPathComponent:fileName];
        NSError *moveError;
        success = [fileManager moveItemAtPath:sourceResolutionFile toPath:destinationResolutionFile error:&moveError];
        if (!success && moveError) {
            PCLog(@"Error moving file (%@): %@", sourceResolutionFile, moveError);
            // If it's not possible to move the file then return early
            return NO;
        }
    }
    return YES;
}

- (BOOL)moveFilesForResourceAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Move regular resources
    NSError *moveError;
    BOOL success = [fileManager moveItemAtPath:sourcePath toPath:destinationPath error:&moveError];
    if (!success && moveError) {
        PCLog(@"Error moving file (%@): %@", sourcePath, moveError);
        // If it's not possible to move the file then return early
        return NO;
    }

    // Also attempt to move preview image (if any)
    NSString *sourcePathPreview = [sourcePath stringByAppendingPathExtension:@"ppng"];
    if ([fileManager fileExistsAtPath:sourcePath]) {
        NSString *destinationPathPreview = [destinationPath stringByAppendingPathExtension:@"ppng"];
        success = [fileManager moveItemAtPath:sourcePathPreview toPath:destinationPathPreview error:&moveError];
        if (!success && moveError) {
            PCLog(@"Error moving file (%@): %@", sourcePathPreview, moveError);
            // If it's not possible to move the file then return early
            return NO;
        }
    }
    return YES;
}

- (BOOL)moveResourceFile:(NSString *)sourcePath ofType:(PCResourceType)type toDirectory:(NSString *)destinationDirectory {
    if (PCIsEmpty(destinationDirectory)) return NO;

    NSString *fileName = [sourcePath lastPathComponent];
    NSString *destinationPath = [destinationDirectory stringByAppendingPathComponent:fileName];
    if (type == PCResourceTypeImage) {
        if (![self moveFilesForImageAtPath:sourcePath toDirectory:destinationDirectory]) {
            return NO;
        }
    } else {
        if (![self moveFilesForResourceAtPath:sourcePath toPath:destinationPath]) {
            return NO;
        }
    }

    // Make sure the project is updated
    NSString *relativeSourcePath = [ResourceManagerUtil relativePathFromAbsolutePath:sourcePath];
    NSString *relativeDestinationPath = [ResourceManagerUtil relativePathFromAbsolutePath:destinationPath];

    [[AppDelegate appDelegate].currentProjectSettings movedResourceFrom:relativeSourcePath to:relativeDestinationPath];
    [[AppDelegate appDelegate] renamedDocumentPathFrom:sourcePath to:destinationPath];

    // Find the resource using the destination path since it's already been moved in the filesystem
    PCResource *resource = [self resourceForPath:destinationPath];
    [resource updateFromDirectoryAtPath:[sourcePath stringByDeletingLastPathComponent] toDirectoryAtPath:destinationDirectory];

    [self resourceListChanged];
    return YES;
}

- (void)renameResourceFile:(NSString *)sourcePath toNewName:(NSString *)newName {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *destinationPath = [[sourcePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    enum PCResourceType type = [self getResourceTypeForFile:sourcePath];

    if (type == PCResourceTypeImage) {
        // Rename all resolutions
        NSString *sourceDirectory = [sourcePath stringByDeletingLastPathComponent];
        NSString *oldName = [sourcePath lastPathComponent];

        for (NSString *resourceDirectory in [self resolutionSpecificDirectories]) {
            NSString *sourceResourcePath = [[sourceDirectory stringByAppendingPathComponent:resourceDirectory] stringByAppendingPathComponent:oldName];
            NSString *destinatinoResourcePath = [[sourceDirectory stringByAppendingPathComponent:resourceDirectory] stringByAppendingPathComponent:newName];

            // Move the file
            NSError *moveError;
            BOOL success = [fileManager moveItemAtPath:sourceResourcePath toPath:destinatinoResourcePath error:&moveError];
            if (!success && moveError) {
                PCLog(@"Error moving item (%@): %@", sourceResourcePath, moveError);
                // Not returning early so the resources still get updated
            }
        }
    }
    else {
        NSError *moveError;
        BOOL success = [fileManager moveItemAtPath:sourcePath toPath:destinationPath error:&moveError];
        if (!success && moveError) {
            PCLog(@"Error moving file (%@): %@", sourcePath, moveError);
            // Not returning early so the resources still get updated
        }

        // Also attempt to move preview image (if any)
        NSString *previewSourcePath = [sourcePath stringByAppendingPathExtension:@"ppng"];
        NSString *previewDestinationPath = [destinationPath stringByAppendingPathExtension:@"ppng"];
        if ([fileManager fileExistsAtPath:previewSourcePath]) {
            success = [fileManager moveItemAtPath:previewSourcePath toPath:previewDestinationPath error:&moveError];
            if (!success && moveError) {
                PCLog(@"Error moving file (%@): %@", previewSourcePath, moveError);
                // Not returning early so the resources still get updated
            }
        }
    }

    // Make sure the project is updated
    NSString *relativeSourcePath = [ResourceManagerUtil relativePathFromAbsolutePath:sourcePath];
    NSString *relativeDestinationPath = [ResourceManagerUtil relativePathFromAbsolutePath:destinationPath];

    [[AppDelegate appDelegate].currentProjectSettings movedResourceFrom:relativeSourcePath to:relativeDestinationPath];
    [[AppDelegate appDelegate] renamedDocumentPathFrom:sourcePath to:destinationPath];

    [self resourceListChanged];
}

- (void)removeResource:(PCResource *)resource {
    NSString *relativePath = resource.relativePath;
    if (PCIsEmpty(relativePath)) return;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directoryPath = [resource.filePath stringByDeletingLastPathComponent];
    NSString *fileName = [resource.filePath lastPathComponent];

    // Do this before actually removing the resource in the filesystem so the path is still valid
    [[AppDelegate appDelegate].currentProjectSettings removedResourceAt:relativePath];

    // Do this before actually deleting the file so that if the process is interrupted, we are left with an orphaned file in the project vs. a project that will never open again
    PCResourceDirectory *directory = [self resourceDirectoryForPath:directoryPath];
    [directory removeResource:resource];
    if (resource.type == PCResourceTypeDirectory) {
        [self removeDirectory:(PCResourceDirectory *)resource.data];
    }
    [self resourceListChanged];

    if (resource.type == PCResourceTypeImage) {
        // Remove all resolutions
        NSArray *resolutions = [self resolutionSpecificDirectories];
        for (NSString *resolution in resolutions) {
            NSString *filePath = [[directoryPath stringByAppendingPathComponent:resolution] stringByAppendingPathComponent:fileName];
            NSError *removeError;
            BOOL success = [fileManager removeItemAtPath:filePath error:&removeError];
            if (!success && removeError) {
                PCLog(@"Error removing file (%@): %@", filePath, removeError);
                // Not returning early so the resources still get updated
            }
        }
    } else {
        // Just remove the file
        NSError *removeError;
        BOOL success = [fileManager removeItemAtPath:resource.filePath error:&removeError];
        if (!success && removeError) {
            PCLog(@"Error removing file (%@): %@", resource.filePath, removeError);
            // Not returning early so the resources still get updated
        }

        // Also attempt to remove preview image (if any)
        NSString *filePathPreview = [resource.filePath stringByAppendingPathExtension:@"ppng"];
        if ([fileManager fileExistsAtPath:filePathPreview]) {
            success = [fileManager removeItemAtPath:filePathPreview error:&removeError];
            if (!success && removeError) {
                PCLog(@"Error removing file (%@): %@", resource.filePath, removeError);
                // Not returning early so the resources still get updated
            }
        }
    }
}

- (void)touchResource:(PCResource *)res {
    if (res.type == PCResourceTypeImage) {
        for (NSString *resDir in [self resolutionSpecificDirectories]) {
            NSString *fileName = [res.filePath lastPathComponent];
            NSString *resPath = [[[res.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:resDir] stringByAppendingPathComponent:fileName];

            [CCBFileUtil setModificationDate:[NSDate date] forFile:resPath];
        }
    }
    else {
        [CCBFileUtil setModificationDate:[NSDate date] forFile:res.filePath];
    }
}


#pragma mark - Resource Observers

- (void)addResourceObserver:(id)observer {
    [resourceObserver addObject:observer];
}

- (void)removeResourceObserver:(id)observer {
    [resourceObserver removeObject:observer];
}

- (void)notifyResourceObserversResourceListUpdated {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id observer in resourceObserver) {
            if ([observer respondsToSelector:@selector(resourceListUpdated)]) {
                [observer performSelector:@selector(resourceListUpdated)];
            }
        }
    });
}

#pragma mark - Finding Resources

- (PCResource *)resourceForPath:(NSString *)path inDir:(PCResourceDirectory *)dir {
    for (PCResource *res in dir.any) {
        if ([res.filePath isEqualToString:path]) {
            return res;
        }

        if (res.type == PCResourceTypeDirectory) {
            PCResourceDirectory *subDir = res.data;
            PCResource *found = [self resourceForPath:path inDir:subDir];
            if (found) {
                return found;
            }
        }
    }
    return nil;
}

- (PCResource *)resourceForPath:(NSString *)path {
    return [self resourceForPath:path inDir:self.rootDirectory];
}

- (PCResource *)resourceWithUUID:(NSString *)uuid {
    for (PCResourceDirectory *directory in self.directories) {
        for (PCResource *resource in directory.resources) {
            if ([resource.uuid isEqualToString:uuid]) {
                return resource;
            }
        }
    }
    return nil;
}

- (NSMutableArray *)allResources {
    NSMutableArray *allResources = [NSMutableArray array];
    if (!self.rootDirectory) return allResources;

    for (PCResourceDirectory *directory in self.directories) {
        [allResources addObjectsFromArray:directory.any];
    }
    return allResources;
}

#pragma mark - Helper methods

+ (CGFloat)destinationScaleFromResolution:(NSString *)resolution {
    if ([resolution isEqualToString:@"phone"]) return 1;
    if ([resolution isEqualToString:@"phonehd"]) return 2;
    if ([resolution isEqualToString:@"phone3x"]) return 3;
    if ([resolution isEqualToString:@"tablet"]) return 1;
    if ([resolution isEqualToString:@"tablethd"]) return 2;
    return 1;
}

+ (NSString *)imageSuffixFromResolution:(NSString *)resolution {
    NSString *scaleExtension = @"";
    if ([PCResourceManager destinationScaleFromResolution:resolution] == 2) {
        scaleExtension = @"@2x";
    }
    else if ([PCResourceManager destinationScaleFromResolution:resolution] == 3) {
        scaleExtension = @"@3x";
    }
    return scaleExtension;
}

/**
 @discussion Used by the studio to find the resolution-specific image for a resource. Should not be used when generating file paths that are used by the player, as it does not use typical iOS naming conventions to determine the resolution of an image.
 */
+ (NSString *)studioImagePath:(NSString *)path withResolution:(NSString *)resolution {
    NSString *originalExtension = [path pathExtension];
    NSString *fileNameWithoutExtension = [[path pc_sdFilePath] stringByDeletingPathExtension];
    NSString *scaleExtension = [self imageSuffixFromResolution:resolution];
    return [[NSString stringWithFormat:@"%@%@", fileNameWithoutExtension, scaleExtension] stringByAppendingPathExtension:originalExtension];
}

+ (CGFloat)sourceScaleForResourceAtRelativePath:(NSString *)relativePath {
    NSInteger scaleSetting = [[[AppDelegate appDelegate].currentProjectSettings valueForRelPath:relativePath andKey:@"scaleFrom"] intValue];
    return scaleSetting ?: [AppDelegate appDelegate].currentProjectSettings.resourceAutoScaleFactor;
}

- (BOOL)createCachedImageFromAuto:(NSString *)autoFile saveAs:(NSString *)dstFile resolution:(NSString *)res studioUse:(BOOL)studioUse {
    NSString *relativePath = [ResourceManagerUtil relativePathFromAbsolutePath:autoFile];
    CGFloat sourceScale = [PCResourceManager sourceScaleForResourceAtRelativePath:relativePath];
    CGFloat destinationScale = [PCResourceManager destinationScaleFromResolution:res];
    CGFloat scaleFactor = destinationScale / sourceScale;

    // Load src image
    CGImageSourceRef sourceImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef) [NSURL fileURLWithPath:autoFile], NULL);
    CGImageRef sourceImage = CGImageSourceCreateImageAtIndex(sourceImageSource, 0, NULL);
    CFRelease(sourceImageSource);

    NSDate *modifiedTime = [CCBFileUtil modificationDateForFile:autoFile];
    NSString *resolutionDstFile = studioUse ? [PCResourceManager studioImagePath:dstFile withResolution:res] : dstFile;
    BOOL success = [self saveImageFromImage:sourceImage scaleFactor:scaleFactor toFile:resolutionDstFile modificationDate:modifiedTime];

    // Create a Retina image if this image is not retina, so it looks good on our MacBooks :)
    // But only if we are creating cached images for use in studio
    if (success && studioUse && scaleFactor < 2) {
        NSString *retinaImagePath = [PCResourceManager studioImagePath:dstFile withResolution:@"tablethd"];
        success = [self saveImageFromImage:sourceImage scaleFactor:2 / sourceScale toFile:retinaImagePath modificationDate:modifiedTime];
    }

    CGImageRelease(sourceImage);
    return success;
}

- (BOOL)saveImageFromImage:(CGImageRef)sourceImage scaleFactor:(CGFloat)scaleFactor toFile:(NSString *)destinationPath modificationDate:(NSDate *)modifiedDate {
    CGSize destinationSize = CGSizeMake(MAX(1, round(CGImageGetWidth(sourceImage) * scaleFactor)),
                                        MAX(1, round(CGImageGetHeight(sourceImage) * scaleFactor)));

    // Since it crashes on CMYK colour space, we will have just use RGB for everything

    // Create new, scaled image
    CGContextRef newContext = CGBitmapContextCreate(NULL, destinationSize.width, destinationSize.height, 8, destinationSize.width * 32, CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
    NSAssert(newContext != nil, @"CG draw context is nil");

    // Enable anti-aliasing
    CGContextSetInterpolationQuality(newContext, kCGInterpolationHigh);
    CGContextSetShouldAntialias(newContext, TRUE);

    CGContextDrawImage(newContext, CGContextGetClipBoundingBox(newContext), sourceImage);
    CGImageRef imageDst = CGBitmapContextCreateImage(newContext);

    // Create destination directory
    NSError *createDirectoryError;
    NSString *directoryPath = [destinationPath stringByDeletingLastPathComponent];
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:NULL error:&createDirectoryError];
    if (!success) {
        PCLog(@"Error creating directory (%@) %@", directoryPath, createDirectoryError);
        // If there was an error creating the destination directories we won't be able to save the file, so return early
        return NO;
    }

    // Save the image
    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:destinationPath];
    CFStringRef out_type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) ([destinationPath pathExtension]), NULL);
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, out_type, 1, NULL);
    CGImageDestinationAddImage(destination, imageDst, nil);
    success = CGImageDestinationFinalize(destination);

    // Release created objects
    CFRelease(destination);
    CGImageRelease(imageDst);
    CFRelease(newContext);

    if (success) {
        // Update modification time to match original file
        [CCBFileUtil setModificationDate:modifiedDate forFile:destinationPath];
    }
    else {
        PCLog(@"Failed to write image to %@", destinationPath);
    }

    return success;
}

- (NSString *)resourceCacheResolutionExtensionFromDeviceTarget:(PCDeviceTargetType)target {
    switch (target) {
        case PCDeviceTargetTypePhone:
            return @"phone";
        
        case PCDeviceTargetTypeTablet:
        default:
            return @"tablet";
    }
}

- (NSString *)toAbsolutePath:(NSString *)relativePath {
    if (!self.rootDirectory) return nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    PCProjectSettings *projectSettings = appDelegate.currentProjectSettings;
    
    if (!appDelegate.currentDocument) {
        // First try the default
        NSString *path = [NSString stringWithFormat:@"%@/%@", self.rootDirectory.directoryPath, relativePath];
        if ([fileManager fileExistsAtPath:path]) {
            NSString *extension = [path pathExtension];
            // use the cached directory
            if ([extension pc_isImageFileExtension]) {
                NSString *projectResolutionSetting = [self resourceCacheResolutionExtensionFromDeviceTarget:projectSettings.deviceResolutionSettings.deviceTarget];
                return [self cachedAutoFilePathFromRelativePath:relativePath resolution:projectResolutionSetting];
            } else {
                return path;
            }
        }

        // Then try all resolution dependent directories
        NSString *fileName = [path lastPathComponent];
        NSString *dirName = [path stringByDeletingLastPathComponent];

        for (NSString *resDir in [self resolutionSpecificDirectories]) {
            NSString *path = [[dirName stringByAppendingPathComponent:resDir] stringByAppendingPathComponent:fileName];
            if ([fileManager fileExistsAtPath:path]) return path;
        }
    }
    else {
        // Select by resolution definied by open document
        NSArray *resolutions = appDelegate.currentDocument.resolutions;
        if (!resolutions) return nil;

        PCDeviceResolutionSettings *resolutionSettings = resolutions[appDelegate.currentDocument.currentResolution];

        NSString *defaultFile = [NSString stringWithFormat:@"%@/%@", self.rootDirectory.directoryPath, relativePath];

        NSString *defaultFileName = [defaultFile lastPathComponent];
        NSString *defaultDirName = [defaultFile stringByDeletingLastPathComponent];

        // Select by resolution
        for (__strong NSString *extension in resolutionSettings.exts) {
            if ([extension isEqualToString:@""]) continue;
            extension = [@"resources-" stringByAppendingString:extension];

            NSString *pathForRes = [[defaultDirName stringByAppendingPathComponent:extension] stringByAppendingPathComponent:defaultFileName];

            if ([fileManager fileExistsAtPath:pathForRes]) return pathForRes;
        }

        // Auto convert!

        NSString *extension = [defaultFileName pathExtension];
        if ([extension pc_isImageFileExtension]) {
            NSString *autoFile = [defaultDirName stringByAppendingPathComponent:defaultFileName];
            if ([fileManager fileExistsAtPath:autoFile]) {
                return [self cachedAutoFilePathFromRelativePath:relativePath resolution:resolutionSettings.exts.firstObject];
            }
        }

        // Fall back on default file
        if ([fileManager fileExistsAtPath:defaultFile]) return defaultFile;
    }
    return nil;
}

- (NSString *)cachedAutoFilePathFromRelativePath:(NSString *)relativePath resolution:(NSString *)resolution {
    NSString *cachedFile = [[AppDelegate appDelegate].currentProjectSettings.displayCacheDirectory stringByAppendingPathComponent:relativePath];
    if (PCIsEmpty(resolution)) return cachedFile;

    NSString *cachedFileName = [cachedFile lastPathComponent];
    NSString *cachedDirName = [cachedFile stringByDeletingLastPathComponent];
    return [[cachedDirName stringByAppendingPathComponent:resolution] stringByAppendingPathComponent:cachedFileName];
}

- (void)resourceListChanged {
    [self notifyResourceObserversResourceListUpdated];
    [self save];
}

- (void)closeProject {
    [self.directories removeAllObjects];
    self.rootDirectory = nil;
    self.rootResourceDirectory = nil;
}

#pragma mark - File Management

- (BOOL)importDaeFiles:(NSArray *)files outResultFilePath:(NSString **)outResultFilePath {

    if (![files pc_containsFileWithExtension:@"dae"]) {
        return NO;
    }

    NSArray *absoluteResourcePaths = [AppDelegate appDelegate].currentProjectSettings.absoluteResourcePaths;
    NSString *resourcesPath = [NSString stringWithFormat:@"%@/resources/", absoluteResourcePaths[0]];
    NSString *daeFilePath = nil;

    // Copy all the other files (assuming they are texture images) except the dae to the resources directory
    // We don't need the exact path as scene kit will look for them as long as they are in the same dir
    for (NSString *filepath in files) {
        NSString *fileType = [filepath pathExtension];
        if (![fileType isEqualToString:@"dae"]){
            NSError *copyError;
            NSString *distPath = [resourcesPath stringByAppendingString:[filepath lastPathComponent]];
            // Don't use default PCResourceManager implementation because it will skip the other image formats (tga, tiff etc)
            BOOL success = [[NSFileManager defaultManager] copyItemAtPath:filepath toPath:distPath error:&copyError];
            [self addResourceWithAbsoluteFilePath:distPath];
            if (!success && copyError) {
                PCLog(@"Error copying file (%@): %@", resourcesPath, copyError);
            }
        }
        else {
            //save the path of the dae file for use later
            daeFilePath = filepath;
        }
    }

    PCResource *resultantResource = [[PCResourceManager sharedManager] importResourceAtAbsolutePath:daeFilePath intoDirectoryAtAbsolutePath:resourcesPath appendSuffixIfFileExists:YES];

    // If we can parse the file (ie. it is in XML and therefore regular DAE file, not scntool DAE)
    // search for and copy over the texture images of the 3D model
    if ([daeFilePath pc_isFilePathToXmlFile]) {
        NSArray *texturePaths = [NSString pc_fetchTextureImagePathsFor3DModelAt:daeFilePath];

        for (NSString *texturePath in texturePaths){
            // Get the full file path
            NSString *textureFullPath = [NSString stringWithFormat:@"%@/%@", [daeFilePath stringByDeletingLastPathComponent], texturePath];
            NSError *copyError;
            NSString *distPath = [resourcesPath stringByAppendingString:[textureFullPath lastPathComponent]];

            // Don't use PCResourceManager because it will skip the other image formats (tga, tiff etc)
            BOOL success = [[NSFileManager defaultManager] copyItemAtPath:textureFullPath toPath:distPath error:&copyError];
            if (!success && copyError) {
                PCLog(@"Error copying file (%@): %@", resourcesPath, copyError);
            }
        }
    }

    *outResultFilePath = [NSString stringWithFormat:@"resources/%@", [resultantResource.filePath lastPathComponent]];
    return YES;
}

- (void)importFile:(NSString *)file intoDir:(NSString *)dstDir appendSuffixIfFileExists:(BOOL)appendSuffixIfFileExists fileImportCallback:(void(^)(BOOL importSuccess, NSString *filePath))fileImportCallback {

    NSFileManager *fm = [NSFileManager defaultManager];

    BOOL isDir = NO;
    if ([fm fileExistsAtPath:file isDirectory:&isDir] && isDir) {
        NSString *ext = [[file pathExtension] lowercaseString];

        if ([ext isEqualToString:@"bmfont"]) {
            // Handle bitmap fonts

            NSString *dstPath = [dstDir stringByAppendingPathComponent:[file lastPathComponent]];
            NSError *copyError;
            BOOL success = [fm copyItemAtPath:file toPath:dstPath error:&copyError];
            if (!success && copyError) {
                PCLog(@"Error copying file (%@): %@", file, copyError);
            }
            if (fileImportCallback) {
                fileImportCallback(success, dstPath);
            }
        }
        else {
            // Handle regular directory
            NSString *dirName = [file lastPathComponent];
            NSString *dstDirNew = [dstDir stringByAppendingPathComponent:dirName];

            if ([fm fileExistsAtPath:dstDirNew]) {
                dstDirNew = [PCResourceManager appendNumberToExistingFileName:dstDirNew];
            }

            // Create if not created
            NSError *createDirectoryError;
            BOOL success = [fm createDirectoryAtPath:dstDirNew withIntermediateDirectories:YES attributes:NULL error:&createDirectoryError];
            if (!success && createDirectoryError) {
                PCLog(@"Error creating directory (%@): %@", dstDirNew, createDirectoryError);
                // If it's not possible to create the destination directory, return early
                if(fileImportCallback) {
                    fileImportCallback(NO, dstDirNew);
                }
                return;
            }

            NSError *contentsOfDirectoryError;
            NSArray *dirFiles = [fm contentsOfDirectoryAtPath:file error:&contentsOfDirectoryError];
            if (!dirFiles && contentsOfDirectoryError) {
                PCLog(@"Error getting contents of directory (%@): %@", file, contentsOfDirectoryError);
                // If it's not possible to get the contents of the directory to copy, return early
                if(fileImportCallback) {
                    fileImportCallback(NO, dstDirNew);
                }
                return;
            }

            if (fileImportCallback) {
                fileImportCallback(YES, dstDirNew);
            }

            for (NSString *fileName in dirFiles) {
                [self importFile:[file stringByAppendingPathComponent:fileName] intoDir:dstDirNew appendSuffixIfFileExists:appendSuffixIfFileExists fileImportCallback:fileImportCallback];
            }
        }
    }
    else {
        // Handle regular file
        NSError *typeOfFileError;
        NSString *fileType = [[NSWorkspace sharedWorkspace] typeOfFile:file error:&typeOfFileError];
        if (!fileType && typeOfFileError) {
            PCLog(@"Error getting file UTI (%@): %@", file, typeOfFileError);
            // If it's not possible to get the filetype we won't know what to do with it (i.e. there's not importing for arbitrary files) so return early
            if (fileImportCallback) {
                fileImportCallback(NO, nil);
            }
            return;
        }
        NSString *ext = [file pathExtension];
        if ([fileType isEqualToString:(__bridge NSString *) kUTTypePNG] || [fileType isEqualToString:(__bridge NSString *) kUTTypeJPEG] || [ext isEqualToString:(__bridge NSString *) kUTTypeJPEG2000]) {
            // Handle image import

            // Copy to destination folder
            NSError *createDirectoryError;
            BOOL success = [fm createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:nil error:&createDirectoryError];
            if (!success && createDirectoryError) {
                PCLog(@"Error creating directory (%@): %@", dstDir, createDirectoryError);
                // If there was an error creating the destination folder then return early
                if (fileImportCallback) {
                    fileImportCallback(NO, nil);
                }
                return;
            }

            NSString *imgFileName = [dstDir stringByAppendingPathComponent:[file lastPathComponent]];

            if ([self isResolutionDependentFile:imgFileName]) {
                imgFileName = [NSString pc_trimFileNameResolutionDependencySuffix:imgFileName];
                if ([fm fileExistsAtPath:imgFileName]) {
                    imgFileName = [PCResourceManager appendNumberToExistingFileName:imgFileName];
                }
            } else if ([fm fileExistsAtPath:imgFileName]) {
                NSImage *originalImage = [[NSImage alloc] initWithContentsOfFile:imgFileName];
                NSImage *newImage = [[NSImage alloc] initWithContentsOfFile:file];
                if (![[originalImage PNGRepresentation] isEqualToData:[newImage PNGRepresentation]]) {
                    if (appendSuffixIfFileExists) {
                        imgFileName = [PCResourceManager appendNumberToExistingFileName:imgFileName];
                    } else {
                        // Confirm remove of items
                        NSAlert *alert = [NSAlert alertWithMessageText:@"Are you sure you want to replace this Image?" defaultButton:@"Stop" alternateButton:@"Keep Both" otherButton:@"Replace" informativeTextWithFormat:@"You cannot undo this operation."];
                        NSInteger result = [alert runModal];
                        if (result == NSAlertAlternateReturn) {
                            imgFileName = [PCResourceManager appendNumberToExistingFileName:imgFileName];
                        } else if (result == NSAlertDefaultReturn) {
                            if (fileImportCallback) {
                                fileImportCallback(NO, imgFileName);
                            }
                            return;
                        } else {
                            NSError *removeItemError;
                            BOOL removeSuccess = [fm removeItemAtPath:imgFileName error:&removeItemError];
                            if (!removeSuccess && removeItemError) {
                                PCLog(@"Error removing item (%@): %@", imgFileName, removeItemError);
                                // If we can't replace the file then just return early
                                if (fileImportCallback) {
                                    fileImportCallback(NO, imgFileName);
                                }
                                return;
                            }
                        }
                    }
                }
            }

            NSError *copyError;
            BOOL importedFile = [fm copyItemAtPath:file toPath:imgFileName error:&copyError];
            if (!importedFile && copyError) {
                PCLog(@"Error copying file (%@): %@", file, copyError);
            }

            if (fileImportCallback) {
                fileImportCallback(importedFile, imgFileName);
            }
        }
        else if ([ext isEqualToString:@"wav"]) {
            // Copy the sound
            NSString *dstPath = [dstDir stringByAppendingPathComponent:[file lastPathComponent]];
            NSError *copyError;
            BOOL importedFile = [fm copyItemAtPath:file toPath:dstPath error:&copyError];
            if (!importedFile && copyError) {
                PCLog(@"Error copying file (%@): %@", file, copyError);
            }

            if (fileImportCallback) {
                fileImportCallback(importedFile, dstPath);
            }
            if (!importedFile) return;

            // Code should check the wav file to see if it is longer than 15 seconds and in that case use mp4 instead of caf
            NSTimeInterval duration = [[SoundFileImageController sharedInstance] getFileDuration:file];
            if (duration > 15) {
                // Set iOS format to mp4 for long sounds
                PCProjectSettings *settings = [AppDelegate appDelegate].currentProjectSettings;
                NSString *relPath = [ResourceManagerUtil relativePathFromAbsolutePath:dstPath];
                [settings setValue:@(kCCBPublishFormatSound_ios_mp4) forRelPath:relPath andKey:@"format_ios_sound"];
            }

        }
        else if ([fileType isEqualToString:(__bridge NSString *) kUTTypeQuickTimeMovie] || [fileType isEqualToString:(__bridge NSString *) kUTTypeMPEG4] || [[ext lowercaseString] isEqualToString:@"tga"]) {
            NSString *dstPath = [dstDir stringByAppendingPathComponent:[file lastPathComponent]];
            if ([fm fileExistsAtPath:dstPath]) {
                PCResource *resource = [self resourceForPath:dstPath];
                if (resource) {
                    if (fileImportCallback) {
                        fileImportCallback(NO, resource.absoluteFilePath);
                    }
                    return;
                } else {
                    dstPath = [PCResourceManager appendNumberToExistingFileName:dstPath];
                }
            }

            NSError *copyError;
            BOOL importedFile = [fm copyItemAtPath:file toPath:dstPath error:&copyError];
            if (!importedFile && copyError) {
                PCLog(@"Error copying file (%@): %@", file, copyError);
            }

            if (fileImportCallback) {
                fileImportCallback(importedFile, dstPath);
            }
        }
        else if ([fileType isEqualToString:(__bridge NSString *) kUTTypeTIFF] || [ext isEqualToString:@"dae"]) {
            // Import fonts or other files that should just be copied
            NSString *dstPath = [dstDir stringByAppendingPathComponent:[file lastPathComponent]];
            NSError *copyError;
            BOOL importedFile = [fm copyItemAtPath:file toPath:dstPath error:&copyError];
            if (!importedFile && copyError) {
                PCLog(@"Error copying file (%@): %@", file, copyError);
            }
            if (fileImportCallback) {
                fileImportCallback(importedFile, dstPath);
            }
        }
    }
}

+ (NSString *)appendNumberToExistingFileName:(NSString *)existingFilePath {
    NSString *filePathWithoutExtension = [existingFilePath stringByDeletingPathExtension];
    NSString *pathExtension = [existingFilePath pathExtension];
    NSString *fullDirectoryPath = nil;
    NSInteger folderIndex = 0;
    do {
        fullDirectoryPath = [NSString stringWithFormat:@"%@%ld.%@", filePathWithoutExtension, ++folderIndex, pathExtension];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:fullDirectoryPath]);
    return fullDirectoryPath;
}

+ (NSArray *)allowedMediaFileExtensions {
    NSArray *fileTypes = @[@"png",@"jpg",@"jpeg",@"wav",@"mov",@"mp4",@"dae"];
    NSMutableArray *results = [NSMutableArray arrayWithArray:fileTypes];
  
    // make sure to add the uppercase file type to the return list too
    for (NSString *fileType in fileTypes) {
        [results addObject:[fileType uppercaseString]];
    }
    
    return results;
}

#pragma mark - Resource usage

- (BOOL)isResourceBeingUsed:(PCResource *)resource {
    for (CCBDocument *document in [[AppDelegate appDelegate] currentProjectSettings].allDocuments) {
        PCDeviceResolutionSettings *resolution = document.resolutions[0];
        SKNode *rootNode = [CCBReaderInternal spriteKitNodeGraphFromDocumentDictionary:document.docData parentSize:CGSizeMake(resolution.width, resolution.height)];
        if ([self isNode:rootNode usingResource:resource]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNode:(SKNode *)node usingResource:(PCResource *)resource {
    if ([node isKindOfClass:[SKSpriteNode class]] && [[node extraPropForKey:@"spriteFrame"] isEqualToString:resource.uuid]) {
        return YES;
    }

    if ([node.children count] > 0) {
        BOOL used = NO;
        for (SKNode *child in node.children) {
            used |= [self isNode:child usingResource:resource];
        }
        return used;
    }
    return NO;
}

- (PCResourceDirectory *)resourceDirectoryForPath:(NSString *)path {
    return Underscore.find(self.directories, ^BOOL(PCResourceDirectory *directory){
        return [directory.directoryPath isEqualToString:path];
    });
}

#pragma mark - Template Setup

- (void)loadResourcesForParticleTemplates:(NSArray *)templates {
    NSString *particlesDirectoryPath = [self.rootResourceDirectory.directoryPath stringByAppendingPathComponent:@"Particles"];
    NSError *createParticlesResourceDirectoryError;
    [self addDirectoryNamed:@"Particles" toDirectory:self.rootResourceDirectory addingSuffixOnNameCollision:NO error:&createParticlesResourceDirectoryError];
    if (createParticlesResourceDirectoryError) {
        PCLog(@"Error creating directory for particle resources: %@", createParticlesResourceDirectoryError);
        return;
    }

    // We only want to import a particle spriteframe once
    // We keep track of the filenames and map it to the resource manager's UUID so we can use it more than once if needed
    NSMutableDictionary *filenameToUUIDMapping = [NSMutableDictionary dictionary];

    for (PCTemplate *template in templates) {
        // Import the template's resource and update the template so it points to the correct resource
        for (NSDictionary *setupProperties in template.projectSetupProperties) {
            if (![setupProperties[@"type"] isEqualToString:@"SpriteFrame"]) continue;

            NSString *propertyName = setupProperties[@"name"];
            // Here setupValue is the filename of the image to add as a resource
            NSString *filename = setupProperties[@"value"];

            // Import the resource only if it hasn't been yet
            NSString *resourceUUID = filenameToUUIDMapping[filename];
            if (!resourceUUID) {
                NSString *absoluteFilePath = [[PCTemplateLibrary templateDirectory] stringByAppendingPathComponent:filename];
                PCResource *addedResource = [self importResourceAtAbsolutePath:absoluteFilePath intoDirectoryAtAbsolutePath:particlesDirectoryPath appendSuffixIfFileExists:NO];
                resourceUUID = addedResource.uuid;
                NSError *removeTemplateResourceError;
                [[NSFileManager defaultManager] removeItemAtPath:absoluteFilePath error:&removeTemplateResourceError];
                if (removeTemplateResourceError) {
                    // Not exiting early since the only downside of this failing is a bit of extra cruft in the project file
                    PCLog(@"Error removing template resource after importing: %@", removeTemplateResourceError);
                }

                filenameToUUIDMapping[filename] = resourceUUID;
            }
            
            [template updatePropertyName:propertyName value:resourceUUID];
        }
    }

    [self resourceListChanged];
}

@end
