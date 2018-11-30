//
//  PCFocusTextFieldStatement.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-04-21.
//
//

#import "PCFocusTextFieldStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"

@interface PCFocusTextFieldStatement()

@property (strong, nonatomic) PCExpression *textFieldNodeExpression;

@end

@implementation PCFocusTextFieldStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCFocusTextFieldStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.textFieldNodeExpression = [[PCExpression alloc] init];
        self.textFieldNodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"Then focus text field "];
        [self appendExpression:self.textFieldNodeExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.textFieldNodeExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self textFieldTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

#pragma mark - Private

- (NSArray *)textFieldTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[self availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeTextField) ]];
}

@end
