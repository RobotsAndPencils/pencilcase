//
//  PCSwipeStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCSwipeStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "NSString+CamelCase.h"
#import "PCTokenVariableDescriptor.h"
#import "PCBehavioursDataSource.h"
#import "PCTokenNodeVariableDescriptor.h"

@interface PCSwipeStatement ()

@property (strong, nonatomic) PCExpression *objectExpression;
@property (strong, nonatomic) PCExpression *swipeDirectionExpression;
@property (strong, nonatomic) PCExpression *fingersExpression;

@end

@implementation PCSwipeStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCSwipeStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objectExpression = [[PCExpression alloc] init];
        self.objectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.swipeDirectionExpression = [[PCExpression alloc] init];
        self.fingersExpression = [[PCExpression alloc] init];

        [self appendString:@"When a "];
        [self appendExpression:self.swipeDirectionExpression];
        [self appendString:@" swipe with "];
        [self appendExpression:self.fingersExpression];
        [self appendString:@" fingers is recognized on object  "];
        [self appendExpression:self.objectExpression];

        PCTokenVariableDescriptor *swipeLocation = [PCTokenVariableDescriptor descriptorWithVariableName:@"SwipeLocation" evaluationType:PCTokenEvaluationTypePoint sourceUUID:self.UUID];
        PCToken *swipeLocationToken = [PCToken tokenWithDescriptor:swipeLocation];
        [self exposeToken:swipeLocationToken];

        PCTokenVariableDescriptor *swipeDirection = [PCTokenVariableDescriptor descriptorWithVariableName:@"SwipeDirection" evaluationType:PCTokenEvaluationTypeString sourceUUID:self.UUID];
        PCToken *swipeDirectionToken = [PCToken tokenWithDescriptor:swipeDirection];
        [self exposeToken:swipeDirectionToken];

        PCTokenVariableDescriptor *numberOfTouches = [PCTokenVariableDescriptor descriptorWithVariableName:@"NumberOfTouches" evaluationType:PCTokenEvaluationTypeNumber sourceUUID:self.UUID];
        PCToken *numberOfTouchesToken = [PCToken tokenWithDescriptor:numberOfTouches];
        [self exposeToken:numberOfTouchesToken];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak __typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        if (expression != self.objectExpression) return;

        PCNodeType nodeType = expression.token.nodeType;
        NSString *name = [NSString stringWithFormat:@"Swiped%@", [PCBehavioursDataSource displayNameForObjectType:nodeType]];
        PCTokenNodeVariableDescriptor *descriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:nodeType variableName:name sourceUUID:weakSelf.UUID];
        weakSelf.swipedNodeToken = [PCToken tokenWithDescriptor:descriptor];
    }];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.swipeDirectionExpression) {
        return [self swipeDirectionTokens];
    }
    else if (expression == self.fingersExpression) {
        return [self fingersTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)swipeDirectionTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSArray *names = @[ @"Left", @"Right", @"Up", @"Down" ];
    for (NSString *name in names) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeString value:[name pc_lowerCamelCaseString]];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    };
    return [tokens copy];
}

- (NSArray *)fingersTokens {
    NSMutableArray *tokens = [NSMutableArray array];
    for (NSInteger fingers = 1; fingers <= 3; fingers++) {
        NSString *name = [@(fingers) stringValue];
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeNumber value:@(fingers)];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }
    return [tokens copy];
}

- (void)setSwipedNodeToken:(PCToken *)token {
    [self exposeToken:token key:@"SwipedNode"];
}

@end