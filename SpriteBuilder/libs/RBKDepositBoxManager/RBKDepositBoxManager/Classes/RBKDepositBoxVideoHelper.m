//
//  RBKDepositBoxVideoHelper.m
//  RBKDepositBoxManager
//
//  Created by Jen on 2013-07-23.
//  Copyright (c) 2013 Robots & Pencils. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "RBKDepositBoxVideoHelper.h"
#import "UIImage+RBKDepositBox.h"

@implementation RBKDepositBoxVideoHelper

- (void)saveToDepositBox:(NSData *)videoData andThumbnail:(NSData *)thumbnailData withUUID:(NSString *)uuid  thumbnailCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)thumbnailBlock videoCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)videoBlock {
    
    if (!thumbnailData) {
        thumbnailData = [self generateThumbnailForVideo:videoData];
    }
    
    [thumbnailData writeToFile:[self thumbnailFilePathStringForUUID:uuid] atomically:NO];    
    [self uploadFileAtPath:[self thumbnailFilePathStringForUUID:uuid]
                  mimeType:@"image/jpg"
      toDepositBoxWithUUID:[self thumbnailUUID:uuid]
    fileExistsOnDepositBox:NO
         completionHandler:^(BOOL suceeded) {
             if (thumbnailBlock) thumbnailBlock(suceeded);
         }];
    
    [videoData writeToFile:[self videoFilePathStringForUUID:uuid] atomically:NO];    
    [self uploadFileAtPath:[self videoFilePathStringForUUID:uuid]
                  mimeType:@"video/quicktime"
      toDepositBoxWithUUID:uuid
    fileExistsOnDepositBox:NO
         completionHandler:^(BOOL suceeded) {
             if (videoBlock) videoBlock(suceeded);
         }];
}

- (void)loadVideoForUUID:(NSString *)uuid progressBlock:(RBKDepositBoxReadProgressBlock)progressBlock completionBlock:(VideoLoadingBlock)completionBlock {
    [self loadVideoFilePath:[self videoFilePathStringForUUID:uuid] orFromDepositBoxWithUUID:uuid progressBlock:progressBlock completionBlock:completionBlock];
}

- (void)loadVideoThumbnailForUUID:(NSString *)uuid completionBlock:(ThumbnailLoadingBlock)completionBlock {
    [self loadThumbnailFilePath:[self thumbnailFilePathStringForUUID:uuid] orFromDepositBoxWithUUID:[self thumbnailUUID:uuid] completionBlock:completionBlock];
}

#pragma mark Private Methods
- (NSString *)videoFilePathStringForUUID:(NSString *)uuid {
    return [self filePathForUUID:uuid withModifier:nil extension:@"mov"];
}

- (void)loadVideoFilePath:(NSString *)filePath orFromDepositBoxWithUUID:(NSString *)uuid progressBlock:(RBKDepositBoxReadProgressBlock)progressBlock completionBlock:(VideoLoadingBlock)completionBlock {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:filePath]) {
            NSURL *videoURL = [NSURL fileURLWithPath:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(videoURL, nil);
            });
        } else {
            [self downloadFileToPath:filePath fromDepositBoxWithUUID:uuid progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                if (progressBlock) {
                    progressBlock(bytesRead, totalBytesRead, totalBytesExpectedToRead);
                }
            } completionHandler:^(BOOL suceeded) {
                if (suceeded) {
                    NSURL *videoURL = [NSURL fileURLWithPath:filePath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(videoURL, nil);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(nil, [NSError errorWithDomain:@"not implemented" code:1 userInfo:nil]);
                    });
                }
            }];
        }
    });
}

- (void)loadThumbnailFilePath:(NSString *)filePath orFromDepositBoxWithUUID:(NSString *)uuid completionBlock:(ThumbnailLoadingBlock)completionBlock {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:filePath]) {
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image, nil);
            });
        } else {            
            [self downloadFileToPath:filePath fromDepositBoxWithUUID:uuid completionHandler:^(BOOL suceeded, BOOL fileDoesNotExist) {
                if (suceeded) {
                    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(image, nil);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(nil, [NSError errorWithDomain:@"not implemented" code:1 userInfo:nil]);
                    });
                }
            }];
        }
    });
}

- (NSData *)generateThumbnailForVideo:(NSData *)videoData {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *videoFilePath = [docsDir stringByAppendingPathComponent:@"videoTMP.mov"];
    [videoData writeToFile:videoFilePath atomically:YES];
    NSURL *videoURL = [NSURL fileURLWithPath:videoFilePath];

    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
    return UIImageJPEGRepresentation(thumbnail, 0.8);
}
@end
