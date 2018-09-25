//
//  PCSliderValueChangedStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCSliderValueChangedStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenFutureNodeDescriptor.h"
#import "PCTokenNodeVariableDescriptor.h"

@interface PCSliderValueChangedStatement ()

@property (strong, nonatomic) PCExpression *sliderExpression;

@end

@implementation PCSliderValueChangedStatement

__attribute__((constructor)) static void registerStatement(void) {
        [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCSliderValueChangedStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sliderExpression = [[PCExpression alloc] init];
        self.sliderExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When the value changes on slider "];
        [self appendExpression:self.sliderExpression];

        PCTokenNodeVariableDescriptor *sliderDescriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:PCNodeTypeSlider variableName:@"ChangedSlider" sourceUUID:self.UUID];
        PCToken *sliderToken = [PCToken tokenWithDescriptor:sliderDescriptor];
        [self exposeToken:sliderToken key:@"slider"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.sliderExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self sliderTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

#pragma mark - Private

- (NSArray *)sliderTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[self availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeSlider) ]];
}

@end
