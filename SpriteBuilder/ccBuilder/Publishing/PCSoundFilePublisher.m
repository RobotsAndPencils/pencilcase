//
//  PCSoundFilePublisher.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-06.
//
//

#import "PCSoundFilePublisher.h"
#import "ResourceManagerUtil.h"
#import "CCBPublisher.h"
#import "FCFormatConverter.h"
#import "PCWarningGroup.h"
#import "CCBFileUtil.h"
#import "PCPublishFile.h"

@implementation PCSoundFilePublisher

+ (PCSoundFilePublisher *)soundFilePublisher {
    static PCSoundFilePublisher *soundFilePublisher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundFilePublisher = [[PCSoundFilePublisher alloc] init];
    });
    return soundFilePublisher;
}

- (NSArray *)expectedOutputFilesForFile:(nonnull PCPublishFile *)file inOutputDirectory:(nonnull NSString *)outputDirectory publisher:(nonnull CCBPublisher *)publisher {
    NSInteger format = [self soundFormatForFile:file publisher:publisher];
    NSString *unconvertedOutputPath = [outputDirectory stringByAppendingPathComponent:file.relativePath];
    return @[ [[FCFormatConverter defaultConverter] proposedNameForConvertedSoundAtPath:unconvertedOutputPath format:format] ];
}

- (BOOL)publishFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory withPublisher:(nonnull CCBPublisher *)publisher {
    if (![super publishFile:file to:outputDirectory withPublisher:publisher]) {
        return NO;
    }

    NSInteger format = [self soundFormatForFile:file publisher:publisher];
    NSInteger quality = [self soundQualityForFile:file publisher:publisher];
    NSString *unconvertedOutputFilePath = [outputDirectory stringByAppendingPathComponent:file.relativePath];
    if (![[FCFormatConverter defaultConverter] convertSoundAtPath:unconvertedOutputFilePath format:format quality:quality]) {
        [publisher.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to convert audio file %@", file.relativePath] isFatal:NO];
        return YES;
    }

    return YES;
}

#pragma mark - PCFileRenameRulePublisher

- (nonnull NSString *)publishedFilePathFromFilePath:(nonnull NSString *)filePath publisher:(nonnull CCBPublisher *)publisher {
    NSInteger format = [self soundFormatForFilePath:filePath publisher:publisher];
    return [[FCFormatConverter defaultConverter] proposedNameForConvertedSoundAtPath:filePath format:format];
}

#pragma mark - Private helpers

- (NSInteger)soundFormatForFile:(nonnull PCPublishFile *)file publisher:(nonnull CCBPublisher *)publisher {
    return [self soundFormatForFilePath:[file projectSettingsPathFrom:publisher] publisher:publisher];
}

- (NSInteger)soundFormatForFilePath:(nonnull NSString *)filePath publisher:(nonnull CCBPublisher *)publisher {
    NSInteger settingsFormat = [[publisher.projectSettings valueForRelPath:filePath andKey:@"format_ios_sound"] intValue];
    return (settingsFormat == 1 ? kFCSoundFormatMP4 : kFCSoundFormatCAF);
}

- (NSInteger)soundQualityForFile:(nonnull PCPublishFile *)file publisher:(nonnull CCBPublisher *)publisher {
    NSInteger quality = [[publisher.projectSettings valueForRelPath:[file projectSettingsPathFrom:publisher] andKey:@"format_ios_sound_quality"] intValue];
    return quality ?: publisher.projectSettings.publishAudioQuality_ios;
}

@end
