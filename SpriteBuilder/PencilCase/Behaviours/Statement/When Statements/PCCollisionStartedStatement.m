//
//  PCCollisionStartedStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCCollisionStartedStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"

@interface PCCollisionStartedStatement ()

@property (strong, nonatomic) PCExpression *firstObjectExpression;
@property (strong, nonatomic) PCExpression *secondObjectExpression;

@end

@implementation PCCollisionStartedStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCCollisionStartedStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.firstObjectExpression = [[PCExpression alloc] init];
        self.firstObjectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.secondObjectExpression = [[PCExpression alloc] init];
        self.secondObjectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When "];
        [self appendExpression:self.firstObjectExpression];
        [self appendString:@" collides with "];
        [self appendExpression:self.secondObjectExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.firstObjectExpression || expression == self.secondObjectExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

@end

