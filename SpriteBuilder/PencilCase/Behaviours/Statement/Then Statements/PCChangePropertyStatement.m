//
//  PCCreateObjectStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCChangePropertyStatement.h"
#import "PCStatement+Subclass.h"

#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"

#import "PCStringExpressionInspector.h"
#import "PCPopUpExpressionInspector.h"
#import "PCPointExpressionInspector.h"
#import "PCNumberExpressionInspector.h"
#import "PCColorExpressionInspector.h"
#import "PCToken.h"
#import "PCTokenValueDescriptor.h"

@interface PCChangePropertyStatement ()

@property (strong, nonatomic) PCExpression *objectExpression;
@property (strong, nonatomic) PCExpression *propertyExpression;
@property (strong, nonatomic) PCExpression *valueExpression;

@end

@implementation PCChangePropertyStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCChangePropertyStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objectExpression = [[PCExpression alloc] init];
        self.objectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.propertyExpression = [[PCExpression alloc] init];
        self.propertyExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeProperty) ];
        self.valueExpression = [[PCExpression alloc] init];
        self.valueExpression.supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        self.valueExpression.suggestedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];

        [self appendString:@"Then change property "];
        [self appendExpression:self.propertyExpression withOrder:1];
        [self appendString:@" of object "];
        [self appendExpression:self.objectExpression withOrder:0];
        [self appendString:@" to "];
        [self appendExpression:self.valueExpression withOrder:2];
    }
    return self;
}

#pragma mark - MTLModel

- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)modelVersion {
    if ([key isEqualToString:@"valueExpression"]) {
        // Get latest tokenTypesThatMakeSense...
        PCExpression *valueExpression = [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
        NSArray *supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        valueExpression.suggestedTokenTypes = supportedTokenTypes;

        // Set the supported type to only the current property type
        PCExpression *propertyExpression = [super decodeValueForKey:@"propertyExpression" withCoder:coder modelVersion:modelVersion];
        PCToken *propertyToken = propertyExpression.token;
        PCPropertyType propertyType = propertyToken.propertyType;
        PCTokenEvaluationType evaluationType = [Constants evaluationTypeFromPropertyType:propertyType];
        valueExpression.supportedTokenTypes = @[ @(evaluationType) ];

        return valueExpression;
    }
    return [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
}

#pragma mark - PCStatement

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token {
    if (expression == self.objectExpression) {
        if (self.objectExpression.token.nodeType == token.nodeType) return;
        NSArray *validPropertyTokens = [PCBehavioursDataSource propertyTokensForNodeToken:token];
        if ([PCToken tokens:validPropertyTokens containsTokenReferenceEqual:self.propertyExpression.token]) return;

    }
    if (expression == self.propertyExpression) {
        if (self.propertyExpression.token.propertyType == token.propertyType) return;
    }
    [super clearValuesForChangingExpression:expression toToken:token];
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.objectExpression) {
        return [self inspectorForObjectExpression];
    }
    if (expression == self.propertyExpression) {
        return [self inspectorForPropertyExpression];
    }
    if (expression == self.valueExpression) {
        return [self inspectorForValueExpression];
    }
    return nil;
}

- (NSViewController<PCExpressionInspector> *)inspectorForObjectExpression {
    return [self createPopupInspectorForExpression:self.objectExpression withItems:[self availableTokensForExpression:self.objectExpression] onSave:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForPropertyExpression {
    return [self createPopupInspectorForExpression:self.propertyExpression withItems:[PCBehavioursDataSource propertyTokensForNodeToken:self.objectExpression.token] onSave:^{
        PCToken *propertyToken = self.propertyExpression.token;
        PCPropertyType propertyType = propertyToken.propertyType;
        PCTokenEvaluationType evaluationType = [Constants evaluationTypeFromPropertyType:propertyType];
        self.valueExpression.supportedTokenTypes = @[ @(evaluationType) ];
    }];
}

- (NSViewController<PCExpressionInspector> *)inspectorForValueExpression {
    PCToken *propertyToken = self.propertyExpression.token;
    PCPropertyType propertyType = propertyToken.propertyType;
    return [self createValueInspectorForPropertyType:propertyType expression:self.valueExpression name:self.propertyExpression.token.displayName];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.objectExpression) {
        return [super availableTokensForExpression:self.objectExpression];
    }
    if (expression == self.propertyExpression) {
        return [PCBehavioursDataSource propertyTokensForNodeToken:self.objectExpression.token];
    }
    if (expression == self.valueExpression) {
        NSArray *tokens = [super availableTokensForExpression:expression];
        if (self.propertyExpression.token.propertyType == PCPropertyTypeTexture) {
            tokens = [tokens arrayByAddingObjectsFromArray:[PCBehavioursDataSource textureTokens]];
        }
        return tokens;
    }
    return @[];
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    if (expression == self.valueExpression) return YES;
    return NO;
}

- (NSString *)javaScriptValidationTemplate {
    return @"property = %@";
}

@end
