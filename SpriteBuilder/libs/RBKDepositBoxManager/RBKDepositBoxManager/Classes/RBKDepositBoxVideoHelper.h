//
//  RBKDepositBoxVideoHelper.h
//  RBKDepositBoxManager
//
//  Created by Jen on 2013-08-08.
//  Copyright (c) 2013 Robots & Pencils. All rights reserved.
//

#import "RBKDepositBoxManager.h"
#import <UIKit/UIKit.h>

typedef void (^ThumbnailLoadingBlock)(UIImage *image, NSError *error);
typedef void (^VideoLoadingBlock)(NSURL *video, NSError *error);

@interface RBKDepositBoxVideoHelper : RBKDepositBoxManager

- (void)saveToDepositBox:(NSData *)videoData andThumbnail:(NSData *)thumbnailData withUUID:(NSString *)uuid  thumbnailCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)thumbnailBlock videoCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)videoBlock;

- (void)loadVideoForUUID:(NSString *)uuid progressBlock:(RBKDepositBoxReadProgressBlock)progressBlock completionBlock:(VideoLoadingBlock)completionBlock;
- (void)loadVideoThumbnailForUUID:(NSString *)uuid completionBlock:(ThumbnailLoadingBlock)completionBlock;
@end
