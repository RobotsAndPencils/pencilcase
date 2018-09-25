//
//  PCCardLoadStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCCardLoadStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"

@interface PCCardLoadStatement ()

@end

@implementation PCCardLoadStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCCardLoadStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self appendString:@"When card loads"];
    }
    return self;
}

@end
