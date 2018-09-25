//
//  PC3DNode+JSExport.h
//  PencilCase
//
//  Created by Michael Beauregard on 02/27/2015.
//  Copyright (c) 2015 Robots and Pencils. All rights reserved.
//

@import JavaScriptCore;
#import "PC3DNode.h"
#import "NSObject+JSDataBinding.h"

@class PC3DAnimation;

@protocol PC3DNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic, assign) CGFloat xRotation3D;
@property (nonatomic, assign) CGFloat yRotation3D;
@property (nonatomic, assign) CGFloat zRotation3D;

JSExportAs(setMaterialTexture,
- (void)setMaterialTexture:(UIImage *)image materialType:(PC3DMaterialType)materialType materialName:(NSString *)materialName intensity:(CGFloat)intensity
);
JSExportAs(setMaterialColor,
- (void)setMaterialColor:(UIColor *)color materialType:(PC3DMaterialType)materialType materialName:(NSString *)materialName intensity:(CGFloat)intensity
);
JSExportAs(setMaterialLocksAmbientWithDiffuse,
- (void)setMaterialLocksAmbientWithDiffuse:(BOOL)value materialName:(NSString *)materialName
);
JSExportAs(setMaterialFresnelExponent,
- (void)setMaterialFresnelExponent:(CGFloat)value materialName:(NSString *)materialName
);
JSExportAs(setMaterialShininess,
- (void)setMaterialShininess:(CGFloat)value materialName:(NSString *)materialName
);

- (void)runAnimation:(NSString *)key;
- (void)stopAnimation:(NSString *)key; 
- (PC3DAnimation *)animationWithName:(NSString *)animationName;

@end

@interface PC3DNode (JSExport) <PC3DNodeExport>

@end
