//
//  PCLongPressStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCLongPressStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenVariableDescriptor.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "PCBehavioursDataSource.h"

@interface PCLongPressStatement ()

@property (strong, nonatomic) PCExpression *objectExpression;

@end

@implementation PCLongPressStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCLongPressStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objectExpression = [[PCExpression alloc] init];
        self.objectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When "];
        [self appendExpression:self.objectExpression];
        [self appendString:@" is tapped and held"];

        PCTokenVariableDescriptor *longPressLocation = [PCTokenVariableDescriptor descriptorWithVariableName:@"LongPressLocation" evaluationType:PCTokenEvaluationTypePoint sourceUUID:self.UUID];
        PCToken *longPressLocationToken = [PCToken tokenWithDescriptor:longPressLocation];
        [self exposeToken:longPressLocationToken];

        PCTokenVariableDescriptor *numberOfTaps = [PCTokenVariableDescriptor descriptorWithVariableName:@"NumberOfTaps" evaluationType:PCTokenEvaluationTypeNumber sourceUUID:self.UUID];
        PCToken *numberOfTapsToken = [PCToken tokenWithDescriptor:numberOfTaps];
        [self exposeToken:numberOfTapsToken];

        PCTokenVariableDescriptor *numberOfTouches = [PCTokenVariableDescriptor descriptorWithVariableName:@"NumberOfTouches" evaluationType:PCTokenEvaluationTypeNumber sourceUUID:self.UUID];
        PCToken *numberOfTouchesToken = [PCToken tokenWithDescriptor:numberOfTouches];
        [self exposeToken:numberOfTouchesToken];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak __typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        PCNodeType nodeType = expression.token.nodeType;
        NSString *name = [NSString stringWithFormat:@"Pressed%@", [PCBehavioursDataSource displayNameForObjectType:nodeType]];
        PCTokenNodeVariableDescriptor *descriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:nodeType variableName:name sourceUUID:weakSelf.UUID];
        weakSelf.pressedNodeToken = [PCToken tokenWithDescriptor:descriptor];
    }];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (void)setPressedNodeToken:(PCToken *)token {
    [self exposeToken:token key:@"PressedNode"];
}

@end