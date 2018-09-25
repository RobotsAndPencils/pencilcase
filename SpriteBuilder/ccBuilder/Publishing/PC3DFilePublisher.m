//
//  PC3DFilePublisher.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-06.
//
//

#import "PC3DFilePublisher.h"
#import "CCBFileUtil.h"
#import "PCPublishFile.h"
#import "CCBPublisher.h"
#import "PCWarningGroup.h"

@implementation PC3DFilePublisher

+ (PC3DFilePublisher *)threeDFilePublisher {
    static PC3DFilePublisher *threeDFilePublisher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        threeDFilePublisher = [[PC3DFilePublisher alloc] init];
    });
    return threeDFilePublisher;
}

- (BOOL)publishFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory withPublisher:(nonnull CCBPublisher *)publisher {
    NSString *destinationPath = [outputDirectory stringByAppendingPathComponent:file.relativePath];
    [PCFilePublisher prepareFileSystemToWriteFiletoPath:destinationPath];

    if ([self processDAEFileWithSCNToolAt:file.absolutePath to:destinationPath publisher:publisher]) return YES;

    // If we get here, scn tool failed. This could mean that it's already compressed, so try to recover by using the provided .dae file.
    return [super publishFile:file to:outputDirectory withPublisher:publisher];
}

#pragma mark - DAE

/**
 *  Convert an xml formatted dae file to a compressed format with xcode's scntool. Reqires Xcode to be installed.
 *
 *  @param origPath path of xml dae
 *  @param newPath  path of scn dae
 *
 *  @return YES if successfully processed file.
 */
- (BOOL)processDAEFileWithSCNToolAt:(NSString *)origPath to:(NSString *)newPath publisher:(CCBPublisher *)publisher {
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;

    NSString *scntoolPath = [CCBPublisher getXcodePath];
    scntoolPath = [scntoolPath stringByAppendingString:@"/usr/bin/scntool"];

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = scntoolPath;
    task.arguments = @[@"--compress", origPath, @"-o", newPath, @"--force-y-up"];
    task.standardOutput = pipe;

    // try and catch any exception thrown from nstask
    @try {
        [task launch];
#ifdef DEBUG
        NSData *data = [file readDataToEndOfFile];
        [file closeFile];

        NSString *grepOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        PCLog(@"grep returned:\n%@", grepOutput);
#endif
    }
    @catch (NSException *exception) {
        [publisher.warnings addWarningWithDescription:[NSString stringWithFormat:@"Failed to compress %@ to %@; Error message: %@", origPath, newPath, exception.reason] isFatal:YES];
        PCLog(@"scntool error: %@", exception);
        return NO;
    }
    @finally {
    }

    return [[NSFileManager defaultManager] fileExistsAtPath:newPath];
}


@end
