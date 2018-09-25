//
//  PCSprite+JSExport.h
//  PCPlayer
//
//  Created by Brandon on 2014-02-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCSprite.h"
#import "NSObject+JSDataBinding.h"

@protocol PCSpriteExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic, strong) SKTexture *spriteFrame;
@property (nonatomic, strong) UIColor *colorRGBA;

// Expects the image's filename without extension, as it appears in the asset browser
// e.g. `CCSprite.spriteWithImage('rbkRobot');
JSExportAs(imageViewWithName,
+ (id)spriteWithImage:(NSString *)name
);

@end

@interface PCSprite (JSExport) <PCSpriteExport>

+ (id)spriteWithImage:(NSString *)name;

@end
