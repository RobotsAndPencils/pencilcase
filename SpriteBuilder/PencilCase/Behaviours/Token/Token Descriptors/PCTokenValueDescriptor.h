//
//  PCTokenValueDescriptor.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "MTLModel.h"
#import "PCTokenDescriptor.h"
#import "Constants.h"
#import "PCJavaScriptRepresentable.h"

@interface PCTokenValueDescriptor : MTLModel <PCTokenDescriptor, PCJavaScriptRepresentable>

+ (instancetype)descriptorWithName:(NSString *)name evaluationType:(PCTokenEvaluationType)evaluationType value:(NSObject<NSCoding,NSCopying> *)value;

@end
