//
//  PCPlayTimelineStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-03.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCPlayTimelineStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"

@interface PCPlayTimelineStatement ()

@property (strong, nonatomic) PCExpression *timelineExpression;

@end

@implementation PCPlayTimelineStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCPlayTimelineStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timelineExpression = [[PCExpression alloc] init];
        self.timelineExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeTimeline) ];
        [self appendString:@"Then start timeline "];
        [self appendExpression:self.timelineExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.timelineExpression) {
        return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
    }
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return NO;
}

#pragma mark - Javascript

- (BOOL)evaluatesAsync {
    return YES;
}

@end