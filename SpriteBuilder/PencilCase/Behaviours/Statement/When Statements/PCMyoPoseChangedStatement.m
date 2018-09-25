//
//  PCMyoPoseChangedStatement.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-02-13.
//
//

#import "PCMyoPoseChangedStatement.h"
#import <GRMustache/GRMustacheTemplate.h>
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCTokenValueDescriptor.h"
#import "NSString+CamelCase.h"
#import "PCBehavioursDataSource.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "PCTokenVariableDescriptor.h"

@interface PCMyoPoseChangedStatement ()

@property (strong, nonatomic) PCExpression *poseExpression;

@end

@implementation PCMyoPoseChangedStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCMyoPoseChangedStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.poseExpression = [[PCExpression alloc] init];
        
        [self appendString:@"When the Myo pose changes to "];
        [self appendExpression:self.poseExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createPopupInspectorForExpression:expression withItems:[self poseStateTokens] onSave:nil];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    return [self poseStateTokens];
}

- (NSArray *)poseStateTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSArray *names = @[ @"Rest", @"Fist", @"WaveIn", @"WaveOut", @"FingersSpread" ];
    for (NSString *name in names) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeString value:[name pc_lowerCamelCaseString]];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }
    return [tokens copy];
}


@end
