//
//  PCPinchStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCPinchStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "NSString+CamelCase.h"
#import "PCTokenVariableDescriptor.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "PCBehavioursDataSource.h"

@interface PCPinchStatement ()

@property (strong, nonatomic) PCExpression *objectExpression;
@property (strong, nonatomic) PCExpression *pinchDirectionExpression;

@end

@implementation PCPinchStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCPinchStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objectExpression = [[PCExpression alloc] init];
        self.objectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.pinchDirectionExpression = [[PCExpression alloc] init];

        [self appendString:@"When a "];
        [self appendExpression:self.pinchDirectionExpression];
        [self appendString:@" pinch gesture is recognized on object "];
        [self appendExpression:self.objectExpression];

        PCTokenVariableDescriptor *pinchLocation = [PCTokenVariableDescriptor descriptorWithVariableName:@"PinchLocation" evaluationType:PCTokenEvaluationTypePoint sourceUUID:self.UUID];
        PCToken *swipeLocationToken = [PCToken tokenWithDescriptor:pinchLocation];
        [self exposeToken:swipeLocationToken];

        PCTokenVariableDescriptor *pinchDirection = [PCTokenVariableDescriptor descriptorWithVariableName:@"PinchDirection" evaluationType:PCTokenEvaluationTypeString sourceUUID:self.UUID];
        PCToken *pinchDirectionToken = [PCToken tokenWithDescriptor:pinchDirection];
        [self exposeToken:pinchDirectionToken];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak __typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        if (expression != self.objectExpression) return;

        PCNodeType nodeType = expression.token.nodeType;
        NSString *name = [NSString stringWithFormat:@"Pinched%@", [PCBehavioursDataSource displayNameForObjectType:nodeType]];
        PCTokenNodeVariableDescriptor *descriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:nodeType variableName:name sourceUUID:weakSelf.UUID];
        weakSelf.pinchedNodeToken = [PCToken tokenWithDescriptor:descriptor];
    }];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.pinchDirectionExpression) {
        return [self pinchDirectionTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)pinchDirectionTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSArray *names = @[ @"Open", @"Close" ];
    for (NSString *name in names) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeString value:[name pc_lowerCamelCaseString]];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }
    return [tokens copy];
}

- (void)setPinchedNodeToken:(PCToken *)token {
    [self exposeToken:token key:@"PinchedNode"];
}

@end