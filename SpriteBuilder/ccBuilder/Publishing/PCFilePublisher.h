//
//  PCFilePublisher.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-03.
//
//

#import <Foundation/Foundation.h>

@class CCBPublisher;
@class PCPublishFile;

@interface PCFilePublisher : NSObject

+ (nonnull PCFilePublisher *)resourcePublisherForExtension:(nullable NSString *)fileExtension;

- (BOOL)shouldPublishFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory previousManifest:(nullable NSDictionary *)previousManifest publisher:(nonnull CCBPublisher *)publisher;

- (BOOL)publishFile:(nonnull PCPublishFile *)file to:(nonnull NSString *)outputDirectory withPublisher:(nonnull CCBPublisher *)publisher;

- (nonnull NSArray/*<NSString *>*/ *)expectedOutputFilesForFile:(nonnull PCPublishFile *)file inOutputDirectory:(nonnull NSString *)outputDirectory publisher:(nonnull CCBPublisher *)publisher;

+ (void)prepareFileSystemToWriteFiletoPath:(nonnull NSString *)outputFile;


@end
