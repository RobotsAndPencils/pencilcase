//
//  PCChange3DMaterialColourStatement.m
//  SpriteBuilder
//
//  Created by Reuben Lee on 2015-03-06.
//
//

#import "PCChange3DAnimationPropertyStatement.h"
#import "PCStatementRegistry.h"
#import "PCExpression.h"
#import "PCStatement+Subclass.h"
#import "PCTokenValueDescriptor.h"
#import "PCNumberExpressionInspector.h"
#import "PCBehavioursDataSource.h"

static NSString *const PC3DAnimationSkeletonKey = @"skeletonName";
static NSString *const PC3DAnimationRepeatCountKey = @"repeatCount";
static NSString *const PC3DAnimationRepeatForeverKey = @"repeatForever";
static NSString *const PC3DAnimationFadeInKey = @"fadeInDuration";
static NSString *const PC3DAnimationFadeOutKey = @"fadeOutDuration";

@interface PCChange3DAnimationPropertyStatement ()

@property (strong, nonatomic) PCExpression *threeDNodeExpression;
@property (strong, nonatomic) PCExpression *animationNameExpression;
@property (strong, nonatomic) PCExpression *propertyExpression;
@property (strong, nonatomic) PCExpression *valueExpression;

@property (strong, nonatomic) NSDictionary *animationPropertiesType;
@property (strong, nonatomic) NSDictionary *animationPropertiesNames;

@end

@implementation PCChange3DAnimationPropertyStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCChange3DAnimationPropertyStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.animationPropertiesType = @{
                PC3DAnimationSkeletonKey : @(PCPropertyTypeString),
                PC3DAnimationRepeatCountKey : @(PCPropertyTypeInteger),
                PC3DAnimationRepeatForeverKey : @(PCPropertyTypeBool),
                PC3DAnimationFadeInKey : @(PCPropertyTypeFloat),
                PC3DAnimationFadeOutKey : @(PCPropertyTypeFloat)
        };

        self.animationPropertiesNames = @{
                PC3DAnimationSkeletonKey : @"Skeleton Name",
                PC3DAnimationRepeatCountKey : @"Repeat Count",
                PC3DAnimationRepeatForeverKey : @"Repeat Forever",
                PC3DAnimationFadeInKey : @"Fade In Duration",
                PC3DAnimationFadeOutKey : @"Fade Out Duration"
        };

        self.threeDNodeExpression = [[PCExpression alloc] init];
        self.threeDNodeExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeNode)];
        self.animationNameExpression = [[PCExpression alloc] init];
        self.animationNameExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeString)];
        self.propertyExpression = [[PCExpression alloc] init];
        self.propertyExpression.supportedTokenTypes = @[@(PCTokenEvaluationTypeProperty)];
        self.valueExpression = [[PCExpression alloc] init];
        self.valueExpression.supportedTokenTypes = [PCToken tokenTypesThatMakeSenseToAppearInAnExpression];

        [self appendString:@"Then change property "];
        [self appendExpression:self.propertyExpression withOrder:2];
        [self appendString:@" to "];
        [self appendExpression:self.valueExpression withOrder:3];
        [self appendString:@" of 3D animation "];
        [self appendExpression:self.animationNameExpression withOrder:1];
        [self appendString:@" of 3D object "];
        [self appendExpression:self.threeDNodeExpression withOrder:0];
    }
    return self;
}

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token {
    [super clearValuesForChangingExpression:expression toToken:token];
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return NO;
}

#pragma mark - Inspectors

- (NSViewController <PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression { 
    if (expression == self.threeDNodeExpression) {
        return [self inspectorForObjectExpression];
    }
    if (expression == self.animationNameExpression) {
        return [self inspectorForAnimationNameExpression];
    }
    if (expression == self.propertyExpression) {
        return [self inspectorForPropertyExpression];
    }
    if (expression == self.valueExpression) {
        return [self inspectorForValueExpression];
    }
    return nil;
}

- (NSViewController <PCExpressionInspector> *)inspectorForObjectExpression {
    return [self createPopupInspectorForExpression:self.threeDNodeExpression
                                         withItems:[self availableTokensForExpression:self.threeDNodeExpression]
                                            onSave:nil];
}

- (NSViewController <PCExpressionInspector> *)inspectorForAnimationNameExpression {
    return [self createPopupInspectorForExpression:self.animationNameExpression
                                         withItems:[self animationNamesTokens]
                                            onSave:nil];
}

- (NSViewController <PCExpressionInspector> *)inspectorForPropertyExpression {
    return [self createPopupInspectorForExpression:self.propertyExpression
                                         withItems:[self animationPropertiesTokens]
                                            onSave:nil];
}

- (NSViewController <PCExpressionInspector> *)inspectorForValueExpression {
    PCToken *propertyToken = self.propertyExpression.token;
    NSString *propertyName = @"";
    if ([propertyToken.descriptor respondsToSelector:@selector(value)] && [propertyToken.descriptor.value isKindOfClass:[NSString class]]) {
        propertyName = (NSString *)propertyToken.descriptor.value;
    }

    if ([propertyName isEqualToString:PC3DAnimationSkeletonKey]) {
        return [self createPopupInspectorForExpression:self.valueExpression
                                             withItems:[self skeletonTokens]
                                                onSave:nil];
    }
    else {
        PCPropertyType propertyType = (PCPropertyType) [self.animationPropertiesType[propertyName] integerValue];
        return [self createValueInspectorForPropertyType:propertyType
                                              expression:self.valueExpression
                                                    name:self.propertyExpression.token.displayName];
    }
}

#pragma mark - Tokens

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    if (expression == self.threeDNodeExpression) {
        return [self threeDNodeTokensForExpression:expression];
    }
    return [super availableTokensForExpression:expression];
}

- (NSArray *)threeDNodeTokensForExpression:(PCExpression *)expression {
    NSArray *result = [PCToken filterTokens:[super availableTokensForExpression:expression]
                               forNodeTypes:@[@(PCNodeType3D)]];

    return [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,
            NSDictionary *bindings) {
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

    // find all the material names from the scene
    NSMutableArray *tokens = [@[] mutableCopy];
    for (NSString *animationName in threeDNode.cachedAnimations.allKeys) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:animationName
                                                                         evaluationType:PCTokenEvaluationTypeString
                                                                                  value:animationName];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }
    return tokens;
}

- (NSArray *)animationPropertiesTokens {
    // find the PC3DNode from the scene based on the expression selected earlier
    NSUUID *threeDNodeUDID = self.threeDNodeExpression.token.descriptor.nodeUUID;
    PC3DNode *threeDNode = (PC3DNode *) [PCBehavioursDataSource nodeWithUUID:threeDNodeUDID];
    if (!threeDNode) return nil;

    // find all the material names from the scene
    NSMutableArray *tokens = [@[] mutableCopy];
    for (NSString *propertyName in self.animationPropertiesNames.allKeys) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:self.animationPropertiesNames[propertyName]
                                                                         evaluationType:PCTokenEvaluationTypeJavaScript
                                                                                  value:propertyName];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        [tokens addObject:token];
    }
    return tokens;
}

- (NSArray *)skeletonTokens {
    // find the PC3DNode from the scene based on the expression selected earlier
    NSUUID *threeDNodeUDID = self.threeDNodeExpression.token.descriptor.nodeUUID;
    PC3DNode *threeDNode = (PC3DNode *) [PCBehavioursDataSource nodeWithUUID:threeDNodeUDID];
    if (!threeDNode) return nil;

    // find all the material names from the scene
    NSMutableArray *tokens = [@[] mutableCopy];
    for (NSString *skeletonName in [threeDNode allSkeletonNames]) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:skeletonName
                                                                         evaluationType:PCTokenEvaluationTypeString
                                                                                  value:skeletonName];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    }
    return tokens;
}

@end
