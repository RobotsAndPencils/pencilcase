//
//  PC3DNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-03-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//
#import <SpriteKit/SpriteKit.h>

typedef enum PC3DMaterialType {
    PC3DMaterialTypeDiffuse = 0,
    PC3DMaterialTypeAmbient,
    PC3DMaterialTypeSpecular,
    PC3DMaterialTypeNormal,
    PC3DMaterialTypeReflective,
    PC3DMaterialTypeEmission,
    PC3DMaterialTypeTransparent,
    PC3DMaterialTypeMultiply
} PC3DMaterialType;

@class PC3DAnimation; 

@interface PC3DNode : SKSpriteNode

@property (nonatomic, assign) CGFloat xRotation3D;
@property (nonatomic, assign) CGFloat yRotation3D;
@property (nonatomic, assign) CGFloat zRotation3D;
@property (strong, nonatomic) NSMutableDictionary *cachedAnimations;
@property (strong, nonatomic) NSString *selectedAnimationName;
@property (readonly, strong, nonatomic) PC3DAnimation *selectedAnimation;
@property (strong, nonatomic) NSDictionary *materials;

@end
