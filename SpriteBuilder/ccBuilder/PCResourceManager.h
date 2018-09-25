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

#import <Foundation/Foundation.h>
#import "PCResource.h"
#import "PCResourceDirectory.h"
#import "PCProjectSettings.h"
#import "PCDeviceResolutionSettings.h"

@class PCTemplateLibrary;

extern NSString * const PCEditedImageSuffix;
extern NSString * const PCVideoPlayerPosterSuffix;

extern NSString * const PCResourceFolderName;

extern CGFloat const PCResourceManagerInternalFontSize;


@interface PCResourceManager : NSObject <NSFileManagerDelegate> {
    NSMutableArray *resourceObserver;
}

@property (nonatomic, strong, readonly) NSMutableArray *directories;
@property (nonatomic, readonly) NSDictionary *directoriesWithRelativePaths;

/**
 The root directory where user-generated/imported files should go.
 */
@property (nonatomic, strong) PCResourceDirectory *rootDirectory;
/**
 The root directory stores all user-generated/imported files, including scene files (.ccb, etc.). This folder is one path deeper and stores the path where resources (.png, .mov, etc.) files should live.
 */
@property (nonatomic, strong) PCResourceDirectory *rootResourceDirectory;
@property (nonatomic, strong, readonly) NSMutableArray *allResources;

@property (nonatomic, strong, readonly) NSArray *supportedFonts;

+ (PCResourceManager *)sharedManager;

- (void)resourceListChanged;


/**
 Initialises the directories in the resource manager when a new project is opened
 @param directoriesWithLocalKeys The dictionary holding the directories, with the keys being relative paths to the project root
 @param rootDirectoryWithLocalPath The currently active root directory path relative to the project root
 @param localRootResourceDirectory The currently active resource root directory path relative to the project root
 @returns whether or not the directory loading is successful
 */
- (BOOL)loadFromLocalDirectories:(NSDictionary *)directoriesWithLocalKeys localRootDirectory:(NSString *)rootDirectoryWithLocalPath localRootResourceDirectory:(NSString *)localRootResourceDirectory;

/**
 Given an updated project settings, updates the directories / active directories configuration
 @param projectSettings the settings of the project that the resource manager should load from.
 @returns whether or not the project is reloaded successfully
 */
- (BOOL)reloadForProject:(PCProjectSettings *)projectSettings;

- (PCResourceDirectory *)addDirectory:(NSString *)directory;
- (void)addDirectoriesFromDictionaryWithRelativePaths:(NSDictionary *)dictionaryWithRelativePaths;
- (void)removeDirectory:(PCResourceDirectory *)directory;
- (void)removeAllDirectories;

/**
 Performs all the cleanup necessary to put the resource manager into a clean state when no project is loaded
 */
- (void)closeProject;

/**
 Creates a new PCResource object and stores it in the app. Automatically detects folder and modified time.
 @param file The file path
 @returns The created resource
 */
- (PCResource *)addResourceWithAbsoluteFilePath:(NSString *)file;

/**
 Creates a new PCResource object and stores it in the app. Automatically detects folder and modified time.
 @param file The file path
 @param The PCResourceDirectory containing the resource.
 @returns The created resource
 */
- (PCResource *)addResourceWithAbsoluteFilePath:(NSString *)file inDirectory:(PCResourceDirectory *)directory;

/**
 Creates a new directory in the file system as a child of the passed in resource directory, with the given name.
 @param directoryName the name for the directory
 @param resourceDirectory The directory that the resource should be added to. 
 @param addSuffixOnNameCollision if true, and the folder already exists, will append a number to the end of the folder name so that the folder is still created.
 @param error Pass an error pointer in here to receive additional information if the method fails
 @returns The created PCResoruce representing the folder, or `nil` if the resource creation fails.
 */
- (PCResource *)addDirectoryNamed:(NSString *)directoryName toDirectory:(PCResourceDirectory *)resourceDirectory addingSuffixOnNameCollision:(BOOL)addSuffixOnNameCollision error:(NSError **)error;

/**
 Recursively adds PCResource data for all resources inside a directory.
 @param absoluteDirectoryPath the absolute path to the directory in the file system. Must lead to a path inside the project. If not, this method will do nothing.
 */
- (void)addResourcesForFilesInDirectory:(NSString *)absoluteDirectoryPath;

- (void)addResourceObserver:(id)observer;
- (void)removeResourceObserver:(id)observer;

- (NSString *)toAbsolutePath:(NSString *)path;

/**
 *  Resolution-specific filename suffixes, like "-tablet"
 *
 *  @return An array of suffixes as strings
 */
- (NSArray *)resolutionSpecificSuffixes;

/**
 *  The directory names for resolution-specific resource directories, like "resources-phone"
 *
 *  @return An array of directory names as strings
 */
- (NSArray *)resolutionSpecificDirectories;

- (BOOL)createCachedImageFromAuto:(NSString *)autoFile saveAs:(NSString *)dstFile resolution:(NSString *)res studioUse:(BOOL)studioUse;

- (void)notifyResourceObserversResourceListUpdated;

/**
 Copies a resource from outside the project to inside the project, and creates a PCResource for the imported resource
 @param resource The absolute file path to the resource that we are creating
 @param dstDir The directory inside the project that the file should be copied into
 @param force Whether to append a # to the end of the file name if that file name already exists
 @returns The PCResource created, or nil if the operation fails
 */
- (PCResource *)importResourceAtAbsolutePath:(NSString *)absolutePath intoDirectoryAtAbsolutePath:(NSString *)destinationDirectory appendSuffixIfFileExists:(BOOL)appendSuffix;

/**
 Copies a list of resources from outside the project to inside the project, and creates a PCResource for each imported resource.
 Unlike importResource:, this does not update the UI until all resources have been updated, so is more efficient for importing batches.
 @param resources The list of absolute file paths to the files that we want to copy into the resource manager
 @param dstDir The directory inside the project that the file should be copied into
 @param force Whether to append a # to the end of the file name if that file name already exists
 @returns YES if any resource imports succeeded, no if any failed.
 */
- (BOOL)importResourcesAtAbsolutePaths:(NSArray *)absolutePaths intoDirectoryAtAbsolutePath:(NSString *)destinationDirectory appendSuffixIfFileExists:(BOOL)appendSuffix;

- (BOOL)moveResourceFile:(NSString *)srcFile ofType:(enum PCResourceType)type toDirectory:(NSString *)dstDir;
- (void)renameResourceFile:(NSString *)srcPath toNewName:(NSString *)newName;
- (void)removeResource:(PCResource *)res;
- (void)touchResource:(PCResource *)res;

/**
 Imports files related to a specific DAE file
 @param the array of files to import
 @param outResultFilePath the path to the loaded DAE file on success
 @returns whether or not the import succeeds
 */
- (BOOL)importDaeFiles:(NSArray *)files outResultFilePath:(NSString **)outResultFilePath;

- (PCResource *)resourceForPath:(NSString *)path;
- (PCResource *)resourceForPath:(NSString *)path inDir:(PCResourceDirectory *)dir;

- (BOOL)isResourceBeingUsed:(PCResource *)resource;

- (PCResource *)resourceWithUUID:(NSString *)uuid;

/**
 *  Check if there is a NSFont supported with the font name
 *
 *  @param fontName Name of the font we want to use
 *
 *  @return Is the NSFont available
 */
- (BOOL)isFontAvailable:(NSString *)fontName;

- (PCResourceDirectory *)resourceDirectoryForPath:(NSString *)path;

/**
 *  Used to import particle template image resources when creating a new project from a template project
 */
- (void)loadResourcesForParticleTemplates:(NSArray *)templates;

/**
 *  All the media files type we are allowing to import (png, jpeg etc)
 *
 *  @return Array of file types
 */
+ (NSArray *)allowedMediaFileExtensions;

@end
