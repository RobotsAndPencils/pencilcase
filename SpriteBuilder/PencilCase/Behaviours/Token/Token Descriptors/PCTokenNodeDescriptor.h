//
//  PCNodeTokenDescriptor.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "MTLModel.h"
#import "PCTokenDescriptor.h"
#import "PCJavaScriptRepresentable.h"

@interface PCTokenNodeDescriptor : MTLModel <PCTokenDescriptor, PCJavaScriptRepresentable>

@property (assign, nonatomic, readonly) PCNodeType nodeType;

+ (instancetype)descriptorWithNodeUUID:(NSUUID *)UUID nodeType:(PCNodeType)nodeType;

@end
