//
//  PCCameraCaptureNodeTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-07.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "SKSpriteNode+JSExport.h"
#import "PCCameraCaptureNode.h"
#import "PCJSContext.h"
#import "UIImage+Orientation.h"

@interface PCCameraCaptureNode (Tests) <UIImagePickerControllerDelegate>

- (void)imagePickerControllerDidPickTexture:(SKTexture *)texture;

@end

SPEC_BEGIN(PCCameraCaptureNodeTests)

__block PCCameraCaptureNode *cameraCaptureNode;
beforeEach(^{
    cameraCaptureNode = [PCCameraCaptureNode new];
});

context(@"When an image is chosen", ^{
    UIImage *image = [UIImage imageNamed:@"testImage.png"];
    __block UIImagePickerController *pickerStub;
    beforeEach(^{
        pickerStub = [UIImagePickerController new];
        [pickerStub stub:@selector(dismissViewControllerAnimated:completion:) withBlock:^id(NSArray *params) {
            if (params.count < 2) {
                return nil;
            }
            void (^completion)(void) = params[1];
            completion();
            return nil;
        }];
    });

    it(@"should fire a JS event", ^{
        [[PCJSContextEventNotificationName should] bePostedWithObject:cameraCaptureNode];
        [cameraCaptureNode imagePickerController:pickerStub didFinishPickingMediaWithInfo:@{ UIImagePickerControllerOriginalImage : image }];
    });

    it(@"should include the event name and texture in the arguments", ^{
        SKTexture *texture = [SKTexture textureWithImage:[image rotatedToOrientationUp]];
        // We don't _really_ care about them being the same in this test, and they are anyways, but the default imp won't report that because the texture copies the image's data
        [texture stub:@selector(isEqual:) andReturn:@YES];

        [[PCJSContextEventNotificationName should] bePostedWithObject:cameraCaptureNode andUserInfo:@{
            PCJSContextEventNotificationEventNameKey: @"photoCaptured",
            PCJSContextEventNotificationArgumentsKey: @[texture]
        }];
        [cameraCaptureNode imagePickerController:pickerStub didFinishPickingMediaWithInfo:@{ UIImagePickerControllerOriginalImage : image }];
    });
});

SPEC_END
