//
//  PCShareStatement.m
//  SpriteBuilder
//
//  Created by Michael Beauregard on 15-02-24.
//
//

#import "PCShareStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"
#import "PCTokenNodeVariableDescriptor.h"
#import "PCStatement+Subclass.h"
#import "AppDelegate.h"

@interface PCShareStatement ()
@property (nonatomic, strong) PCExpression *presentedFromExpression;
@end

@implementation PCShareStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCShareStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.presentedFromExpression = [[PCExpression alloc] init];
        self.presentedFromExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        
        [self appendString:@"Then capture a screenshot and present share options from "];
        [self appendExpression:self.presentedFromExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        PCNodeType nodeType = expression.token.nodeType;
        NSString *name = [NSString stringWithFormat:@"PresentedFrom%@", [PCBehavioursDataSource displayNameForObjectType:nodeType]];
        PCTokenNodeVariableDescriptor *descriptor = [PCTokenNodeVariableDescriptor descriptorWithNodeType:nodeType variableName:name sourceUUID:weakSelf.UUID];
        weakSelf.presentedFromNodeToken = [PCToken tokenWithDescriptor:descriptor];
    }];

    return nil;
}

- (void)setPresentedFromNodeToken:(PCToken *)presentedFromNodeToken {
    [self exposeToken:presentedFromNodeToken key:@"PresentedFromNode"];
}

- (BOOL)evaluatesAsync {
    return YES;
}

@end
