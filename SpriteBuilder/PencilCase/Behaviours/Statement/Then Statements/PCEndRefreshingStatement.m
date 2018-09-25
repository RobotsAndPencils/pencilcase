//
//  PCEndRefreshingStatement.m
//  SpriteBuilder
//
//  Created by Michael Beauregard on 15-02-26.
//
//

#import "PCEndRefreshingStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"

@interface PCEndRefreshingStatement ()
@property (nonatomic, strong) PCExpression *tableExpression;
@end

@implementation PCEndRefreshingStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCEndRefreshingStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableExpression = [[PCExpression alloc] init];
        self.tableExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"End table refreshing on "];
        [self appendExpression:self.tableExpression];
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
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
}

@end
