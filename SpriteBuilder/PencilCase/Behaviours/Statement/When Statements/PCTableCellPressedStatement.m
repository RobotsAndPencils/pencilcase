//
//  PCTableCellPressedStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCTableCellPressedStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "PCBehavioursDataSource.h"

@interface PCTableCellPressedStatement ()

@property (strong, nonatomic) PCExpression *tableExpression;
@property (strong, nonatomic) PCExpression *cellExpression;

@end

@implementation PCTableCellPressedStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCTableCellPressedStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableExpression = [[PCExpression alloc] init];
        self.tableExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.cellExpression = [[PCExpression alloc] init];

        [self appendString:@"When table "];
        [self appendExpression:self.tableExpression];
        [self appendString:@", cell "];
        [self appendExpression:self.cellExpression withOrder:1];
        [self appendString:@", is tapped"];

        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:PCTableCellsChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [weakSelf validateExpressions];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.tableExpression) {
        return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeTable) ]];
    }
    else if (expression == self.cellExpression) {
        return [PCBehavioursDataSource cellTokensForTableViewToken:self.tableExpression.token];
    }
    return [super availableTokensForExpression:expression];
}

@end
