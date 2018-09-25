//
//  PCStopTimelineStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-01-14.
//
//

#import "PCStopTimelineStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"

@interface PCStopTimelineStatement ()

@property (strong, nonatomic) PCExpression *timelineExpression;

@end

@implementation PCStopTimelineStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCStopTimelineStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timelineExpression = [[PCExpression alloc] init];
        self.timelineExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeTimeline) ];
        [self appendString:@"Then stop timeline "];
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

@end
