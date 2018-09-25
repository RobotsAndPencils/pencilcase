//
//  PCKeyPressedStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCKeyPressedStatement.h"
#import "PCStatement+Subclass.h"
#import "PCExpression.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"

@implementation PCKeyPressedStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCKeyPressedStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keyExpression = [[PCExpression alloc] init];
        [self appendString:@"When the key "];
        [self appendExpression:self.keyExpression];
        [self appendString:@" is pressed"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createValueInspectorForPropertyType:PCPropertyTypeKeyboardInput expression:self.keyExpression];
}

@end
