//
//  PCTimelineFinishedStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCTimelineFinishedStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"

@interface PCTimelineFinishedStatement ()

@property (strong, nonatomic) PCExpression *timelineExpression;

@end

@implementation PCTimelineFinishedStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCTimelineFinishedStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timelineExpression = [[PCExpression alloc] init];
        self.timelineExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeTimeline) ];

        [self appendString:@"When timeline "];
        [self appendExpression:self.timelineExpression];
        [self appendString:@" finishes"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.timelineExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

@end