//
//  PCTokenVariableDescriptor.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "MTLModel.h"
#import "PCTokenDescriptor.h"
#import "Constants.h"
#import "PCJavaScriptRepresentable.h"

@interface PCTokenNodeVariableDescriptor : MTLModel <PCTokenDescriptor, PCJavaScriptRepresentable>

+ (instancetype)descriptorWithNodeType:(PCNodeType)nodeType variableName:(NSString *)name sourceUUID:(NSUUID *)UUID;

@end
