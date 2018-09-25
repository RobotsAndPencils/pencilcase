//
//  RBKDepositBoxImageHelper.h
//  RBKDepositBoxManager
//
//  Created by Matt KiazykNew on 2013-07-23.
//  Copyright (c) 2013 Robots & Pencils. All rights reserved.
//

#import "RBKDepositBoxManager.h"
#import <UIKit/UIKit.h>

typedef void (^ImageLoadingBlock)(UIImage *image, NSError *error);

@interface RBKDepositBoxImageHelper : RBKDepositBoxManager

@property (nonatomic) CGFloat thumbnailCompression;
@property (nonatomic) CGFloat thumbnailHeight;

- (void)saveToDepositBox:(UIImage *)image withUUID:(NSString *)uuid thumbnailCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)thumbnailBlock fullsizeCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)fullsizeBlock;
- (void)loadFullsizeImageForUUID:(NSString *)uuid withBlock:(ImageLoadingBlock)block;
- (void)loadThumbnailImageForUUID:(NSString *)uuid withBlock:(ImageLoadingBlock)block;
@end
