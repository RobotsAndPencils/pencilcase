//
//  PCChangeMultiViewFocusStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCChangeMultiViewFocusStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "PCNumberExpressionInspector.h"
#import "PCTokenVariableDescriptor.h"
#import "PCBehavioursDataSource.h"

@interface PCChangeMultiViewFocusStatement ()

@property (strong, nonatomic) PCExpression *multiViewExpression;
@property (strong, nonatomic) PCExpression *viewExpression;
@property (strong, nonatomic) PCExpression *transitionTypeExpression;
@property (strong, nonatomic) PCExpression *transitionDurationExpression;

@end

@implementation PCChangeMultiViewFocusStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCChangeMultiViewFocusStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.multiViewExpression = [[PCExpression alloc] init];
        self.multiViewExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.viewExpression = [[PCExpression alloc] init];
        self.transitionTypeExpression = [[PCExpression alloc] init];
        self.transitionDurationExpression = [[PCExpression alloc] init];
        self.transitionDurationExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNumber) ];
        self.transitionDurationExpression.suggestedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];

        [self appendString:@"Then change the focus of multi view "];
        [self appendExpression:self.multiViewExpression];
        [self appendString:@" to view "];
        [self appendExpression:self.viewExpression withOrder:1];
        [self appendString:@", using transition "];
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
        // Specify distinction between supported and suggested token types
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
    if (expression == self.multiViewExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self multiViewTokensForExpression:expression] onSave:nil];
    }
    else if (expression == self.viewExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self viewTokens] onSave:nil];
    }
    else if (expression == self.transitionTypeExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self transitionTokens] onSave:nil];
    }
    else if (expression == self.transitionDurationExpression) {
        PCNumberExpressionInspector *inspector = [self createFloatInspectorForExpression:expression];
        inspector.number = @0.4;
        return inspector;
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return expression == self.transitionDurationExpression;
}

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token {
    if (expression == self.transitionTypeExpression) return;
    if (expression == self.transitionDurationExpression) return;
    [super clearValuesForChangingExpression:expression toToken:token];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.multiViewExpression) {
        return [self multiViewTokensForExpression:expression];
    }
    if (expression == self.viewExpression) {
        return [self viewTokens];
    }
    if (expression == self.transitionTypeExpression) {
        return [self transitionTokens];
        
    }
    return @[];
}

#pragma mark - Private

- (NSArray *)multiViewTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeMultiView) ]];
}

- (NSArray *)viewTokens {
    return [PCBehavioursDataSource viewTokensForMultiViewToken:self.multiViewExpression.token indicesOnly:NO];
}

- (NSArray *)transitionTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSArray *names = @[ @"SlideRight", @"SlideLeft", @"SlideUp", @"SlideDown", @"Instant" ];
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger index, BOOL *stop) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeNumber value:@(index)];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }];
    return [tokens copy];
}

@end
