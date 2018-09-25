//
//  PCTapStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCTapStatement.h"
#import "PCStatement+Subclass.h"

#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCPopUpExpressionInspector.h"
#import "PCBehavioursDataSource.h"
#import "PCToken.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "PCTokenValueDescriptor.h"
#import "PCTokenVariableDescriptor.h"

@interface PCTapStatement ()

@property (strong, nonatomic) PCExpression *objectExpression;

@end

@implementation PCTapStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCTapStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objectExpression = [[PCExpression alloc] init];
        self.objectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        [self appendString:@"When "];
        [self appendExpression:self.objectExpression];
        [self appendString:@" is tapped"];

        PCTokenVariableDescriptor *tapLocationDescriptor = [PCTokenVariableDescriptor descriptorWithVariableName:@"TapLocation" evaluationType:PCTokenEvaluationTypePoint sourceUUID:self.UUID];
        PCToken *tapLocationToken = [PCToken tokenWithDescriptor:tapLocationDescriptor];
        [self exposeToken:tapLocationToken];

        PCTokenVariableDescriptor *numberOfTapsDescriptor = [PCTokenVariableDescriptor descriptorWithVariableName:@"NumberOfTaps" evaluationType:PCTokenEvaluationTypeNumber sourceUUID:self.UUID];
        PCToken *numberOfTapsToken = [PCToken tokenWithDescriptor:numberOfTapsDescriptor];
        [self exposeToken:numberOfTapsToken];

        PCTokenVariableDescriptor *numberOfTouchesDescriptor = [PCTokenVariableDescriptor descriptorWithVariableName:@"NumberOfTouches" evaluationType:PCTokenEvaluationTypeNumber sourceUUID:self.UUID];
        PCToken *numberOfTouchesToken = [PCToken tokenWithDescriptor:numberOfTouchesDescriptor];
        [self exposeToken:numberOfTouchesToken];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        PCNodeType nodeType = expression.token.nodeType;
        NSString *name = [NSString stringWithFormat:@"Tapped%@", [PCBehavioursDataSource displayNameForObjectType:nodeType]];
        PCTokenNodeVariableDescriptor *descriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:nodeType variableName:name sourceUUID:weakSelf.UUID];
        weakSelf.tappedNodeToken = [PCToken tokenWithDescriptor:descriptor];
    }];
    
    return nil;
}

- (void)setTappedNodeToken:(PCToken *)tappedNodeToken {
    [self exposeToken:tappedNodeToken key:@"TappedNode"];
}

@end
