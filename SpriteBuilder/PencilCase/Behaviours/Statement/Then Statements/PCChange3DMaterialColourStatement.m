//
//  PCChange3DMaterialColourStatement.m
//  SpriteBuilder
//
//  Created by Reuben Lee on 2015-03-06.
//
//

#import "PCChange3DMaterialColourStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCTokenValueDescriptor.h"
#import "PCStageScene.h"
#import "PCNumberExpressionInspector.h"
#import "PCBehavioursDataSource.h"

static NSString *const PC3DMaterialColorDiffuse = @"Diffuse";
static NSString *const PC3DMaterialColorSpecular = @"Specular";
static NSString *const PC3DMaterialColorEmission = @"Emission";
static NSString *const PC3DMaterialColorAmbient = @"Ambient";
static NSString *const PC3DMaterialColorNormal = @"Normal";
static NSString *const PC3DMaterialColorReflective = @"Reflective";
static NSString *const PC3DMaterialColorTransparent = @"Transparent";
static NSString *const PC3DMaterialColorMultiply = @"Multiply";

@interface PCChange3DMaterialColourStatement()

@property (strong, nonatomic) PCExpression *threeDNodeExpression;
@property (strong, nonatomic) PCExpression *materialNameExpression;
@property (strong, nonatomic) PCExpression *materialTypeExpression;
@property (strong, nonatomic) PCExpression *intensityExpression;
@property (strong, nonatomic) PCExpression *colourValueExpression;

@end

@implementation PCChange3DMaterialColourStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCChange3DMaterialColourStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.threeDNodeExpression = [[PCExpression alloc] init];
        self.threeDNodeExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNode) ];
        self.colourValueExpression = [[PCExpression alloc] init];
        self.colourValueExpression.supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        self.materialTypeExpression = [[PCExpression alloc] init];
        self.materialTypeExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeNumber)];
        self.intensityExpression = [[PCExpression alloc] init];
        self.intensityExpression.supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
        self.materialNameExpression = [[PCExpression alloc] init];
        self.materialNameExpression.supportedTokenTypes = @[ @(PCTokenEvaluationTypeString) ];
        
        [self appendString:@"Then change the "];
        [self appendExpression:self.materialTypeExpression withOrder:1];
        [self appendString:@" color of material "];
        [self appendExpression:self.materialNameExpression withOrder:2];
        [self appendString:@" of 3D object "];
        [self appendExpression:self.threeDNodeExpression withOrder:0];
        [self appendString:@" to "];
        [self appendExpression:self.colourValueExpression withOrder:3];
        [self appendString:@" with intensity of "];
        [self appendExpression:self.intensityExpression withOrder:4];
    }
    return self;
}

#pragma mark - MTLModel

- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)modelVersion {
    if (modelVersion == 0) {
        if ([key isEqualToString:@"colourValueExpression"]) {
            PCExpression *colourValueExpression = [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
            NSArray *supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
            colourValueExpression.supportedTokenTypes = supportedTokenTypes;
            return colourValueExpression;
        }
        else if ([key isEqualToString:@"intensityExpression"]) {
            PCExpression *intensityExpression = [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
            NSArray *supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];
            intensityExpression.supportedTokenTypes = supportedTokenTypes;
            return intensityExpression;
        }
    }
    return [super decodeValueForKey:key withCoder:coder modelVersion:modelVersion];
}

+ (NSUInteger)modelVersion {
    return 1;
}

#pragma mark - PCStatement

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token {
    if (expression != self.threeDNodeExpression) return;
    // only clear values if we are changing the 3D node
    [super clearValuesForChangingExpression:expression toToken:token];
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return self.colourValueExpression == expression || self.intensityExpression == expression;
}

#pragma mark - Inspectors

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    if (expression == self.threeDNodeExpression) {
        return [self inspectorForObjectExpression];
    }
    if (expression == self.materialNameExpression) {
        return [self inspectorForMaterialNameExpression];
    }
    if (expression == self.materialTypeExpression) {
        return [self inspectorForMaterialTypeExpression];
    }
    if (expression == self.intensityExpression) {
        return [self inspectorForIntensityExpression];
    }
    if (expression == self.colourValueExpression) {
        return [self inspectorForColourValueExpression];
    }
    return nil;
}

- (NSViewController<PCExpressionInspector> *)inspectorForObjectExpression {
    return [self createPopupInspectorForExpression:self.threeDNodeExpression
                                         withItems:[self availableTokensForExpression:self.threeDNodeExpression]
                                            onSave:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForMaterialTypeExpression {
    return [self createPopupInspectorForExpression:self.materialTypeExpression
                                         withItems:[self materialTypeTokens]
                                            onSave:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForMaterialNameExpression {
    return [self createPopupInspectorForExpression:self.materialNameExpression withItems:[self materialNameTokens] onSave:nil];
}

- (NSViewController<PCExpressionInspector> *)inspectorForColourValueExpression {
    return [self createValueInspectorForPropertyType:PCPropertyTypeColor expression:self.colourValueExpression name:nil];
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

#pragma mark - Material Type

+ (NSString *)nameForPC3DMaterialType:(PC3DMaterialType)type {
    switch (type){
        case PC3DMaterialTypeDiffuse: return PC3DMaterialColorDiffuse;
        case PC3DMaterialTypeAmbient: return PC3DMaterialColorAmbient;
        case PC3DMaterialTypeSpecular: return PC3DMaterialColorSpecular;
        case PC3DMaterialTypeNormal: return PC3DMaterialColorNormal;
        case PC3DMaterialTypeReflective: return PC3DMaterialColorReflective;
        case PC3DMaterialTypeEmission: return PC3DMaterialColorEmission;
        case PC3DMaterialTypeTransparent: return PC3DMaterialColorTransparent;
        case PC3DMaterialTypeMultiply: return PC3DMaterialColorMultiply;
    }
    return nil;
}

+ (NSArray *)allMaterialTypes {
    return @[@(PC3DMaterialTypeDiffuse),
             @(PC3DMaterialTypeAmbient),
             @(PC3DMaterialTypeSpecular),
             @(PC3DMaterialTypeNormal),
             @(PC3DMaterialTypeReflective),
             @(PC3DMaterialTypeEmission),
             @(PC3DMaterialTypeTransparent),
             @(PC3DMaterialTypeMultiply)];
}

@end
