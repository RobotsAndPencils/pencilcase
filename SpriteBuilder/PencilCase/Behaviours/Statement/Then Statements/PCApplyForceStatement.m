//
//  PCApplyForceStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCApplyForceStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"

@interface PCApplyForceStatement ()

@property (strong, nonatomic) PCExpression *nodeExpression;
@property (strong, nonatomic) PCExpression *forceExpression;

@end

@implementation PCApplyForceStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCApplyForceStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nodeExpression = [[PCExpression alloc] init];
        self.nodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        self.forceExpression = [[PCExpression alloc] init];
        self.forceExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeVector) ];
        self.forceExpression.suggestedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];

        [self appendString:@"Then apply force to object "];
        [self appendExpression:self.nodeExpression];
        [self appendString:@" with strength "];
        [self appendExpression:self.forceExpression];
    }
    return self;
}

#pragma mark - MTLModel

- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)modelVersion {
    if ([key isEqualToString:@"forceExpression"]) {
        PCExpression *forceExpression = [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
        NSArray *supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        forceExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeVector) ];
        forceExpression.suggestedTokenTypes = supportedTokenTypes;
        return forceExpression;
    }
    return [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
}

#pragma mark - PCStatement

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.nodeExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
    }
    if (expression == self.forceExpression) {
        return [self createValueInspectorForPropertyType:PCPropertyTypeVector expression:expression];
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return expression == self.forceExpression;
}

@end
