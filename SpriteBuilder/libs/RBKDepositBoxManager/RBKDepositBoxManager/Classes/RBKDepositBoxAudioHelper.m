//
//  RBKDepositBoxAudioHelper.m
//  RBKDepositBoxManager
//
//  Created by Jen on 2013-09-12.
//  Copyright (c) 2013 Robots & Pencils. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "RBKDepositBoxAudioHelper.h"
#import "UIImage+RBKDepositBox.h"

@implementation RBKDepositBoxAudioHelper

- (void)saveToDepositBox:(NSData *)audioData withUUID:(NSString *)uuid audioCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)audioBlock {
    
    [audioData writeToFile:[self audioFilePathStringForUUID:uuid] atomically:NO];    
    [self uploadFileAtPath:[self audioFilePathStringForUUID:uuid]
                  mimeType:@"audio/x-caf"
      toDepositBoxWithUUID:uuid
    fileExistsOnDepositBox:NO
         completionHandler:^(BOOL suceeded) {
             if (audioBlock) audioBlock(suceeded);
         }];
}

- (void)loadAudioForUUID:(NSString *)uuid progressBlock:(RBKDepositBoxReadProgressBlock)progressBlock completionBlock:(AudioLoadingBlock)completionBlock {
    [self loadAudioFilePath:[self audioFilePathStringForUUID:uuid] orFromDepositBoxWithUUID:uuid progressBlock:progressBlock completionBlock:completionBlock];
}

#pragma mark Private Methods
- (NSString *)audioFilePathStringForUUID:(NSString *)uuid {
    return [self filePathForUUID:uuid withModifier:nil extension:@"caf"];
}

- (void)loadAudioFilePath:(NSString *)filePath orFromDepositBoxWithUUID:(NSString *)uuid progressBlock:(RBKDepositBoxReadProgressBlock)progressBlock completionBlock:(AudioLoadingBlock)completionBlock {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:filePath]) {
            NSURL *audioURL = [NSURL fileURLWithPath:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(audioURL, nil);
            });
        } else {
            [self downloadFileToPath:filePath fromDepositBoxWithUUID:uuid progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                if (progressBlock) {
                    progressBlock(bytesRead, totalBytesRead, totalBytesExpectedToRead);
                }
            } completionHandler:^(BOOL suceeded) {
                if (suceeded) {
                    NSURL *audioURL = [NSURL fileURLWithPath:filePath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(audioURL, nil);
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

@end
