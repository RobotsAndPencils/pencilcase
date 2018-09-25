//
//  PCImageFilePublisher.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-06.
//
//

#import "PCImageFilePublisher.h"
#import "CCBPublisher.h"
#import "ResourceManagerUtil.h"
#import "CCBPublisher.h"
#import "PCWarningGroup.h"
#import "CCBFileUtil.h"
#import "FCFormatConverter.h"
#import "PCPublishFile.h"

@implementation PCImageFilePublisher

#pragma mark - Initialisation

+ (instancetype)imageFilePublisher {
    static PCImageFilePublisher *imageFilePublisher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageFilePublisher = [[PCImageFilePublisher alloc] init];
    });
    return imageFilePublisher;
}

#pragma mark - Subclass

- (nonnull NSArray/*<NSString *>*/ *)expectedOutputFilesForFile:(nonnull PCPublishFile *)file inOutputDirectory:(nonnull NSString *)outputDirectory publisher:(CCBPublisher *)publisher {

    NSMutableArray *result = [NSMutableArray array];
    for (NSString *resolution in publisher.publishForResolutions) {
        [result addObject:[PCImageFilePublisher filePathForFile:file publishedToDirectory:outputDirectory resolution:resolution]];
    }
    return [result copy];
}

- (BOOL)publishFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory withPublisher:(nonnull CCBPublisher *)publisher {
    for (NSString *resolution in publisher.publishForResolutions) {
        [PCImageFilePublisher publishImageFile:file to:outputDirectory resolution:resolution publisher:publisher];
    }
    return YES;
}

#pragma mark - Private

+ (NSString *)filePathForFile:(PCPublishFile *)publishFile publishedToDirectory:(NSString *)outputDirectory resolution:(NSString *)resolution {
    NSString *fileName = [publishFile.relativePath lastPathComponent];
    NSString *relativeFolder = [publishFile.relativePath stringByDeletingLastPathComponent];
    NSString *resolutionFolder = [NSString stringWithFormat:@"resources-%@", resolution];
    NSString *fullPath = [[[outputDirectory stringByAppendingPathComponent:relativeFolder] stringByAppendingPathComponent:resolutionFolder] stringByAppendingPathComponent:fileName];
    return [[fullPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
}

+ (BOOL)publishImageFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory resolution:(nonnull NSString *)resolution publisher:(nonnull CCBPublisher *)publisher {

    NSString *outputFilePath = [PCImageFilePublisher filePathForFile:file publishedToDirectory:outputDirectory resolution:resolution];
    [PCFilePublisher prepareFileSystemToWriteFiletoPath:outputFilePath];

    if (![[PCResourceManager sharedManager] createCachedImageFromAuto:file.absolutePath saveAs:outputFilePath resolution:resolution studioUse:NO]) {
        [publisher.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to create image from %@", file.absolutePath] isFatal:YES];
        return NO;
    }

    NSInteger format = [PCImageFilePublisher imageFormatForFileAtPath:outputFilePath];
    BOOL dither = [[publisher.projectSettings valueForRelPath:[file projectSettingsPathFrom:publisher] andKey:@"format_ios_dither"] boolValue];;
    BOOL compress = [[publisher.projectSettings valueForRelPath:[file projectSettingsPathFrom:publisher] andKey:@"format_ios_compress"] boolValue];

    NSError *error;
    if(![[FCFormatConverter defaultConverter] convertImageAtPath:outputFilePath format:format dither:dither compress:compress isSpriteSheet:NO outputFilename:nil error:&error])
    {
        [publisher.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to convert image: %@. Error Message:%@", file.relativePath.lastPathComponent, error.localizedDescription] isFatal:NO];
        return NO;
    }

    return YES;
}

+ (NSInteger)imageFormatForFileAtPath:(NSString *)imagePath {
    NSString *fileType = [[NSWorkspace sharedWorkspace] typeOfFile:imagePath error:nil];
    NSString *extension = [fileType pathExtension];
    return ([extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"jpg"]) ? kFCImageFormatJPG_High : kFCImageFormatPNG;
}


@end
