//
//  PCTokenFutureNodeDescriptor.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "MTLModel.h"
#import "PCTokenDescriptor.h"
#import "Constants.h"
#import "PCJavaScriptRepresentable.h"

@interface PCTokenFutureNodeDescriptor : MTLModel <PCTokenDescriptor, PCJavaScriptRepresentable>

+ (instancetype)descriptorWithType:(PCNodeType)type variableName:(NSString *)name sourceUUID:(NSUUID *)UUID;

@end
