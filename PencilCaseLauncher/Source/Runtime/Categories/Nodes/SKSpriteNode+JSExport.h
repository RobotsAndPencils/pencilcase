//
//  SKSpriteNode+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-20.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "NSObject+JSDataBinding.h"

@protocol SKSpriteNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic, retain) SKTexture *texture;
@property (nonatomic, retain) SKTexture *normalTexture NS_AVAILABLE(10_10, 8_0);
@property (nonatomic) uint32_t lightingBitMask NS_AVAILABLE(10_10, 8_0);
@property (nonatomic) uint32_t shadowCastBitMask NS_AVAILABLE(10_10, 8_0);
@property (nonatomic) uint32_t shadowedBitMask NS_AVAILABLE(10_10, 8_0);
@property (nonatomic) CGRect centerRect;
@property (nonatomic) CGFloat colorBlendFactor;
@property (nonatomic, retain) SKColor *color;
@property (nonatomic) SKBlendMode blendMode;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) CGSize size;
@property (nonatomic, retain) SKShader *shader NS_AVAILABLE(10_10, 8_0);

@end

@interface SKSpriteNode (JSExport) <SKSpriteNodeExport>

@end
