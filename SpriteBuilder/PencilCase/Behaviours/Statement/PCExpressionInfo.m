//
//  PCTokenStringInfo.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-17.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCExpressionInfo.h"

@implementation PCExpressionInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _UUID = [NSUUID UUID];
    }
    return self;
}

@end
