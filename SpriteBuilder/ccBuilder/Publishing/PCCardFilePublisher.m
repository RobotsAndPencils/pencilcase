//
//  PCCardPublisher.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-07.
//
//

#import "PCCardFilePublisher.h"
#import "CCBPublisher.h"
#import "PCPublishFile.h"
#import "CCBFileUtil.h"
#import "PCWarningGroup.h"
#import "PluginManager.h"
#import "PluginExport.h"
#import "PCProjectSettings.h"

@implementation PCCardFilePublisher

#pragma mark - Initialisation

+ (PCCardFilePublisher *)cardFilePublisher {
    static PCCardFilePublisher *cardFilePublisher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cardFilePublisher = [[PCCardFilePublisher alloc] init];
    });
    return cardFilePublisher;
}

#pragma mark - Subclass

- (BOOL)publishFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory withPublisher:(nonnull CCBPublisher *)publisher {
    NSString *strippedFileName = file.relativePath.lastPathComponent.stringByDeletingPathExtension;
    NSString *absoluteOutputDirectory = [outputDirectory stringByAppendingPathComponent:file.relativePath].stringByDeletingLastPathComponent;
    NSString *absoluteDestinationPath = [[absoluteOutputDirectory stringByAppendingPathComponent:strippedFileName] stringByAppendingPathExtension:publisher.publishFormat];

    return [PCCardFilePublisher publishCCBFile:file.absolutePath to:absoluteDestinationPath publisher:publisher];
}

#pragma mark - Private Helpers

+ (BOOL)publishCCBFile:(NSString *)sourceFile to:(NSString *)destinationFile publisher:(CCBPublisher *)publisher {
    PlugInExport *plugIn = [[PlugInManager sharedManager] plugInExportForExtension:publisher.publishFormat];
    if (!plugIn) {
        [publisher.warnings addWarningWithDescription:[NSString stringWithFormat: @"Plug-in is missing for publishing files to %@-format. You can select plug-in in Project Settings.", publisher.publishFormat] isFatal:YES];
        return NO;
    }

    NSMutableDictionary *sourceDocument = [NSMutableDictionary dictionaryWithContentsOfFile:sourceFile];
    if (!sourceDocument) {
        [publisher.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish ccb-file. File is in invalid format: %@",sourceFile] isFatal:YES];
        return NO;
    }

    plugIn.flattenPaths = publisher.projectSettings.flattenPaths;
    plugIn.projectSettings = publisher.projectSettings;

    NSData *exportedData = [plugIn exportDocument:sourceDocument encounterWarning:^(NSString *message, BOOL fatal) {
        [publisher.warnings addWarningWithDescription:message isFatal:fatal relatedFile:[destinationFile lastPathComponent]];
    }];
    if (!exportedData) {
        [publisher.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish ccb-file: %@",sourceFile] isFatal:YES];
        return NO;
    }

    [PCFilePublisher prepareFileSystemToWriteFiletoPath:destinationFile];
    if (![exportedData writeToFile:destinationFile atomically:YES]) {
        [publisher.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to publish ccb-file. Failed to write file: %@",destinationFile] isFatal:YES];
        return NO;
    }

    return YES;
}


@end
