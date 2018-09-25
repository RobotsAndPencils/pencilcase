//
//  PCVideoPlayerChangedStateStatement.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-04-14.
//
//

#import "PCVideoPlayerChangedStateStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "PCTokenValueDescriptor.h"

@interface PCVideoPlayerChangedStateStatement()

@property (strong, nonatomic) PCExpression *videoPlayerExpression;
@property (strong, nonatomic) PCExpression *stateExpression;

@end

@implementation PCVideoPlayerChangedStateStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCVideoPlayerChangedStateStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoPlayerExpression = [[PCExpression alloc] init];
        self.videoPlayerExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeNode)];

        self.stateExpression = [[PCExpression alloc] init];

        [self appendString:@"When video player "];
        [self appendExpression:self.videoPlayerExpression];
        [self appendString:@" changes to state "];
        [self appendExpression:self.stateExpression];

        PCTokenNodeVariableDescriptor *videoDescriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:PCNodeTypeVideo variableName:@"ChangedVideoPlayer" sourceUUID:self.UUID];
        PCToken *videoToken = [PCToken tokenWithDescriptor:videoDescriptor];
        [self exposeToken:videoToken key:@"Video"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:nil];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.videoPlayerExpression) {
        return [self videoPlayerTokensForExpression:expression];
    }
    if (expression == self.stateExpression) {
        return [self stateTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (NSArray *)videoPlayerTokensForExpression:(PCExpression *)expression {
    return [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeTypeVideo) ]];
}

- (NSArray *)stateTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    NSDictionary *values = @{ NSLocalizedString(@"PlayingVideoPlayerState", @"Playing") : @0,
                              NSLocalizedString(@"PausedVideoPlayerState", @"Paused") : @1,
                              NSLocalizedString(@"FinishedVideoPlayerState", @"Finished") : @2 };
    for (NSString *name in values.allKeys) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeNumber value:values[name]];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    };
    return [tokens copy];
}

@end
