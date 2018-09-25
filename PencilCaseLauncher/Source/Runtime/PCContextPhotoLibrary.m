//
//  PCContextPhotoLibrary.m
//  Pods
//
//  Created by Stephen Gazzard on 2015-02-24.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
@import Photos;
@import SpriteKit;

#import "PCContextPhotoLibrary.h"
#import <PSPDFActionSheet.h>
#import "PCAppViewController.h"
#import "PCOverlayView.h"
#import "PCCameraCaptureNode.h"
#import "PCJSImagePickerDelegate.h"

@implementation PCContextPhotoLibrary

+ (void)requestPermissionIfNecessaryWithCompletion:(dispatch_block_t)completion {
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusNotDetermined) {
        completion();
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        completion();
    }];
}

+ (void)loadLastImageFromPhotoLibrary:(JSValue *)value {
    [self requestPermissionIfNecessaryWithCompletion:^{
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        if (0 == fetchResult.count) {
            PCLog(@"There were no images to load");
            [value callWithArguments:@[]];
            return;
        }
        PHAsset *lastImage = fetchResult[fetchResult.count - 1];
        PHImageRequestOptions *options;
        options.version = PHImageRequestOptionsVersionOriginal;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        [[PHImageManager defaultManager] requestImageForAsset:lastImage targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (!result) {
                PCLog(@"Failed to get image: %@", info);
                [value callWithArguments:@[]];
                return;
            }
            SKTexture *texture = [SKTexture textureWithImage:result];
            [value callWithArguments:@[texture]];
        }];
    }];
}

+ (void)selectImageWithSource:(UIImagePickerControllerSourceType)source withJSValue:(JSValue *)jsValue
{
    if (![UIImagePickerController isSourceTypeAvailable:source]) {
        PSPDFAlertView *alert = [[PSPDFAlertView alloc] initWithTitle:@"Not Available"];
        alert.message = @"Camera not available on this device.";
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = source;

    [PCJSImagePickerDelegate observeDelegateCallbacksFrom:imagePicker informingValueWhenFinished:jsValue];

    // On iOS 8 this needs to be delayed a runloop so the action sheet can dismiss.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PCAppViewController lastCreatedInstance] presentViewController:imagePicker animated:YES completion:^{}];
    });
}

+ (void)showPhotoSelectorFromNode:(SKNode *)node withJSValue:(JSValue *)jsValue {
    __weak typeof(self) _self = self;
    PSPDFActionSheet *actionSheet = [[PSPDFActionSheet alloc] initWithTitle:@"Source"];
    actionSheet.allowsTapToDismiss = YES;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", @"Title for the camera button in the image source picker") block:^(NSInteger buttonIndex) {
        [_self selectImageWithSource:UIImagePickerControllerSourceTypeCamera withJSValue:jsValue];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Photo Library", @"Title for the photo library button in the image source picker") block:^(NSInteger buttonIndex) {
        [_self selectImageWithSource:UIImagePickerControllerSourceTypePhotoLibrary withJSValue:jsValue];
    }];
    [actionSheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:nil];
    [actionSheet addCancelBlock:^(NSInteger buttonIndex){
        [jsValue callWithArguments:@[]];
    }];
    CGRect rect = [[PCOverlayView overlayView] rectForPopoverOriginatingFromNode:node];
    [actionSheet showFromRect:rect inView:[PCOverlayView overlayView] animated:YES];
}

#pragma mark - RPJSCoreModule

+ (void)setupInContext:(JSContext *)context {
    context[@"__photoLibrary_loadLastImage"] = ^(JSValue *value) {
        [self loadLastImageFromPhotoLibrary:value];
    };
    context[@"__photoLibrary_showPhotoSelector"] = ^(SKNode *node, JSValue *value) {
        [self showPhotoSelectorFromNode:node withJSValue:value];
    };
}

@end
