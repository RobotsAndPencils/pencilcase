//
//  PCShapeNode.h
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2014-05-16.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCOverlayNode.h"

@class PCShapeView;

@interface PCShapeNode : SKSpriteNode <PCOverlayNode>

@property (strong, nonatomic) NSMutableDictionary *shapeInfo;
@property (strong, nonatomic) PCShapeView *shapeView;

@end
