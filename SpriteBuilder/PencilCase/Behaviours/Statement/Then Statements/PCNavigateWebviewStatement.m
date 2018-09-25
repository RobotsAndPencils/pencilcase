//
//  PCNavigateWebviewStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCNavigateWebviewStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "NSString+CamelCase.h"
#import "Constants.h"

@interface PCNavigateWebviewStatement ()

@property (strong, nonatomic) PCExpression *webViewExpression;
@property (strong, nonatomic) PCExpression *navigationTypeExpression;

@end

@implementation PCNavigateWebviewStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCNavigateWebviewStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.webViewExpression = [[PCExpression alloc] init];
        self.webViewExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.navigationTypeExpression = [[PCExpression alloc] init];

        [self appendString:@"Then navigate WebView "];
        [self appendExpression:self.webViewExpression];
        [self appendString:@" with action "];
        [self appendExpression:self.navigationTypeExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.webViewExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self webviewTokensForExpression:expression] onSave:nil];
    }
    if (expression == self.navigationTypeExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self navigationTypeTokens] onSave:nil];
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return NO;
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.webViewExpression) {
        return [self webviewTokensForExpression:expression];
    }
    if (expression == self.navigationTypeExpression) {
        return [self navigationTypeTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)webviewTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeWebView) ]];
}

- (NSArray *)navigationTypeTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSArray *names = @[ @"Go Back", @"Go Forward", @"Refresh", @"Stop", @"Go Home" ];
    for (NSString *name in names) {
        NSString *value = [[name stringByReplacingOccurrencesOfString:@"Go " withString:@""] pc_lowerCamelCaseString];
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeString value:value];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }

    return tokens;
}

#pragma mark - PCJavaScriptRepresentable

- (BOOL)evaluatesAsync {
    return YES;
}

@end