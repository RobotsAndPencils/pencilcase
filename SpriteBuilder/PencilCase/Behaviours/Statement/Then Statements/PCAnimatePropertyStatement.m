//
//  PCAnimatePropertyStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-02-03.
//
//

#import "PCStatement+Subclass.h"
#import "PCAnimatePropertyStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCBehavioursDataSource.h"
#import "PCNumberExpressionInspector.h"

@interface PCAnimatePropertyStatement ()

@property (nonatomic, strong) PCExpression *propertyExpression;
@property (nonatomic, strong) PCExpression *objectExpression;
@property (nonatomic, strong) PCExpression *valueExpression;
@property (nonatomic, strong) PCExpression *durationExpression;

@end

@implementation PCAnimatePropertyStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCAnimatePropertyStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.propertyExpression = [[PCExpression alloc] init];
        self.propertyExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeProperty) ];
        self.objectExpression = [[PCExpression alloc] init];
        self.objectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.valueExpression = [[PCExpression alloc] init];
        self.valueExpression.suggestedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        self.durationExpression = [[PCExpression alloc] init];
        self.durationExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNumber) ];

        [self appendString:@"Then animate property "];
        [self appendExpression:self.propertyExpression withOrder:1];
        [self appendString:@" of "];
        [self appendExpression:self.objectExpression withOrder:0];
        [self appendString:@", to "];
        [self appendExpression:self.valueExpression withOrder:2];
        [self appendString:@" with duration "];
        [self appendExpression:self.durationExpression];
        [self appendString:@" seconds"];
    }
    return self;
}

#pragma mark - MTLModel

- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)modelVersion {
    if ([key isEqualToString:@"valueExpression"]) {
        PCExpression *valueExpression = [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
        NSArray *supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        valueExpression.suggestedTokenTypes = supportedTokenTypes;

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
    // Don't clear anything when changing the duration
    if (expression == self.durationExpression) return;
    [super clearValuesForChangingExpression:expression toToken:token];
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.objectExpression) {
        return [self createPopupInspectorForExpression:self.objectExpression withItems:[self availableTokensForExpression:self.objectExpression] onSave:nil];
    }
    if (expression == self.propertyExpression) {
        return [self createPopupInspectorForExpression:self.propertyExpression withItems:[PCBehavioursDataSource animatablePropertyTokensForNodeToken:self.objectExpression.token] onSave:^{
            PCToken *propertyToken = self.propertyExpression.token;
            PCPropertyType propertyType = propertyToken.propertyType;
            PCTokenEvaluationType evaluationType = [Constants evaluationTypeFromPropertyType:propertyType];
            self.valueExpression.supportedTokenTypes = @[ @(evaluationType) ];
        }];
    }
    if (expression == self.valueExpression) {
        PCToken *propertyToken = self.propertyExpression.token;
        PCPropertyType propertyType = propertyToken.propertyType;
        return [self createValueInspectorForPropertyType:propertyType expression:self.valueExpression name:self.propertyExpression.token.displayName];
    }
    if (expression == self.durationExpression) {
        PCNumberExpressionInspector *inspector = [self createFloatInspectorForExpression:self.durationExpression];
        inspector.minValue = 0;
        inspector.maxValue = PCJavaScriptNumberMax;
        return inspector;
    }
    return nil;
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
    return expression == self.valueExpression;
}

- (BOOL)evaluatesAsync {
    return YES;
}

@end
