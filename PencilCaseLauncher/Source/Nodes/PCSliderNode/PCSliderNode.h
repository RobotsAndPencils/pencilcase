//
//  PCSliderNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-12.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCOverlayNode.h"

@interface PCSliderNode : SKSpriteNode <PCOverlayNode>

@property (assign, nonatomic) CGFloat minimumValue;
@property (assign, nonatomic) CGFloat maximumValue;
@property (assign, nonatomic) CGFloat currentValue;

@end
