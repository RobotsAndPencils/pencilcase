//
//  PCGoToCardStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCGoToCardStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "PCNumberExpressionInspector.h"
#import "PCBehavioursDataSource.h"
#import "PCTokenVariableDescriptor.h"

@interface PCGoToCardStatement ()

@property (strong, nonatomic) PCExpression *cardExpression;
@property (strong, nonatomic) PCExpression *transitionTypeExpression;
@property (strong, nonatomic) PCExpression *transitionDurationExpression;

@end

@implementation PCGoToCardStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCGoToCardStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardExpression = [[PCExpression alloc] init];
        self.transitionTypeExpression = [[PCExpression alloc] init];
        self.transitionDurationExpression = [[PCExpression alloc] init];
        self.transitionDurationExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNumber) ];
        self.transitionDurationExpression.suggestedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];

        [self appendString:@"Then go to card "];
        [self appendExpression:self.cardExpression];
        [self appendString:@" using transition type "];
        [self appendExpression:self.transitionTypeExpression];
        [self appendString:@" with duration "];
        [self appendExpression:self.transitionDurationExpression];
        [self appendString:@" seconds"];
    }
    return self;
}

#pragma mark - MTLModel

- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)modelVersion {
    if ([key isEqualToString:@"transitionDurationExpression"]) {
        PCExpression *transitionDurationExpression = [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
        NSArray *supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        transitionDurationExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNumber) ];
        transitionDurationExpression.suggestedTokenTypes = supportedTokenTypes;
        return transitionDurationExpression;
    }
    return [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
}

#pragma mark - PCStatement

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.cardExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[PCBehavioursDataSource cardTokens] onSave:nil];
    }
    else if (expression == self.transitionTypeExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self transitionTokens] onSave:nil];
    }
    else if (expression == self.transitionDurationExpression) {
        PCNumberExpressionInspector *inspector = [self createFloatInspectorForExpression:expression];
        if (!inspector.number) inspector.number = @0.4;
        return inspector;
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return expression == self.transitionDurationExpression;
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.cardExpression) {
        return [PCBehavioursDataSource cardTokens];
    }
    else if (expression == self.transitionTypeExpression) {
        return [self transitionTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)transitionTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSArray *names = @[ @"Instant", @"Slide Left", @"Slide Right", @"Slide Up", @"Slide Down", @"Cross Fade", @"Fade In" ];
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger index, BOOL *stop) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeString value:name];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }];
    return [tokens copy];
}

#pragma mark - PCJavaScriptRepresentable

- (BOOL)evaluatesAsync {
    return YES;
}

@end
