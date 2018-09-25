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

#import "CCBPublisher.h"
#import "PCProjectSettings.h"
#import "PCWarningGroup.h"
#import "NSString+RelativePath.h"
#import "PlugInExport.h"
#import "PlugInManager.h"
#import "AppDelegate.h"
#import "PCResourceManager.h"
#import "CCBFileUtil.h"
#import "Tupac.h"
#import "CCBPublisherTemplate.h"
#import "CCBDirectoryComparer.h"
#import "ResourceManagerUtil.h"
#import "FCFormatConverter.h"
#import "NSImage+PNGRepresentation.h"
#import "PCIBeacon.h"
#import "PCTemplate.h"
#import "CCBReaderInternal.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+JavaScript.h"
#import "NodePhysicsBody.h"
#import "PCBehaviourList.h"
#import "PCWhen.h"
#import "PCKeyPressedStatement.h"
#import "PCToken.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"
#import "NSFileManager+PCHelpers.h"
#import "NSString+FileUtilities.h"
#import "PCTemplateLibrary.h"
#import "PCPublishJavascriptContext.h"
#import "PCPublishFile.h"
#import "PCFilePublisher.h"
#import "PCImageFilePublisher.h"
#import "NSDictionary+Utility.h"
#import "PCFileRenameRulePublisher.h"

static const CGFloat PCPublishFilesWeight = 0.95f;

@interface CCBPublisher ()

@property (strong, readwrite, nonatomic) NSArray *publishForResolutions;
@property (assign, readwrite, nonatomic) PCPublisherTargetType targetType;
@property (copy, readwrite, nonatomic) NSString *publishFormat;

@property (copy, nonatomic) NSString *outputDir;


@property (strong, nonatomic) NSArray *extensionsToCopy;
@property (strong, nonatomic) NSMutableDictionary *renamedFiles;

@end

@implementation CCBPublisher

- (instancetype)initWithProjectSettings:(PCProjectSettings *)settings warnings:(PCWarningGroup *)w {
    self = [super init];
    if (self) {
        _projectSettings = settings;
        _publishFormat = _projectSettings.exporter;
        _warnings = w;

        _extensionsToCopy = @[@"jpg",@"jpeg", @"png", @"psd", @"pvr", @"ccz", @"plist", @"fnt", @"ttf",@"js", @"json", @"wav",@"mp3",@"m4a",@"caf",@"ccblang",@"mov",@"mp4",@"dae",@"tiff",@"tif",@"tga", @"thumb", @"ccb"];
    }
    
    return self;
}

- (void)addRenamingRuleFrom:(NSString *)src to:(NSString*)dst {
    if (self.projectSettings.flattenPaths) {
        src = [src lastPathComponent];
        dst = [dst lastPathComponent];
    }

    if ([src isEqualToString:dst]) return;

    self.renamedFiles[src] = dst;
}

/// Writes out the lookup dictionary for keyPress events on an entire card to a file
/// If the file exists, and there are keyPress events on this card, it will append those events to the dictionary with the card's UUID as the key
- (void)appendKeyPressInfo:(NSArray *)keyPressInfo withKey:(NSString *)key toFilePath:(NSString *)filePath {
    NSMutableDictionary *lookupDictionary;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        lookupDictionary = [[[NSDictionary alloc] initWithContentsOfFile:filePath] mutableCopy];
    } else {
        lookupDictionary = [[NSMutableDictionary alloc] init];
    }

    if (keyPressInfo.count) {
        lookupDictionary[key] = keyPressInfo;
        [lookupDictionary writeToFile:filePath atomically:YES];
    }
}

/// Returns an array of unique @[ keyCode, modifier ] arrays for key press whens
- (NSArray *)keyPressInfoFromWhens:(NSArray *)whens {
    return Underscore.array(whens).filter(^BOOL(PCWhen *when) {
        return [when.statement isKindOfClass:[PCKeyPressedStatement class]];
    }).map(^(PCWhen *when){
        PCKeyPressedStatement *statement = (PCKeyPressedStatement *)when.statement;

        PCToken *keyToken = statement.keyExpression.token;
        NSDictionary *value = (NSDictionary *)keyToken.descriptor.value;
        NSString *keyCode = value[@"keycode"];
        NSString *modifier = value[@"keycodeModifier"];
        return @[ keyCode, modifier ];
    }).uniq.unwrap;
}

- (nonnull NSDictionary/*<NSString : PCPublishFile *>*/ *)resourcesInDirectory:(nonnull NSString *)absoluteDirectoryPath relativeToDirectory:(nonnull NSString *)absoluteRootDirectory includeNestedFolders:(BOOL)includeNestedFolders {
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absoluteDirectoryPath error:&error];
    if (error) {
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to access output path %@", absoluteDirectoryPath] isFatal:YES];
        return @{};
    }

    NSMutableDictionary *filesToPublish = [NSMutableDictionary dictionary];
    for (NSString *file in files) {
        if ([file pc_isHiddenFile]) continue;

        NSString *absoluteFilePath = [absoluteDirectoryPath stringByAppendingPathComponent:file];
        BOOL directory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:absoluteFilePath isDirectory:&directory]) continue;

        if (!directory) {
            NSString *extension = file.lowercaseString.pathExtension;
            if (!PCIsEmpty(extension) && ![self.extensionsToCopy containsObject:extension]) continue;

            PCPublishFile *file = [[PCPublishFile alloc] initWithAbsolutePath:absoluteFilePath rootPath:absoluteRootDirectory];
            filesToPublish[file.relativePath] = file;
        } else if (includeNestedFolders) {
            [filesToPublish addEntriesFromDictionary:[self resourcesInDirectory:absoluteFilePath relativeToDirectory:absoluteRootDirectory includeNestedFolders:includeNestedFolders]];
        }
    }
    return [filesToPublish copy];
}

+ (nonnull NSString *)manifestPathInFolder:(nonnull NSString *)directory {
    static NSString *const PCPublishManifestFileName = @".publish";
    return [directory stringByAppendingPathComponent:PCPublishManifestFileName];
}

+ (nullable NSDictionary *)publishManifestInFolder:(nonnull NSString *)directory {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[CCBPublisher manifestPathInFolder:directory]];
}

- (BOOL)publishResourcesInDirectory:(nonnull NSString *)directory publishNestedFolders:(BOOL)publishNestedFolders outputDirectory:(nonnull NSString *)outputDirectory statusBlock:(nullable PCStatusBlock)statusBlock {

    NSDictionary *publishManifest = [self resourcesInDirectory:directory relativeToDirectory:directory includeNestedFolders:publishNestedFolders];
    NSLog(@"PUBLISH: Publishing to output directory %@", outputDirectory);
    NSDictionary *previousManifest = [CCBPublisher publishManifestInFolder:outputDirectory];
    NSMutableDictionary *outputManifest = previousManifest ? [previousManifest mutableCopy] : [NSMutableDictionary dictionary];

    [self removeFilesInManifest:previousManifest thatAreNotPresentInManifest:publishManifest fromOutputDirectory:outputDirectory outputManifest:outputManifest];
    [self addRenameRulesFrom:publishManifest];

    NSArray *filesToPublish = [self filesNeedingPublishIn:publishManifest withPreviousManifest:previousManifest outputDirectory:outputDirectory];
    BOOL status = [self publishFiles:filesToPublish to:outputDirectory finalManifest:outputManifest statusBlock:statusBlock];

    if (statusBlock) statusBlock(@"Finalizing...", PCPublishFilesWeight);
    [NSKeyedArchiver archiveRootObject:outputManifest toFile:[CCBPublisher manifestPathInFolder:outputDirectory]];
    return status;
}

- (void)addRenameRulesFrom:(NSDictionary *)publishManifest {
    for (PCPublishFile *file in publishManifest.allValues) {
        PCFilePublisher *filePublisher = [PCFilePublisher resourcePublisherForExtension:file.relativePath.pathExtension];
        if (![filePublisher conformsToProtocol:@protocol(PCFileRenameRulePublisher)]) continue;

        PCFilePublisher<PCFileRenameRulePublisher> *renamePublisher = (PCFilePublisher<PCFileRenameRulePublisher> *)filePublisher;
        NSString *originalPath = [self.projectSettings.defaultResourcesSubpath stringByAppendingPathComponent:file.relativePath];
        [self addRenamingRuleFrom:originalPath to:[renamePublisher publishedFilePathFromFilePath:originalPath publisher:self]];
    }
}

- (nonnull NSArray/*<NSArray[file, publisher]>*/*)filesNeedingPublishIn:(nonnull NSDictionary *)publishManifest withPreviousManifest:(nullable NSDictionary *)previousManifest outputDirectory:(NSString *)outputDirectory {

    NSMutableArray *filesNeedingPublish = [NSMutableArray array];
    for (PCPublishFile *file in publishManifest.allValues) {
        PCFilePublisher *publisher = [PCFilePublisher resourcePublisherForExtension:file.relativePath.pathExtension];
        if ([publisher shouldPublishFile:file to:outputDirectory previousManifest:previousManifest publisher:self]) {
            [filesNeedingPublish addObject:file];
        } else {
            NSLog(@"Skipping %@", file.relativePath);
        }
    }
    return [filesNeedingPublish copy];
}

- (BOOL)publishFiles:(nonnull NSArray *)filesNeedingPublish to:(NSString *)outputDirectory finalManifest:(NSMutableDictionary *)finalManifest statusBlock:(nullable PCStatusBlock)statusBlock {
    BOOL anyFailed = NO;
    for (NSInteger fileIndex = 0; fileIndex < filesNeedingPublish.count; fileIndex++) {
        PCPublishFile *file = filesNeedingPublish[fileIndex];
        if (statusBlock) statusBlock([NSString stringWithFormat:NSLocalizedString(@"PublishFileFormat", nil), file.relativePath.lastPathComponent], fileIndex / (CGFloat)filesNeedingPublish.count * PCPublishFilesWeight);

        PCFilePublisher *publisher = [PCFilePublisher resourcePublisherForExtension:file.relativePath.pathExtension];
        if (![publisher publishFile:file to:outputDirectory withPublisher:self]) {
            anyFailed = YES;
            continue;
        }

        finalManifest[file.relativePath] = file;
        NSLog(@"Published %@", file.relativePath);
    }
    return !anyFailed;
}

- (void)removeFilesInManifest:(nonnull NSDictionary *)previousManifest thatAreNotPresentInManifest:(nonnull NSDictionary *)publishManifest fromOutputDirectory:(NSString *)outputDirectory outputManifest:(NSMutableDictionary *)outputManifest {
    NSSet *filesToRemove = [previousManifest keysThatDoNotExistInDictionary:publishManifest];
    for (NSString *fileName in filesToRemove) {
        PCPublishFile *file = previousManifest[fileName];
        PCFilePublisher *publisher = [PCFilePublisher resourcePublisherForExtension:file.relativePath.pathExtension];
        NSArray *expectedFiles = [publisher expectedOutputFilesForFile:file inOutputDirectory:outputDirectory publisher:self];
        for (NSString *absolutePath in expectedFiles) {
            [[NSFileManager defaultManager] removeItemAtPath:absolutePath error:nil];
        }
        [outputManifest removeObjectForKey:fileName];
        NSLog(@"Removed file %@", fileName);
    }
}

/// Publishes a dictionary to a plist that contains the filename conversions for resources that get exported to new formats during publish (ex: sound.wav will actually be sound.caf after being published, this is how the launcher knows to make that conversion)
- (BOOL)publishFilenameLookup {
    NSDictionary *fileLookup = @{
                                 @"metadata" : @{ @"version" : @1 },
                                 @"filenames" : self.renamedFiles
                                };

    NSString *lookupFilePath = [self.outputDir stringByAppendingPathComponent:[self fileLookupFileName]];

    if (![fileLookup writeToFile:lookupFilePath atomically:YES]) {
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write to file: %@", lookupFilePath] isFatal:YES];
        return NO;
    }
    return YES;
}

- (void) publishGeneratedFiles
{
    // Create the directory if it doesn't exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL createdDirs = [fileManager createDirectoryAtPath:self.outputDir withIntermediateDirectories:YES attributes:NULL error:NULL];
    if (!createdDirs)
    {
        [self.warnings addWarningWithDescription:@"Failed to create output directory" isFatal:YES relatedFile:self.outputDir];
        return;
    }
    
    if (![self publishFilenameLookup]) return;

    // We need to save the name in order to convert them in the launcher
    NSMutableDictionary *fontNamesDictionary = [NSMutableDictionary dictionary];

    NSString *keyPressLookupFilePath = [self.outputDir stringByAppendingPathComponent:@"slideKeyPressLookup.plist"];

    // Generate slide lookup
    NSMutableDictionary *slideLookup = [NSMutableDictionary dictionary];
    NSMutableArray *slideList = [NSMutableArray array];
    PCPublishJavascriptContext *publishContext = [[PCPublishJavascriptContext alloc] init];
    [self.projectSettings.slideList enumerateObjectsUsingBlock:^(PCSlide *slide, NSUInteger index, BOOL *stop) {
        // Append slide to slide list
        NSString *fileName = slide.fileName;
        if ([[fileName pathExtension] isEqualToString:@"ccb"]) {
            fileName = [fileName stringByDeletingPathExtension];
        }
        [slideList addObject:fileName];

        // Merge fonts from this slide's dictionary into the master list
        for (NSString *fontName in slide.labelFontInfo) {
            NSString *actualFontName = slide.labelFontInfo[fontName];
            fontNamesDictionary[fontName] = actualFontName;
        }

        // Copy the pre-generated JS file to the output directory
        NSString *sourceJSFilePath = slide.absoluteJavaScriptFilePath;
        NSString *targetJSFileName = [self.outputDir stringByAppendingPathComponent:slide.javaScriptFileName];
        if ([fileManager fileExistsAtPath:targetJSFileName]) {
            NSError *removeExistingJSFileError;
            [fileManager removeItemAtPath:targetJSFileName error:&removeExistingJSFileError];
            if (removeExistingJSFileError) {
                PCLog(@"Error removing existing JS file while publishing: %@", removeExistingJSFileError.localizedDescription);
            }
        }

        if (!PCIsEmpty(sourceJSFilePath) && [[NSFileManager defaultManager] fileExistsAtPath:sourceJSFilePath]) {
            NSError *shimError;
            NSString *shimmedJavascript = [publishContext shimGeneratorScriptAtPath:sourceJSFilePath error:&shimError];
            if (shimError) {
                [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish %@; Error message: %@", targetJSFileName, shimError.localizedDescription] isFatal:YES];
                PCLog(@"Error shimming JS file while publishing: %@", shimError.localizedDescription);
            }
            NSError *writeJSFileError;
            [shimmedJavascript writeToFile:targetJSFileName atomically:YES encoding:NSUTF8StringEncoding error:&writeJSFileError];
            if (writeJSFileError) {
                [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write %@; Error message: %@", targetJSFileName, writeJSFileError.localizedDescription] isFatal:YES];
                PCLog(@"Error writing shimmed JS file while publishing: %@", writeJSFileError.localizedDescription);
            }
        }

        // Write out keyPress event lookup file so the UIKeyCommands can be registered at runtime
        NSArray *keyPressInfo = [self keyPressInfoFromWhens:slide.behaviourList.whens];
        [self appendKeyPressInfo:keyPressInfo withKey:slide.uuid toFilePath:keyPressLookupFilePath];
    }];

    [self publishFonts:fontNamesDictionary];
    
    [slideLookup setObject:slideList forKey:@"slideFiles"];
    NSString *slideLookupFile = [self.outputDir stringByAppendingPathComponent:@"slideFileList.plist"];
    if (![slideLookup writeToFile:slideLookupFile atomically:YES]) {
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write to file %@", slideLookupFile] isFatal:YES];
    }
    
    // Generate thirdParty lookup
    NSMutableDictionary *iBeaconLookup = [NSMutableDictionary dictionary];
    NSMutableArray *iBeaconInfoList = [NSMutableArray array];
    [self.projectSettings.iBeaconList enumerateObjectsUsingBlock:^(PCIBeacon *beacon, NSUInteger index, BOOL *stop) {
        [iBeaconInfoList addObject:[beacon dictionaryRepresentation]];
    }];
    [iBeaconLookup setObject:iBeaconInfoList forKey:@"iBeaconList"];
    NSString *thirdPartyInfoFile = [self.outputDir stringByAppendingPathComponent:@"thirdPartyInfo.plist"];
    if (![iBeaconLookup writeToFile:thirdPartyInfoFile atomically:YES]) {
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write to file %@", thirdPartyInfoFile] isFatal:YES];
    }

    // Copy ccbproj file
    NSDictionary *settings = [self.projectSettings serialize];
    NSString *projectFile = [self.outputDir stringByAppendingPathComponent:@"project.ccbproj"];
    if (![settings writeToFile:projectFile atomically:YES]) {
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write project file %@", projectFile] isFatal:YES];
    }

    NSString *iconFile = [self.outputDir stringByAppendingPathComponent:@"icon.png"];
    NSString *icon2xFile = [self.outputDir stringByAppendingPathComponent:@"icon@2x.png"];

    [fileManager removeItemAtPath:iconFile error:nil];
    [fileManager removeItemAtPath:icon2xFile error:nil];

    if (self.projectSettings.appIconImage) {
        if (![[self.projectSettings.appIconImage PNGRepresentation] writeToFile:iconFile atomically:YES]) {
            [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write icon %@", iconFile] isFatal:NO];
        }
    }
    else if (self.projectSettings.appIconRetinaImage) {
        if (![[self.projectSettings.appIconRetinaImage PNGRepresentation] writeToFile:iconFile atomically:YES]) {
            [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write icon %@", iconFile] isFatal:NO];
        }
    }

    if (self.projectSettings.appIconRetinaImage) {
        if (![[self.projectSettings.appIconRetinaImage PNGRepresentation] writeToFile:icon2xFile atomically:YES]) {
            [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write icon %@", icon2xFile] isFatal:NO];
        }
    }
    else if (self.projectSettings.appIconImage) {
        if (![[self.projectSettings.appIconImage PNGRepresentation] writeToFile:icon2xFile atomically:YES]) {
            [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write icon %@", icon2xFile] isFatal:NO];
        }
    }

    if ([self.projectSettings.slideList count] > 0){
        NSString *previewPath = [[self.projectSettings.slideList firstObject] absoluteImageFilePath];
        NSString *splashPath = [self.outputDir stringByAppendingPathComponent:@"splash.png"];
        if (![fileManager copyItemAtPath:previewPath toPath:splashPath error:nil]) {
            [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to copy splash from %@ to %@", previewPath, splashPath] isFatal:NO];
        }
    }

    if ([self.projectSettings.slideList count] > 0){
        NSString *previewPath = [[self.projectSettings.slideList firstObject] absoluteImageFilePath];
        NSString *splashPath = [self.outputDir stringByAppendingPathComponent:@"splash@2x.png"];
        if (![fileManager copyItemAtPath:previewPath toPath:splashPath error:nil]) {
            [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to copy splash from %@ to %@", previewPath, splashPath] isFatal:NO];
        }
    }

    // Generate Cocos2d setup file
    NSMutableDictionary* configCocos2d = [NSMutableDictionary dictionary];
    
    NSString* screenMode = @"";
    if (self.projectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFixed)
		screenMode = @"CCScreenModeFixed";
    else if (self.projectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
		screenMode = @"CCScreenModeFlexible";
    [configCocos2d setObject:screenMode forKey:@"CCSetupScreenMode"];
    
    NSString* screenOrientation = @"";
    if (self.projectSettings.deviceResolutionSettings.deviceOrientation == PCDeviceTargetOrientationLandscape)
		screenOrientation = @"CCScreenOrientationLandscape";
    else if (self.projectSettings.deviceResolutionSettings.deviceOrientation == PCDeviceTargetOrientationPortrait)
		screenOrientation = @"CCScreenOrientationPortrait";
    [configCocos2d setObject:screenOrientation forKey:@"CCSetupScreenOrientation"];
    
    [configCocos2d setObject:[NSNumber numberWithBool:YES] forKey:@"CCSetupTabletScale2X"];
    
    NSString* configCocos2dFile = [self.outputDir stringByAppendingPathComponent:@"configCocos2d.plist"];
    if (![configCocos2d writeToFile:configCocos2dFile atomically:YES]) {
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write file %@", configCocos2dFile] isFatal:YES];
    }
}

- (void)publishFonts:(NSDictionary *)fontNamesDictionary {
    // Copy the contents of the project/Font directory
    NSString *sourceFontsDirectory = self.projectSettings.absoluteProjectFontsPath;
    NSString *targetFontsDirectory = [self.outputDir stringByAppendingPathComponent:@"Fonts"];
    NSError *folderCreationError;
    [[NSFileManager defaultManager] createDirectoryAtPath:targetFontsDirectory withIntermediateDirectories:YES attributes:nil error:&folderCreationError];
    if (folderCreationError) {
        NSLog(@"Could not create fonts folder: %@", folderCreationError);
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to create fonts folder %@", folderCreationError] isFatal:YES];
        return;
    }

    NSDirectoryEnumerator *sourceFontsDirectoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:sourceFontsDirectory] includingPropertiesForKeys:@[ NSURLNameKey ] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    for (NSURL *sourceFontURL in sourceFontsDirectoryEnumerator) {
        NSURL *targetFontURL = [NSURL fileURLWithPath:[targetFontsDirectory stringByAppendingPathComponent:sourceFontURL.lastPathComponent]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:targetFontURL.path]) {
            NSError *targetFontRemovalError;
            [[NSFileManager defaultManager] removeItemAtURL:targetFontURL error:&targetFontRemovalError];
            if (targetFontRemovalError) {
                PCLog(@"Error removing file at target font publish URL: %@", targetFontRemovalError);
                [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to remove file %@; Error message: %@", targetFontURL, targetFontRemovalError.localizedDescription] isFatal:YES];
            }
        }
        NSError *copyFontError;
        [[NSFileManager defaultManager] copyItemAtURL:sourceFontURL toURL:targetFontURL error:&copyFontError];
        if (copyFontError) {
            PCLog(@"Error copying font for publish: %@", copyFontError);
            [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish font from %@ to %@; Error message: %@", sourceFontURL, targetFontURL, copyFontError.localizedDescription] isFatal:YES];
        }
    }

    // Save the font dictionary file
    NSString *fontDictionaryPath = [targetFontsDirectory stringByAppendingPathComponent:@"fontNames.plist"];
    if (![fontNamesDictionary writeToFile:fontDictionaryPath atomically:YES]) {
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to write fonts %@", fontDictionaryPath] isFatal:YES];
    }
}

- (BOOL)publishAllToDirectory:(NSString *)directory statusBlock:(nullable PCStatusBlock)statusBlock {
    self.outputDir = directory;

    self.renamedFiles = [NSMutableDictionary dictionary];
    
    // Publish resources and ccb-files
    for (NSString *dir in self.projectSettings.absoluteResourcePaths) {
        if (![self publishResourcesInDirectory:dir publishNestedFolders:NO outputDirectory:self.outputDir statusBlock:statusBlock]) return NO;
    }
    if (![self publishResourcesInDirectory:self.projectSettings.absoluteProjectResourcesPath publishNestedFolders:YES outputDirectory:[self.outputDir stringByAppendingPathComponent:self.projectSettings.defaultResourcesSubpath] statusBlock:statusBlock]) return NO;

    [self publishGeneratedFiles];
    [self publishTemplatesToDirectory:directory];
    
    // Yiee Haa!
    return YES;
}

- (void)publishTemplatesToDirectory:(NSString *)dir {
    NSString *sourcePath = [PCTemplateLibrary templateConfigFilePath];
    NSString *publishPath = [dir stringByAppendingPathComponent:@"templates.plist"];
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:publishPath error:&error];
    if (!success) {
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish templates from %@ to %@", sourcePath, publishPath] isFatal:YES];
    }
}

- (BOOL)publishResourcesToTemporaryDirectory:(nullable PCStatusBlock)statusBlock {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString* publishDir;
    
    publishDir = self.projectSettings.publishDirectory;
    
    for (NSString *file in [fm contentsOfDirectoryAtPath:publishDir error:NULL]) {
        if ([[self filesToKeepOnRepublish] containsObject:file]) continue;
        NSString *path = [publishDir stringByAppendingPathComponent:file];
        [fm removeItemAtPath:path error:nil];
    }
    
    self.targetType = PCPublisherTargetTypeIPhone;
    self.warnings.currentTargetType = self.targetType;
    
    NSMutableArray *resolutions = [NSMutableArray array];
    switch (self.projectSettings.deviceResolutionSettings.deviceTarget) {
        case PCDeviceTargetTypePhone:
            if (self.projectSettings.publishResolution_ios_phone) {
                [resolutions addObject:@"phone"];
            }
            if (self.projectSettings.publishResolution_ios_phonehd) {
                [resolutions addObject:@"phonehd"];
                [resolutions addObject:@"phone3x"];
            }
            break;

        case PCDeviceTargetTypeTablet:
        default:
            if (self.projectSettings.publishResolution_ios_tablet) {
                [resolutions addObject:@"tablet"];
            }
            if (self.projectSettings.publishResolution_ios_tablethd) {
                [resolutions addObject:@"tablethd"];
            }
            break;
    }
    self.publishForResolutions = resolutions;
    
    if (![self publishAllToDirectory:publishDir statusBlock:statusBlock]) return NO;

    [self.projectSettings clearAllDirtyMarkers];
    
    return YES;
}

- (NSArray *)filesToKeepOnRepublish {
    return @[ @"resources",
              @".publish",
              [self fileLookupFileName],
              ];
}

- (NSString *)fileLookupFileName {
    return @"fileLookup.plist";
}

- (void)publish:(nullable PCStatusBlock)statusBlock {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Do actual publish
        BOOL happyPublish = [self publishResourcesToTemporaryDirectory:statusBlock];

        // Flag files with warnings as dirty
        for (PCWarning* warning in self.warnings.warnings)
        {
            if (warning.relatedFile)
            {
                [self.projectSettings markAsDirtyRelPath:warning.relatedFile];
            }
            if (warning.fatal) happyPublish = NO;
        }

        if (!happyPublish && self.warnings.warnings.count == 0) {
            [self.warnings addWarningWithDescription:@"Failed to publish due to previous errors" isFatal:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate publisher:self finishedWithWarnings:self.warnings success:happyPublish];
        });
    });
}

- (BOOL)copyPublishDirectoryToURL:(NSURL *)url {
    NSString *publishDir = self.projectSettings.publishDirectory;
    if (PCIsEmpty(publishDir) || ![[NSFileManager defaultManager] fileExistsAtPath:publishDir]) {
        return NO;
    }

    NSURL *publishDirectoryURL = [NSURL fileURLWithPath:publishDir isDirectory:YES];

    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        NSError *existingItemRemovalError;
        BOOL removalSuccess = [[NSFileManager defaultManager] removeItemAtURL:url error:&existingItemRemovalError];
        if (!removalSuccess) {
            NSLog(@"SHARE: Error removing existing item at publish directory URL: %@", existingItemRemovalError);
        }
    }

    NSError *copyError;
    if (![[NSFileManager defaultManager] copyItemAtURL:publishDirectoryURL toURL:url error:&copyError]) {
        NSLog(@"SHARE: Error copying publish directory to URL: %@", copyError);
        [self.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to copy files from %@ to %@; Error messsage: %@", publishDirectoryURL, url, copyError.localizedDescription] isFatal:YES];
        return NO;
    }

    return YES;
}

#pragma mark - Xcode

/**
 *  Find the path of where xcode is installed on the system
 *
 *  @return path to xcode
 */
+ (NSString *)getXcodePath {
    NSString *path = @"/usr/bin/xcode-select";
    NSArray *args = @[ @"--print-path" ];
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = path;
    task.arguments = args;
    
    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];
    
    NSString *xcodePath = nil;
    @try {
        [task launch];
        [task waitUntilExit];
        NSFileHandle *fileHandle = [out fileHandleForReading];
        NSData *data = [fileHandle readDataToEndOfFile];
        xcodePath = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        return xcodePath;
    }
}

@end
