//
//  RBKDepositBoxAudioHelper.h
//  RBKDepositBoxManager
//
//  Created by Jen on 2013-09-12.
//  Copyright (c) 2013 Robots & Pencils. All rights reserved.
//

#import "RBKDepositBoxManager.h"

typedef void (^AudioLoadingBlock)(NSURL *audio, NSError *error);

@interface RBKDepositBoxAudioHelper : RBKDepositBoxManager

- (void)saveToDepositBox:(NSData *)audioData withUUID:(NSString *)uuid audioCompletionHandler:(RBKDepositBoxManagerBlockWithSuccessFlag)audioBlock;

- (void)loadAudioForUUID:(NSString *)uuid progressBlock:(RBKDepositBoxReadProgressBlock)progressBlock completionBlock:(AudioLoadingBlock)completionBlock;

@end
