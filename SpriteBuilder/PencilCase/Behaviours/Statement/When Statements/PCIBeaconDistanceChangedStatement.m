//
//  PCIBeaconDistanceChangedStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCIBeaconDistanceChangedStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "PCBehavioursDataSource.h"
#import "NSString+CamelCase.h"

@interface PCIBeaconDistanceChangedStatement ()

@property (strong, nonatomic) PCExpression *beaconExpression;
@property (strong, nonatomic) PCExpression *distanceExpression;

@end

@implementation PCIBeaconDistanceChangedStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCIBeaconDistanceChangedStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.beaconExpression = [[PCExpression alloc] init];
        self.beaconExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeBeacon) ];
        self.distanceExpression = [[PCExpression alloc] init];

        [self appendString:@"When the proximity of iBeacon "];
        [self appendExpression:self.beaconExpression];
        [self appendString:@" changes to "];
        [self appendExpression:self.distanceExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.distanceExpression) {
        return [self distanceTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)distanceTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSArray *names = @[ @"Immediate", @"Near", @"Far" ];
    for (NSString *name in names) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeString value:[name pc_lowerCamelCaseString]];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    };
    return [tokens copy];
}

@end
