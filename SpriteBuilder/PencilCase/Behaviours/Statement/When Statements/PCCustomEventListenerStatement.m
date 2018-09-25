//
//  PCCustomEventListenerStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCCustomEventListenerStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStringExpressionInspector.h"

@interface PCCustomEventListenerStatement ()

@property (strong, nonatomic) PCExpression *eventNameExpression;

@end

@implementation PCCustomEventListenerStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCCustomEventListenerStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventNameExpression = [[PCExpression alloc] init];
        self.eventNameExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeString) ];
        [self appendString:@"When custom event "];
        [self appendExpression:self.eventNameExpression];
        [self appendString:@" fires"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createValueInspectorForPropertyType:PCPropertyTypeString expression:self.eventNameExpression];
}

@end
