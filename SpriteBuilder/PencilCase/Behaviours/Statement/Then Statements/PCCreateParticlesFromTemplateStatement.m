//
//  PCCreateParticlesFromTemplateStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-02-06.
//
//

#import "PCCreateParticlesFromTemplateStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"
#import "PCTokenFutureNodeDescriptor.h"
#import "PCStatement+Subclass.h"

@interface PCCreateParticlesFromTemplateStatement ()

@property (nonatomic, strong) PCExpression *templateExpression;

@end

@implementation PCCreateParticlesFromTemplateStatement

// Disabled until particle spriteframe UUIDs are fixed (they currently don't ever update even though the resource UUIDs may change) so that this behaviour works at runtime
//__attribute__((constructor)) static void registerStatement(void) {
//    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCCreateParticlesFromTemplateStatement class]];
//}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.templateExpression = [[PCExpression alloc] init];
        self.templateExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeTemplate )];

        [self appendString:@"Then create particles with the "];
        [self appendExpression:self.templateExpression];
        [self appendString:@" template"];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        NSString *name = [NSString stringWithFormat:@"New%@", [PCBehavioursDataSource displayNameForObjectType:PCNodeTypeParticle]];
        name = [self uniqueTokenNameForName:name];

        PCTokenFutureNodeDescriptor *descriptor = [PCTokenFutureNodeDescriptor descriptorWithType:PCNodeTypeParticle variableName:name sourceUUID:weakSelf.UUID];
        self.createdParticlesToken = [PCToken tokenWithDescriptor:descriptor];
    }];

    return nil;
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.templateExpression) {
        return [PCBehavioursDataSource particleTemplateTokens];
    }
    return [super availableTokensForExpression:expression];
}

#pragma mark - Private

- (void)setCreatedParticlesToken:(PCToken *)createdObjectToken {
    [self exposeToken:createdObjectToken key:@"CreatedParticles"];
}

@end
