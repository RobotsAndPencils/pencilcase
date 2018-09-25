//
//  PCCameraCaptureNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-04-02.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCCameraCaptureNode.h"
#import "SKNode+SFGestureRecognizers.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CoordinateConversion.h"
#import <PSAlertView/PSPDFActionSheet.h>
#import "PCAppViewController.h"
#import "PCOverlayView.h"
#import "PCJSContext.h"
#import "UIImage+Orientation.h"
#import "UIImage+Resize.h"
#import "PCConstants.h"

NSString *const PCPresentPhotoLibraryViewController = @"PCPresentPhotoLibraryViewController";
NSString *const PCDismissPhotoLibraryViewController = @"PCDismissPhotoLibraryViewController";

@interface PCCameraCaptureNode () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) SKSpriteNode *cameraIconSprite;
@property (weak, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation PCCameraCaptureNode

- (void)pc_didEnterScene {
    [super pc_didEnterScene];

    //Only add camera supply if we don't have a default background
    if ([self.children count] != 0) return;
    self.cameraIconSprite = [SKSpriteNode spriteNodeWithImageNamed:@"CameraIcon"];
    [self addChild:self.cameraIconSprite];
    [self.cameraIconSprite pc_centerInParent];
}

- (void)pc_presentationCompleted {
    [super pc_presentationCompleted];

    if (self.tapGestureRecognizer) return;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self sf_addGestureRecognizer:tapRecognizer];
    self.tapGestureRecognizer = tapRecognizer;
}

- (void)tapped:(UITapGestureRecognizer *)recognizer {
    if (!self.userInteractionEnabled) return;
    
    UIView *view = [PCOverlayView overlayView];

    SKSpriteNode *sourceSprite = self.imageSprite ?: self.cameraIconSprite;
    CGRect rect = (CGRect){ sourceSprite.frame.origin, sourceSprite.contentSize };
    rect = [[PCOverlayView overlayView] convertRect:rect toOverlayViewFromNode:sourceSprite willAdjustAnchorPointOfView:NO];

    // inset the popover source rect so that it doesn't look squished, or worse, crash the action sheet autolayout fails
    rect = CGRectInset(rect, rect.size.width * 0.25f, rect.size.height * 0.25f);

    __weak typeof(self) _self = self;
    PSPDFActionSheet *actionSheet = [[PSPDFActionSheet alloc] initWithTitle:@"Source"];
    actionSheet.allowsTapToDismiss = YES;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", @"Title for the camera button in the image source picker") block:^(NSInteger buttonIndex) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            PSPDFAlertView *alert = [[PSPDFAlertView alloc] initWithTitle:@"Not Available"];
            alert.message = @"Camera not available on this device.";
            [alert addButtonWithTitle:@"OK"];
            [alert show];
            return;
        }
        _self.imagePicker = [[UIImagePickerController alloc] init];
        _self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _self.imagePicker.delegate = _self;

        // On iOS 8 this needs to be delayed a runloop so the action sheet can dismiss.
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PCAppViewController lastCreatedInstance] presentViewController:_self.imagePicker animated:YES completion:^{}];
        });
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Photo Library", @"Title for the photo library button in the image source picker") block:^(NSInteger buttonIndex) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            PSPDFAlertView *alert = [[PSPDFAlertView alloc] initWithTitle:@"Not Available"];
            alert.message = @"Photo Library not available on this device.";
            [alert addButtonWithTitle:@"OK"];
            [alert show];
            return;
        }
        
        _self.imagePicker = [[UIImagePickerController alloc] init];
        _self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _self.imagePicker.delegate = _self;

        if (IS_IPAD()) {
            // Use popover presentation on iPad
            _self.imagePicker.modalPresentationStyle = UIModalPresentationPopover;
        }

        // On iOS 8 this needs to be delayed a runloop so the action sheet can dismiss.
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PCPresentPhotoLibraryViewController object:self userInfo:@{
                @"viewController" : _self.imagePicker
            }];

            if (IS_IPAD()) {
                // Popover presentation *must* be configured after it has been presented
                UIPopoverPresentationController *popover = _self.imagePicker.popoverPresentationController;
                popover.sourceView = view;
                popover.sourceRect = rect;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
        });
    }];
    [actionSheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:nil];
    [actionSheet showFromRect:rect inView:view animated:YES];
}

- (void)setSpriteFrame:(SKTexture *)texture {
    [self updateImageSpriteWithTexture:texture];
}

- (SKTexture *)spriteFrame {
    return self.imageSprite.texture;
}

- (void)updateImageSpriteWithTexture:(SKTexture *)texture {
    if (!texture) return;
    if (self.imageSprite) [self.imageSprite removeFromParent];

    self.imageSprite = [SKSpriteNode spriteNodeWithTexture:texture];

    CGFloat widthScale = self.contentSize.width / self.imageSprite.contentSize.width;
    CGFloat heightScale = self.contentSize.height / self.imageSprite.contentSize.height;
    
    self.imageSprite.scale = MIN(widthScale, heightScale);
    
    [self addChild:self.imageSprite];
    [self.imageSprite pc_centerInParent];
}

- (void)dismissImagePicker:(UIImagePickerController *)picker {
    if (!picker) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:PCDismissPhotoLibraryViewController object:self userInfo:@{
        @"viewController" : picker
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    image = [image pc_imageAspectConfinedToSize:PCMaxTextureSize];
    SKTexture *texture = [SKTexture textureWithImage:[image rotatedToOrientationUp]];
    [self imagePickerControllerDidPickTexture:texture];

    //Dismiss picker locally so we can use it's completion block to fire the photoCaptured event.
    [picker dismissViewControllerAnimated:YES completion:^{
        NSDictionary *userInfo = @{
            PCJSContextEventNotificationEventNameKey: @"photoCaptured",
            PCJSContextEventNotificationArgumentsKey: @[texture]
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:userInfo];
    }];
}

- (void)imagePickerControllerDidPickTexture:(SKTexture *)texture {
    [self updateImageSpriteWithTexture:texture];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissImagePicker:picker];
}

@end
