//
//  PCCreateImageStatement.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-23.
//
//

#import "PCCreateImageStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCTokenFutureNodeDescriptor.h"
#import "PCBehavioursDataSource.h"

@interface PCCreateImageStatement()

@property (strong, nonatomic) PCExpression *imageExpression;

@end

@implementation PCCreateImageStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCCreateImageStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageExpression = [[PCExpression alloc] init];
        self.imageExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeTexture) ];
        [self appendString:@"Then create image view "];
        [self appendExpression:self.imageExpression];

        PCTokenFutureNodeDescriptor *descriptor = [PCTokenFutureNodeDescriptor descriptorWithType:PCNodeTypeImage variableName:[self uniqueTokenNameForName:@"NewImage"] sourceUUID:self.UUID];
        [self exposeToken:[PCToken tokenWithDescriptor:descriptor]];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    return [self createValueInspectorForPropertyType:PCPropertyTypeTexture expression:expression];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.imageExpression) {
        NSArray *tokens = [super availableTokensForExpression:expression];
        return [tokens arrayByAddingObjectsFromArray:[PCBehavioursDataSource textureTokens]];
    }
    return @[];
}

@end
