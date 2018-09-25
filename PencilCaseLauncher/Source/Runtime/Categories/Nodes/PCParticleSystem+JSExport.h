//
//  PCParticleSystem+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-28.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCParticleSystem.h"
#import "NSObject+JSDataBinding.h"

@protocol PCParticleSystemExport <JSExport, NSObjectJSDataBindingExport>

// PCParticleNode
@property (assign, nonatomic) CGFloat birthRate;
@property (assign, nonatomic) CGFloat savedBirthRate;
@property (assign, nonatomic) CGFloat particleRotationDegrees;
@property (assign, nonatomic) CGFloat particleRotationDegreesRange;
@property (assign, nonatomic) CGFloat emissionAngleDegrees;
@property (assign, nonatomic) CGFloat emissionAngleDegreesRange;
@property (strong, nonatomic) SKColor *startColor;
@property (strong, nonatomic) SKColor *endColor;
@property (assign, nonatomic) BOOL resetOnVisibilityToggle;
@property (assign, nonatomic) CGPoint gravity;

- (void)setTextureFromRelativePath:(NSString *)path;

// Forwarded to emitter node
@property (nonatomic, retain) SKTexture *particleTexture;
@property (nonatomic) CGFloat particleZPosition;
@property (nonatomic) CGFloat particleZPositionRange;
@property (nonatomic) CGFloat particleZPositionSpeed;
@property (nonatomic) SKBlendMode particleBlendMode;
@property (nonatomic, retain) SKColor *particleColor;
@property (nonatomic) CGFloat particleColorRedRange;
@property (nonatomic) CGFloat particleColorGreenRange;
@property (nonatomic) CGFloat particleColorBlueRange;
@property (nonatomic) CGFloat particleColorAlphaRange;
@property (nonatomic) CGFloat particleColorRedSpeed;
@property (nonatomic) CGFloat particleColorGreenSpeed;
@property (nonatomic) CGFloat particleColorBlueSpeed;
@property (nonatomic) CGFloat particleColorAlphaSpeed;
@property (nonatomic) CGFloat particleColorBlendFactor;
@property (nonatomic) CGFloat particleColorBlendFactorRange;
@property (nonatomic) CGFloat particleColorBlendFactorSpeed;
@property (nonatomic) CGPoint particlePosition;
@property (nonatomic) CGVector particlePositionRange;
@property (nonatomic) CGFloat particleSpeed;
@property (nonatomic) CGFloat particleSpeedRange;
@property (nonatomic) CGFloat emissionAngle;
@property (nonatomic) CGFloat emissionAngleRange;
@property (nonatomic) CGFloat xAcceleration;
@property (nonatomic) CGFloat yAcceleration;
@property (nonatomic) CGFloat particleBirthRate;
@property (nonatomic) NSUInteger numParticlesToEmit;
@property (nonatomic) CGFloat particleLifetime;
@property (nonatomic) CGFloat particleLifetimeRange;
@property (nonatomic) CGFloat particleRotation;
@property (nonatomic) CGFloat particleRotationRange;
@property (nonatomic) CGFloat particleRotationSpeed;
@property (nonatomic) CGSize particleSize;
@property (nonatomic) CGFloat particleScale;
@property (nonatomic) CGFloat particleScaleRange;
@property (nonatomic) CGFloat particleScaleSpeed;
@property (nonatomic) CGFloat particleAlpha;
@property (nonatomic) CGFloat particleAlphaRange;
@property (nonatomic) CGFloat particleAlphaSpeed;
@property (nonatomic, copy) SKAction *particleAction;
@property (nonatomic, weak) SKNode *targetNode;

// SKNode+Template
+ (instancetype)fromTemplateNamed:(NSString *)name;

@end

@interface PCParticleSystem (JSExport) <PCParticleSystemExport>

@end
