//
//  PCTextFieldBeganStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-02-18.
//
//

#import "PCJavaScriptRepresentable.h"
#import "PCTextFieldBeganStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"

@interface PCTextFieldBeganStatement ()

@property (strong, nonatomic) PCExpression *textFieldNodeExpression;

@end

@implementation PCTextFieldBeganStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCTextFieldBeganStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.textFieldNodeExpression = [[PCExpression alloc] init];
        self.textFieldNodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When editing begins in text field "];
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
