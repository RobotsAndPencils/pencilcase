//
//  RBKDepositBoxImageHelper.m
//  RBKDepositBoxManager
//
//  Created by Matt KiazykNew on 2013-07-23.
//  Copyright (c) 2013 Robots & Pencils. All rights reserved.
//

#import "RBKDepositBoxImageHelper.h"
#import "UIImage+RBKDepositBox.h"

@implementation RBKDepositBoxImageHelper

- (void)saveToDepositBox:(UIImage *)image withUUID:(NSString *)uuid thumbnailCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)thumbnailBlock fullsizeCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)fullsizeBlock {
    
    NSData *imageData = UIImageJPEGRepresentation(image, self.thumbnailCompression);
    NSString *extension = [self contentTypeForImageData:imageData];
    
    [imageData writeToFile:[self fullsizeFilePathStringForUUID:uuid extension:extension] atomically:NO];
    
    UIImage *thumnbnail = [image imageByScalingToHeight:self.thumbnailHeight];
    NSData *thumbnailData = UIImageJPEGRepresentation(thumnbnail, self.thumbnailCompression);
    [thumbnailData writeToFile:[self thumbnailFilePathStringForUUID:uuid extension:extension] atomically:NO];
    
    [self writeDataToDepsoitBoxWithUUID:uuid thumbnailAlreadyOnDepositBox:NO fullImageAlreadyOnDepositBox:NO thumbnailCompletionHandler:thumbnailBlock fullsizeCompletionHandler:fullsizeBlock extension:extension];
}

- (void)saveToDepositBox:(UIImage *)image withUUID:(NSString *)uuid thumbnailAlreadyOnDepositBox:(BOOL)thumbnailOnDepositBox fullImageAlreadyOnDepositBox:(BOOL)fullImageOnDepositBox thumbnailCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)thumbnailBlock fullsizeCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)fullsizeBlock {
    
    NSData *imageData = UIImageJPEGRepresentation(image, self.thumbnailCompression);
    NSString *extension = [self contentTypeForImageData:imageData];
    
    [imageData writeToFile:[self fullsizeFilePathStringForUUID:uuid extension:extension] atomically:NO];
    
    UIImage *thumnbnail = [image imageByScalingToHeight:self.thumbnailHeight];
    NSData *thumbnailData = UIImageJPEGRepresentation(thumnbnail, self.thumbnailCompression);
    [thumbnailData writeToFile:[self thumbnailFilePathStringForUUID:uuid extension:extension] atomically:NO];
    
    if ([self canWriteFileWithUUID:uuid toDespositBox:(thumbnailOnDepositBox && fullImageOnDepositBox) extension:extension]) {
        [self writeDataToDepsoitBoxWithUUID:uuid thumbnailAlreadyOnDepositBox:thumbnailOnDepositBox fullImageAlreadyOnDepositBox:fullImageOnDepositBox thumbnailCompletionHandler:thumbnailBlock fullsizeCompletionHandler:fullsizeBlock extension:extension];
    }
    
}

- (NSString *)fullsizeFilePathStringForUUID:(NSString *)uuid extension:(NSString *)extension {
    return [self filePathForUUID:uuid withModifier:nil extension:extension];
}

- (NSString *)thumbnailFilePathStringForUUID:(NSString *)uuid extension:(NSString *)extension {
    return [self filePathForUUID:uuid withModifier:@"thumbnail" extension:extension];
}

- (void)loadFilePath:(NSString *)filePath orFromDepositBoxWithUUID:(NSString *)uuid block:(ImageLoadingBlock)block {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:filePath]) {
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image, nil);
            });
        } else {
            
            [self downloadFileToPath:filePath fromDepositBoxWithUUID:uuid completionHandler:^(BOOL suceeded, BOOL fileDoesNotExist) {
                if (suceeded) {
                    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(image, nil);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, [NSError errorWithDomain:@"not implemented" code:1 userInfo:nil]);
                    });
                }
            }];
        }
    });
}

- (BOOL)canWriteFileWithUUID:(NSString *)uuid toDespositBox:(BOOL)filesOnDepositBox extension:(NSString *)extension {
    
    BOOL filesExistLocally = ([[NSFileManager defaultManager] fileExistsAtPath:[self thumbnailFilePathStringForUUID:uuid extension:extension]] &&
                              [[NSFileManager defaultManager] fileExistsAtPath:[self fullsizeFilePathStringForUUID:uuid extension:extension]]);
    if (!filesExistLocally) {
        NSLog(@"Could not re-upload image with UUID: %@ as files don't exist locally.", uuid);
    }
    
    return filesExistLocally && !filesOnDepositBox;
}

- (void)writeDataToDepsoitBoxWithUUID:(NSString *)uuid thumbnailAlreadyOnDepositBox:(BOOL)thumbnailIsOnDepositBox fullImageAlreadyOnDepositBox:(BOOL)fullImageIsOnDepositBox thumbnailCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)thumbnailBlock fullsizeCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)fullsizeBlock extension:(NSString *)extension {
    
    [self uploadFileAtPath:[self thumbnailFilePathStringForUUID:uuid extension:extension]
                  mimeType:@"image/jpeg"
            toDepositBoxWithUUID:[self thumbnailUUID:uuid]
          fileExistsOnDepositBox:thumbnailIsOnDepositBox
               completionHandler:^(BOOL suceeded) {
                   if (thumbnailBlock) thumbnailBlock(suceeded);
               }];
    
    [self uploadFileAtPath:[self fullsizeFilePathStringForUUID:uuid extension:extension]
                  mimeType:@"image/jpeg"
            toDepositBoxWithUUID:uuid
          fileExistsOnDepositBox:fullImageIsOnDepositBox
               completionHandler:^(BOOL suceeded) {
                   if (fullsizeBlock) fullsizeBlock(suceeded);
               }];
}

- (void)loadFullsizeImageForUUID:(NSString *)uuid withBlock:(ImageLoadingBlock)block {
    [self loadFilePath:[self fullsizeFilePathStringForUUID:uuid] orFromDepositBoxWithUUID:uuid block:block];
}


- (void)loadThumbnailImageForUUID:(NSString *)uuid withBlock:(ImageLoadingBlock)block {
    [self loadFilePath:[self thumbnailFilePathStringForUUID:uuid] orFromDepositBoxWithUUID:[self thumbnailUUID:uuid] block:block];
}

- (NSString *)fullsizeFilePathStringForUUID:(NSString *)uuid {
    return [self filePathForUUID:uuid withModifier:nil extension:@"jpg"];
}

@end
