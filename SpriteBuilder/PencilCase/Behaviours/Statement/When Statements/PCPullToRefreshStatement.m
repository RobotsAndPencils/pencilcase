//
//  PCPullToRefreshStatement.m
//  Behaviours
//
//  Created by Michael Beauregard on 15-02-23.
//  Copyright (c) 2015 Robots and Pencils. All rights reserved.
//

#import "PCPullToRefreshStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "PCStatement+Subclass.h"

@interface PCPullToRefreshStatement ()
@property (nonatomic, strong) PCExpression *tableExpression;
@end

@implementation PCPullToRefreshStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCPullToRefreshStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableExpression = [[PCExpression alloc] init];
        self.tableExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When table "];
        [self appendExpression:self.tableExpression];
        [self appendString:@" is pulled to refresh"];
    }
    return self;
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.tableExpression) {
        return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeTable) ]];
    }
    return [super availableTokensForExpression:expression];
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak __typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        if (expression != self.tableExpression) return;

        PCNodeType nodeType = expression.token.nodeType;
        NSString *name = [NSString stringWithFormat:@"Refreshing%@", [PCBehavioursDataSource displayNameForObjectType:nodeType]];
        PCTokenNodeVariableDescriptor *descriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:nodeType variableName:name sourceUUID:weakSelf.UUID];
        weakSelf.pulledNodeToken = [PCToken tokenWithDescriptor:descriptor];
    }];
}

- (void)setPulledNodeToken:(PCToken *)token {
    [self exposeToken:token key:@"RefreshingTable"];
}

@end
