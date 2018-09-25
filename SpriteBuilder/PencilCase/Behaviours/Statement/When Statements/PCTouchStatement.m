//
//  PCTouchStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-02-02.
//
//

#import "PCTouchStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCTokenValueDescriptor.h"
#import "NSString+CamelCase.h"
#import "PCBehavioursDataSource.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "PCTokenVariableDescriptor.h"

@interface PCTouchStatement ()

@property (nonatomic, strong) PCExpression *stateExpression;
@property (nonatomic, strong) PCExpression *objectExpression;

@end

@implementation PCTouchStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCTouchStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stateExpression = [[PCExpression alloc] init];
        self.objectExpression = [[PCExpression alloc] init];
        self.objectExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];

        [self appendString:@"When touch "];
        [self appendExpression:self.stateExpression];
        [self appendString:@" on "];
        [self appendExpression:self.objectExpression];

        PCTokenVariableDescriptor *touchLocationDescriptor = [PCTokenVariableDescriptor descriptorWithVariableName:@"TouchLocation" evaluationType:PCTokenEvaluationTypePoint sourceUUID:self.UUID];
        PCToken *touchLocationToken = [PCToken tokenWithDescriptor:touchLocationDescriptor];
        [self exposeToken:touchLocationToken];

        PCTokenVariableDescriptor *numberOfTouchesDescriptor = [PCTokenVariableDescriptor descriptorWithVariableName:@"NumberOfTouches" evaluationType:PCTokenEvaluationTypeNumber sourceUUID:self.UUID];
        PCToken *numberOfTouchesToken = [PCToken tokenWithDescriptor:numberOfTouchesDescriptor];
        [self exposeToken:numberOfTouchesToken];
    }
    return self;
}

#pragma mark - PCStatement

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        if (expression != self.objectExpression) return;
        PCNodeType nodeType = expression.token.nodeType;
        NSString *name = [NSString stringWithFormat:@"Touched%@", [PCBehavioursDataSource displayNameForObjectType:nodeType]];
        PCTokenNodeVariableDescriptor *descriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:nodeType variableName:name sourceUUID:weakSelf.UUID];
        weakSelf.touchedNodeToken = [PCToken tokenWithDescriptor:descriptor];
    }];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.stateExpression) {
        return [self touchStateTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)touchStateTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];

    // Map localized string keys to event names
    NSDictionary *states = @{
        @"PCTouchStatementTouchStateBegan": @"touchBegan",
        @"PCTouchStatementTouchStateChanges": @"touchChanged",
        @"PCTouchStatementTouchStateEnds": @"touchEnded"
    };

    for (NSString *key in states) {
        NSString *eventName = states[key];
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:NSLocalizedString(key, @"The lowercase touch state") evaluationType:PCTokenEvaluationTypeString value:eventName];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }
    return [tokens copy];
}

- (void)setTouchedNodeToken:(PCToken *)tappedNodeToken {
    [self exposeToken:tappedNodeToken key:@"TouchedNode"];
}

@end
