//
//  SKTexture+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-28.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import <SpriteKit/SpriteKit.h>
#import "NSObject+JSDataBinding.h"

@protocol SKTextureExport <JSExport, NSObjectJSDataBindingExport>

+ (instancetype)textureWithUUID:(NSString *)uuid;
+ (instancetype)textureWithRelativeImagePath:(NSString *)relativePath;
JSExportAs(textureByApplyingFilter,
- (instancetype)textureByApplyingCIFilter:(CIFilter *)filter
);

- (UIImage *)__pc_UIImage;

@end

@interface SKTexture (JSExport) <SKTextureExport>

@end
