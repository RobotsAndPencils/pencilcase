//
//  PCSwitchNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-11.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCOverlayNode.h"

@interface PCSwitchNode : SKSpriteNode <PCOverlayNode>

@property (assign, nonatomic) BOOL isOn;

@end
