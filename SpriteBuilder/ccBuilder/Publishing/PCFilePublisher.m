//
//  PCFilePublisher.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-03.
//
//

#import "PCFilePublisher.h"
#import "PCPublishFile.h"
#import "CCBPublisher.h"
#import "NSString+FileUtilities.h"
#import "PCImageFilePublisher.h"
#import "PCSoundFilePublisher.h"
#import "PC3DFilePublisher.h"
#import "PCCardFilePublisher.h"
#import "PCProjectSettings.h"

@interface PCFilePublisher()

@end

@implementation PCFilePublisher

#pragma mark - Initialisation

+ (nonnull PCFilePublisher *)resourcePublisherForExtension:(nullable NSString *)fileExtension {
    static NSDictionary *publisherToExtensionMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        for (NSString *extension in [NSString pc_imageExtensions]) {
            temp[extension.lowercaseString] = [PCImageFilePublisher imageFilePublisher];
        }
        for (NSString *extension in [NSString pc_audioExtensions]) {
            temp[extension.lowercaseString] = [PCSoundFilePublisher soundFilePublisher];
        }
        for (NSString *extension in [NSString pc_3DExtensions]) {
            temp[extension.lowercaseString] = [PC3DFilePublisher threeDFilePublisher];
        }
        for (NSString *extension in [NSString pc_cardExtensions]) {
            temp[extension.lowercaseString] = [PCCardFilePublisher cardFilePublisher];
        }
        publisherToExtensionMap = [temp copy];
    });
    PCFilePublisher *publisherForExtension = publisherToExtensionMap[fileExtension.lowercaseString];
    return publisherForExtension ?: [PCFilePublisher defaultFilePublisher];
}

+ (nonnull instancetype)defaultFilePublisher {
    static PCFilePublisher *defaultPublisher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultPublisher = [[PCFilePublisher alloc] init];
    });
    return defaultPublisher;
}

#pragma mark - Public

- (BOOL)shouldPublishFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory previousManifest:(nullable NSDictionary *)previousManifest publisher:(nonnull CCBPublisher *)publisher {
    if (![[NSFileManager defaultManager] fileExistsAtPath:file.absolutePath]) return NO;

    NSArray *expectedOutputFiles = [self expectedOutputFilesForFile:file inOutputDirectory:outputDirectory publisher:publisher];
    for (NSString *filePath in expectedOutputFiles) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return YES;
        }
    }

    PCPublishFile *lastPublishFile = previousManifest[file.relativePath];
    return [file hasChangedSince:lastPublishFile];
}

- (BOOL)publishFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory withPublisher:(nonnull CCBPublisher *)publisher {
    NSError *error;
    NSString *outputFile = [outputDirectory stringByAppendingPathComponent:file.relativePath];
    [PCFilePublisher prepareFileSystemToWriteFiletoPath:outputFile];
    [[NSFileManager defaultManager] copyItemAtPath:file.absolutePath toPath:outputFile error:&error];
    if (error) {
        //TODO: add warning
        NSLog(@"Could not publish file %@: %@", file.relativePath, error.localizedDescription);
        return NO;
    }
    return YES;
}

- (nonnull NSArray/*<NSString *>*/ *)expectedOutputFilesForFile:(nonnull PCPublishFile *)file inOutputDirectory:(nonnull NSString *)outputDirectory publisher:(CCBPublisher *)publisher {
    return @[ [outputDirectory stringByAppendingString:file.relativePath] ];
}

+ (void)prepareFileSystemToWriteFiletoPath:(nonnull NSString *)outputFile {
    NSString *containingFolder = [outputFile stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:containingFolder]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:containingFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
