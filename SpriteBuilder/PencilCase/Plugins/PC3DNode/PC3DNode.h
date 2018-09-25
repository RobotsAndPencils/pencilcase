//
//  PC3DNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2/21/2014.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PC3DNode.h"

@class PC3DAnimation;

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

@interface PC3DNode : SKSpriteNode

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) CGFloat xRotation3D;
@property (nonatomic, assign) CGFloat yRotation3D;
@property (nonatomic, assign) CGFloat zRotation3D;

@property (strong, nonatomic) NSMutableDictionary *cachedAnimations;
@property (copy, nonatomic) NSString *selectedAnimationName;
@property (readonly, strong, nonatomic) PC3DAnimation *selectedAnimation;

@property (strong, nonatomic) NSDictionary *materials;;

- (NSArray *)materialsForNode:(SCNNode *)node;
- (NSArray *)materialNames;
- (void)refreshAnimations;
- (NSArray *)allSkeletonNames;
- (void)saveCachedAnimations;
- (BOOL)isPC3DAnimationNode;
- (void)runAnimation:(NSString *)key;

@end
