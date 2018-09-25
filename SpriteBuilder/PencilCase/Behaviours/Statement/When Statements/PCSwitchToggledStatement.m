//
//  PCSwitchToggledStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCSwitchToggledStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "PCTokenVariableDescriptor.h"
#import "PCTokenFutureNodeDescriptor.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "NSString+CamelCase.h"

@interface PCSwitchToggledStatement ()

@property (strong, nonatomic) PCExpression *switchExpression;
@property (strong, nonatomic) PCExpression *stateExpression;

@end

@implementation PCSwitchToggledStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCSwitchToggledStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.switchExpression = [[PCExpression alloc] init];
        self.switchExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.stateExpression = [[PCExpression alloc] init];

        [self appendString:@"When switch "];
        [self appendExpression:self.switchExpression];
        [self appendString:@" is toggled to state "];
        [self appendExpression:self.stateExpression];

        PCTokenNodeVariableDescriptor *switchDescriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:PCNodeTypeSwitch variableName:@"ToggledSwitch" sourceUUID:self.UUID];
        PCToken *switchToken = [PCToken tokenWithDescriptor:switchDescriptor];
        [self exposeToken:switchToken key:@"Switch"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.switchExpression) {
        return [self switchTokensForExpression:expression];
    }
    if (expression == self.stateExpression) {
        return [self stateTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)switchTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeSwitch) ]];
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