//
//  PCCreateObjectStatement.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-26.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <GRMustache/GRMustacheTemplate.h>
#import "PCCreateObjectStatement.h"
#import "PCStatement+Subclass.h"
#import "PCStatementRegistry.h"
#import "PCBehavioursDataSource.h"

#import "PCExpression.h"
#import "PCPopUpExpressionInspector.h"

#import "PCToken.h"
#import "PCTokenFutureNodeDescriptor.h"
#import "PCTokenValueDescriptor.h"

@interface PCCreateObjectStatement ()

@property (strong, nonatomic) PCExpression *objectTypeExpression;

@end

@implementation PCCreateObjectStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCCreateObjectStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objectTypeExpression = [[PCExpression alloc] init];
        self.objectTypeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNodeType) ];
        [self appendString:@"Then create object of type "];
        [self appendExpression:self.objectTypeExpression];
    }
    return self;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    __weak typeof(self) weakSelf = self;
    return [self createPopupInspectorForExpression:expression withItems:[self availableTokensForExpression:expression] onSave:^{
        PCToken *typeToken = weakSelf.objectTypeExpression.token;
        PCNodeType nodeType = typeToken.nodeType;

        NSString *name = [NSString stringWithFormat:@"New%@", [PCBehavioursDataSource displayNameForObjectType:nodeType]];
        name = [self uniqueTokenNameForName:name];

        PCTokenFutureNodeDescriptor *descriptor = [PCTokenFutureNodeDescriptor descriptorWithType:nodeType variableName:name sourceUUID:weakSelf.UUID];
        [self setCreatedObjectToken:[PCToken tokenWithDescriptor:descriptor]];
    }];

    return nil;
}

- (void)setCreatedObjectToken:(PCToken *)createdObjectToken {
    [self exposeToken:createdObjectToken key:@"CreatedObject"];
}

@end
