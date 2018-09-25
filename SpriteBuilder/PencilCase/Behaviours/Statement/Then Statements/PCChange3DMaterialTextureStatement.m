//
//  PCChange3DMaterialColourStatement.m
//  SpriteBuilder
//
//  Created by Reuben Lee on 2015-03-06.
//
//

#import "PCChange3DMaterialTextureStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCTokenValueDescriptor.h"
#import "PCStageScene.h"
#import "PCChange3DMaterialColourStatement.h"
#import "PCNumberExpressionInspector.h"
#import "PCBehavioursDataSource.h"

@interface PCChange3DMaterialTextureStatement()

@property (strong, nonatomic) PCExpression *threeDNodeExpression;
@property (strong, nonatomic) PCExpression *materialNameExpression;
@property (strong, nonatomic) PCExpression *textureValueExpression;
@property (strong, nonatomic) PCExpression *materialTypeExpression;
@property (strong, nonatomic) PCExpression *intensityExpression;

@end

@implementation PCChange3DMaterialTextureStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCChange3DMaterialTextureStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.threeDNodeExpression = [[PCExpression alloc] init];
        self.threeDNodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.textureValueExpression = [[PCExpression alloc] init];
        self.textureValueExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeImage)];
        self.materialNameExpression = [[PCExpression alloc] init];
        self.materialNameExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeString) ];
        self.materialTypeExpression = [[PCExpression alloc] init];
        self.materialTypeExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeNumber)];
        self.intensityExpression = [[PCExpression alloc] init];
        self.intensityExpression.supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        
        [self appendString:@"Then change the "];
        [self appendExpression:self.materialTypeExpression withOrder:1];
        [self appendString:@" texture of material "];
        [self appendExpression:self.materialNameExpression withOrder:2];
        [self appendString:@" of 3D object "];
        [self appendExpression:self.threeDNodeExpression withOrder:0];
        [self appendString:@" to "];
        [self appendExpression:self.textureValueExpression withOrder:3];
        [self appendString:@" with intensity of "];
        [self appendExpression:self.intensityExpression withOrder:4];
    }
    return self;
}

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token {
    if (expression != self.threeDNodeExpression) return;
    // only clear values if we are changing the 3D node
    [super clearValuesForChangingExpression:expression toToken:token];
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return NO;
}

#pragma mark - Inspectors

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.threeDNodeExpression) {
        return [self inspectorForObjectExpression];
    }
    if (expression == self.materialNameExpression) {
        return [self inspectorForMaterialNameExpression];
    }
    if (expression == self.textureValueExpression) {
        return [self inspectorForTextureValueExpression];
    }
    if (expression == self.materialTypeExpression) {
        return [self inspectorForMaterialTypeExpression];
    }
    if (expression == self.intensityExpression) {
        return [self inspectorForIntensityExpression];
    }
    return nil;
}

- (NSViewController<PCExpressionInspector> *)inspectorForObjectExpression {
    return [self createPopupInspectorForExpression:self.threeDNodeExpression
                                         withItems:[self availableTokensForExpression:self.threeDNodeExpression]
                                            onSave:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForMaterialNameExpression {
    return [self createPopupInspectorForExpression:self.materialNameExpression withItems:[self materialNameTokens] onSave:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForTextureValueExpression {
    return [self createValueInspectorForPropertyType:PCPropertyTypeImage expression:self.textureValueExpression];
}

- (NSViewController<PCExpressionInspector> *)inspectorForMaterialTypeExpression {
    return [self createPopupInspectorForExpression:self.materialTypeExpression
                                         withItems:[self materialTypeTokens]
                                            onSave:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForIntensityExpression {
    PCNumberExpressionInspector *inspector = [self createFloatInspectorForExpression:self.intensityExpression];
    inspector.minValue = 0;
    inspector.maxValue = 1.0;
    return inspector;
}

#pragma mark - Tokens

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.threeDNodeExpression) {
        return [self threeDNodeTokensForExpression:expression];
    }
    if (expression == self.textureValueExpression) {
        NSArray *tokens = [super availableTokensForExpression:expression];
        return [tokens arrayByAddingObjectsFromArray:[PCBehavioursDataSource imageTokens]];
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

- (NSArray *)materialTypeTokens {
    NSArray *types = [PCChange3DMaterialColourStatement allMaterialTypes];
    NSMutableArray *tokens = [@[] mutableCopy];

    for (NSNumber *materialType in types) {
        PC3DMaterialType type = (PC3DMaterialType) [materialType intValue];
        NSString *typeName = [PCChange3DMaterialColourStatement nameForPC3DMaterialType:type];
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:typeName evaluationType:PCTokenEvaluationTypeNumber value:@(type)];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }
    return tokens;
}

- (NSArray *)materialNameTokens {
    // find the PC3DNode from the scene based on the expression selected earlier
    NSUUID *threeDNodeUDID = self.threeDNodeExpression.token.descriptor.nodeUUID;
    PC3DNode *threeDNode = (PC3DNode *)[PCBehavioursDataSource nodeWithUUID:threeDNodeUDID];
    if (!threeDNode) return nil;
    
    // find all the material names from the scene
    NSMutableArray *tokens = [@[] mutableCopy];
    for (NSString *materialName in [threeDNode materialNames]) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:materialName evaluationType:PCTokenEvaluationTypeString value:materialName];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }
    
    return tokens;
}

@end
