//
//  PCCameraCaptureNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-04-02.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

extern NSString * const PCPresentPhotoLibraryViewController;
extern NSString * const PCDismissPhotoLibraryViewController;

@interface PCCameraCaptureNode : SKSpriteNode

@property (strong, nonatomic) SKSpriteNode *imageSprite;

/**
 Exposes the texture of our selected sprite frame so user may set / read it via behaviours, JS
 */
@property (weak, nonatomic) SKTexture *spriteFrame;

@end
