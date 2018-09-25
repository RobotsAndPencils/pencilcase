//
//  PCPlayVideoStatement.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-04-15.
//
//

#import "PCPlayVideoStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"

@interface PCPlayVideoStatement()

@property (strong, nonatomic) PCExpression *videoExpression;

@end

@implementation PCPlayVideoStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCPlayVideoStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoExpression = [[PCExpression alloc] init];
        self.videoExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"Then play video player "];
        [self appendExpression:self.videoExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.videoExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self videoPlayerTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

#pragma mark - Private

- (NSArray *)videoPlayerTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeVideo) ]];
}

@end
