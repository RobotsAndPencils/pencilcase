//
//  PCTokenVariableDescriptor.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-04.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "MTLModel.h"
#import "PCTokenDescriptor.h"
#import "Constants.h"
#import "PCJavaScriptRepresentable.h"

@interface PCTokenVariableDescriptor : MTLModel <PCTokenDescriptor, PCJavaScriptRepresentable>

+ (instancetype)descriptorWithVariableName:(NSString *)name evaluationType:(PCTokenEvaluationType)evaluationType sourceUUID:(NSUUID *)sourceUUID;

@end
