//
//  PCJSImagePickerDelegate.m
//  
//
//  Created by Stephen Gazzard on 2015-02-25.
//
//

#import "PCJSImagePickerDelegate.h"
#import "PCOverlayView.h"
#import "PCCameraCaptureNode.h"

@interface PCJSImagePickerDelegate() <UIImagePickerControllerDelegate>

@property (strong, nonatomic) PCJSImagePickerDelegate *retainCycleHack;
@property (strong, nonatomic) JSValue *value;
@property (copy, nonatomic) dispatch_block_t callback;

@end

@implementation PCJSImagePickerDelegate

+ (void)observeDelegateCallbacksFrom:(UIImagePickerController *)imagePickerController informingValueWhenFinished:(JSValue *)value {
    [[PCJSImagePickerDelegate alloc] initAsDelegateOf:imagePickerController value:value];
}

- (id)initAsDelegateOf:(UIImagePickerController *)picker value:(JSValue *)value {
    self = [super init];
    if (self) {
        picker.delegate = self;
        self.retainCycleHack = self;
        self.value = value;
    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    SKTexture *texture = [SKTexture textureWithImage:image];
    [self.value callWithArguments:@[texture]];
    [self dismissImagePicker:picker];
    self.retainCycleHack = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.value callWithArguments:@[]];
    [self dismissImagePicker:picker];
    self.retainCycleHack = nil;
}

- (void)dismissImagePicker:(UIImagePickerController *)picker {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCDismissPhotoLibraryViewController object:self userInfo:@{ @"viewController" : picker }];
}


@end
