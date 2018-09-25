//
//  PCButtonToggledStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCButtonToggledStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "NSString+CamelCase.h"
#import "PCTokenNodeVariableDescriptor.h"

@interface PCButtonToggledStatement ()

@property (strong, nonatomic) PCExpression *buttonExpression;
@property (strong, nonatomic) PCExpression *stateExpression;

@end

@implementation PCButtonToggledStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCButtonToggledStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.buttonExpression = [[PCExpression alloc] init];
        self.buttonExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.stateExpression = [[PCExpression alloc] init];

        [self appendString:@"When button "];
        [self appendExpression:self.buttonExpression];
        [self appendString:@" is toggled to state "];
        [self appendExpression:self.stateExpression];

        PCTokenNodeVariableDescriptor *buttonDescriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:PCNodeTypeButton variableName:@"ToggledButton" sourceUUID:self.UUID];
        PCToken *buttonToken = [PCToken tokenWithDescriptor:buttonDescriptor];
        [self exposeToken:buttonToken key:@"Button"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.buttonExpression) {
        return [self buttonTokensForExpression:expression];
    }
    if (expression == self.stateExpression) {
        return [self stateTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)buttonTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeButton) ]];
}

- (NSArray *)stateTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSArray *names = @[ @"Any", @"On", @"Off" ];
    for (NSString *name in names) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeString value:[name pc_lowerCamelCaseString]];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    };
    return [tokens copy];
}

@end