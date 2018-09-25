//
//  PCTextInputBeganStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCTextInputBeganStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"

@interface PCTextInputBeganStatement ()

@property (strong, nonatomic) PCExpression *textInputNodeExpression;

@end

@implementation PCTextInputBeganStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCTextInputBeganStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.textInputNodeExpression = [[PCExpression alloc] init];
        self.textInputNodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When editing begins in text input "];
        [self appendExpression:self.textInputNodeExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.textInputNodeExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self textInputTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

#pragma mark - Private

- (NSArray *)textInputTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[self availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeTextInput) ]];
}

@end