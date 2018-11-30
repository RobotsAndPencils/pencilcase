//
//  PCWebViewStartedLoadingStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCWebViewStartedLoadingStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"

@interface PCWebViewStartedLoadingStatement ()

@property (strong, nonatomic) PCExpression *webViewExpression;

@end

@implementation PCWebViewStartedLoadingStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCWebViewStartedLoadingStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.webViewExpression = [[PCExpression alloc] init];
        self.webViewExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When WebView "];
        [self appendExpression:self.webViewExpression];
        [self appendString:@" starts loading page"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.webViewExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self webviewTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

#pragma mark - Private

- (NSArray *)webviewTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[self availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeWebView) ]];
}

@end