//
//  PCChange3DMaterialColourStatement.m
//  SpriteBuilder
//
//  Created by Reuben Lee on 2015-03-06.
//
//

#import "PC3DAnimationRunStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCTokenValueDescriptor.h"
#import "PCStageScene.h"
#import "PCNumberExpressionInspector.h"
#import "PCBehavioursDataSource.h"

@interface PC3DAnimationRunStatement()

@property (strong, nonatomic) PCExpression *threeDNodeExpression;
@property (strong, nonatomic) PCExpression *animationNameExpression;

@end

@implementation PC3DAnimationRunStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PC3DAnimationRunStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.threeDNodeExpression = [[PCExpression alloc] init];
        self.threeDNodeExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeNode)];
        self.animationNameExpression = [[PCExpression alloc] init];
        self.animationNameExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeString)];

        [self appendString:@"Then run 3D animation "];
        [self appendExpression:self.animationNameExpression withOrder:1];
        [self appendString:@" of 3D object "];
        [self appendExpression:self.threeDNodeExpression withOrder:0];
    }
    return self;
}

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token {
    if (expression != self.threeDNodeExpression) return;
    // only clear values if we are changing the 3D node
    [super clearValuesForChangingExpression:expression toToken:token];
}

#pragma mark - Inspectors

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.threeDNodeExpression) {
        return [self inspectorForObjectExpression];
    }
    if (expression == self.animationNameExpression) {
        return [self inspectorForAnimationNameExpression];
    }
    return nil;
}

- (NSViewController<PCExpressionInspector> *)inspectorForObjectExpression {
    return [self createPopupInspectorForExpression:self.threeDNodeExpression
                                         withItems:[self availableTokensForExpression:self.threeDNodeExpression]
                                            onSave:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForAnimationNameExpression {
    return [self createPopupInspectorForExpression:self.animationNameExpression
                                         withItems:[self animationNamesTokens]
                                            onSave:nil];
}

#pragma mark - Tokens

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.threeDNodeExpression) {
        return [self threeDNodeTokensForExpression:expression];
    }
    return [super availableTokensForExpression:expression];
}

- (NSArray *)threeDNodeTokensForExpression:(PCExpression *)expression {
    NSArray *result = [PCToken filterTokens:[super availableTokensForExpression:expression] forNodeTypes:@[ @(PCNodeType3D) ]];

    return [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        PCToken *token = evaluatedObject;
        
        NSUUID *threeDNodeUDID = token.descriptor.nodeUUID;
        PC3DNode *threeDNode = (PC3DNode *)[PCBehavioursDataSource nodeWithUUID:threeDNodeUDID];
        if (threeDNode && threeDNode.isPC3DAnimationNode) return NO;
        
        return token.descriptor.tokenType == PCTokenTypeValue;
    }]];
}

- (NSArray *)animationNamesTokens {
    // find the PC3DNode from the scene based on the expression selected earlier
    NSUUID *threeDNodeUDID = self.threeDNodeExpression.token.descriptor.nodeUUID;
    PC3DNode *threeDNode = (PC3DNode *) [PCBehavioursDataSource nodeWithUUID:threeDNodeUDID];
    if (!threeDNode) return nil;

    NSArray *animationNames = @[@"None"];
    animationNames = [animationNames arrayByAddingObjectsFromArray:threeDNode.cachedAnimations.allKeys];
    
    // find all the material names from the scene
    NSMutableArray *tokens = [@[] mutableCopy];
    for (NSString *animationName in animationNames) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:animationName
                                                                         evaluationType:PCTokenEvaluationTypeString
                                                                                  value:animationName];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }

    return tokens;
}

@end
