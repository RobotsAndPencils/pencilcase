//
//  PCPublishFile.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-02.
//
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@class CCBPublisher;

@interface PCPublishFile : MTLModel

@property (strong, nonatomic, readonly, nonnull) NSString *relativePath;
@property (strong, nonatomic, readonly, nonnull) NSString *absolutePath;

- (nullable instancetype)initWithAbsolutePath:(nonnull NSString *)absolutePath rootPath:(nonnull NSString *)rootPath;
- (BOOL)hasChangedSince:(nonnull PCPublishFile *)previousFile;
- (nonnull NSString *)projectSettingsPathFrom:(nonnull CCBPublisher *)publisher;

@end
