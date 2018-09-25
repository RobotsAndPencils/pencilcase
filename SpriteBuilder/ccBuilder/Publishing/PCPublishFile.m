//
//  PCPublishFile.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-02.
//
//

#import "PCPublishFile.h"
#import "CCBPublisher.h"
#import "PCProjectSettings.h"

@interface PCPublishFile()

@property (strong, nonatomic, nullable) NSNumber *fileSize;
@property (strong, nonatomic, nullable) NSDate *modifiedDate;

@end

@implementation PCPublishFile

- (nullable instancetype)initWithAbsolutePath:(nonnull NSString *)absolutePath rootPath:(nonnull NSString *)rootPath {
    self = [super init];
    if (self) {
        if ([absolutePath hasPrefix:rootPath]) {
            _relativePath = [absolutePath substringFromIndex:rootPath.length];
        } else {
            _relativePath = absolutePath;
        }
        _absolutePath = absolutePath;

        NSError *error;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:absolutePath error:&error];
        if (error) {
            NSLog(@"Could not store file attributes for file at path %@", absolutePath);
        } else {
            _fileSize = attributes[NSFileSize];
            _modifiedDate = attributes[NSFileModificationDate];
        }
    }
    return self;
}

- (BOOL)hasChangedSince:(nonnull PCPublishFile *)previousFile {
    //If either is incomplete, we assume they are different
    if (!self.modifiedDate || !previousFile.modifiedDate || !self.fileSize || !previousFile.fileSize) return YES;

    return ![self.modifiedDate isEqual:previousFile.modifiedDate] || ![self.fileSize isEqual:previousFile.fileSize];
}

- (nonnull NSString *)projectSettingsPathFrom:(nonnull CCBPublisher *)publisher {
    return [publisher.projectSettings.defaultResourcesSubpath stringByAppendingPathComponent:self.relativePath];
}

@end
