//
//  PCMultiViewFocusChangedStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCMultiViewFocusChangedStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "PCBehavioursDataSource.h"

@interface PCMultiViewFocusChangedStatement ()

@property (strong, nonatomic) PCExpression *multiViewExpression;
@property (strong, nonatomic) PCExpression *changeIndexExpression;

@end

@implementation PCMultiViewFocusChangedStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCMultiViewFocusChangedStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.multiViewExpression = [[PCExpression alloc] init];
        self.multiViewExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.changeIndexExpression = [[PCExpression alloc] init];

        [self appendString:@"When the focus of multi view "];
        [self appendExpression:self.multiViewExpression];
        [self appendString:@" changes to view "];
        [self appendExpression:self.changeIndexExpression withOrder:1];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.multiViewExpression) {
        return [self multiViewTokensForExpression:expression];
    }
    if (expression == self.changeIndexExpression) {
        return [PCBehavioursDataSource viewTokensForMultiViewToken:self.multiViewExpression.token indicesOnly:YES];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)multiViewTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeMultiView) ]];
}

@end
