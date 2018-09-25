//
//  PCCameraCaptureNode+JSExport.h
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-14.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCCameraCaptureNode.h"

@protocol PCCameraCaptureNodeExport <JSExport>

@property (strong, nonatomic) SKSpriteNode *imageSprite;
@property (weak, nonatomic) SKTexture *spriteFrame;

@end

@interface PCCameraCaptureNode (JSExport) <PCCameraCaptureNodeExport>

@end
