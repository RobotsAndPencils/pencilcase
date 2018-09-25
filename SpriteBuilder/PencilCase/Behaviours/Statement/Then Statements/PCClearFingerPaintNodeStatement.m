//
//  PCClearFingerPaintNodeStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCClearFingerPaintNodeStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"

@interface PCClearFingerPaintNodeStatement ()

@property (strong, nonatomic) PCExpression *fingerPaintNodeExpression;

@end

@implementation PCClearFingerPaintNodeStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCClearFingerPaintNodeStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fingerPaintNodeExpression = [[PCExpression alloc] init];
        self.fingerPaintNodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        [self appendString:@"Then clear drawing and signatures view "];
        [self appendExpression:self.fingerPaintNodeExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.fingerPaintNodeExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self fingerPaintViewTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return NO;
}

#pragma mark - Private

- (NSArray *)fingerPaintViewTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[self availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeFingerPaint) ]];
}

@end