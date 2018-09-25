//
//  PCBehavioursDataSource.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-04.
//
//

#import "PCBehavioursDataSource.h"
#import "PCToken.h"
#import "PCTokenNodeDescriptor.h"
#import "PCTokenValueDescriptor.h"
#import "PCTokenCardDescriptor.h"
#import "PCTokenTableCellDescriptor.h"

#import "PCStageScene.h"
#import "SKNode+JavaScript.h"
#import "SKNode+NodeInfo.h"
#import "PlugInManager.h"
#import "PlugInNode.h"

#import "AppDelegate.h"
#import "PCIBeacon.h"
#import "SequencerSequence.h"

#import "PCSKMultiViewNode.h"
#import "PCTokenMultiViewCellDescriptor.h"

#import "PCSKTableNode.h"
#import "PCTableCellInfo.h"

#import "ResourceManagerUtil.h"
#import "CCBReaderInternal.h"
#import "PropertyInspectorHandler.h"
#import "PCTemplate.h"
#import "PCTemplateLibrary.h"
#import "PCKeyValueStoreKeyConfig.h"
#import "PCProjectSettings.h"
#import "PCTokenKVSKeyDescriptor.h"

#import <Underscore.m/Underscore.h>

@implementation PCBehavioursDataSource

+ (NSArray *)objectTokens {
    NSArray *nodes = [self allNodesForCurrentCard];
    return Underscore.array(nodes).map(^id(SKNode *node){
        if (![[Constants userFacingNodeTypes] containsObject:@(node.nodeType)]) return nil;
        if ([node.displayName length] == 0) return nil;

        PCTokenNodeDescriptor *descriptor = [PCTokenNodeDescriptor descriptorWithNodeUUID:node.UUID nodeType:node.nodeType];
        return [PCToken tokenWithDescriptor:descriptor];
    }).unwrap;
}

+ (NSArray *)textureTokens {
    return Underscore.array([ResourceManagerUtil allImageResources]).map(^id(PCResource *resource) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:[resource.filePath lastPathComponent] evaluationType:PCTokenEvaluationTypeTexture value:[[NSUUID alloc] initWithUUIDString:resource.uuid]];
        return [PCToken tokenWithDescriptor:descriptor];
    }).unwrap;
}

+ (NSArray *)imageTokens {
    return Underscore.array([ResourceManagerUtil allImageResources]).map(^id(PCResource *resource) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:[resource.filePath lastPathComponent] evaluationType:PCTokenEvaluationTypeImage value:[[NSUUID alloc] initWithUUIDString:resource.uuid]];
        return [PCToken tokenWithDescriptor:descriptor];
    }).unwrap;
}

+ (NSArray *)beaconTokens {
    NSArray *beacons = [AppDelegate appDelegate].currentProjectSettings.iBeaconList;
    return Underscore.array(beacons).map(^id(PCIBeacon *beacon){
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:beacon.beaconName evaluationType:PCTokenEvaluationTypeBeacon value:@{ @"beaconUUID": beacon.beaconUUID, @"beaconMajor": beacon.beaconMajorId, @"beaconMinor": beacon.beaconMinorId }];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        return token;
    }).unwrap;
}

+ (NSArray *)timelineTokens {
    CCBDocument *document = mockedDocument ?: [AppDelegate appDelegate].currentDocument;
    NSArray *sequences = document.sequences;
    return Underscore.array(sequences).map(^id(SequencerSequence *sequence){
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:sequence.name evaluationType:PCTokenEvaluationTypeTimeline value:nil];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        return token;
    }).unwrap;
}

+ (NSArray *)cardTokens {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    [tokens addObjectsFromArray:[self tokensForDescriptors:[PCTokenCardDescriptor descriptorsForAllChangeTypes]]];

    NSArray *cards = [AppDelegate appDelegate].currentProjectSettings.slideList;
    for (PCSlide *card in cards) {
        PCTokenCardDescriptor *descriptor = [PCTokenCardDescriptor descriptorWithCardUUID:[[NSUUID alloc] initWithUUIDString:card.uuid]];
        [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
    };
    return [tokens copy];
}

+ (NSArray *)particleTemplateTokens {
    PCTemplateLibrary *templateLibrary = [[PCTemplateLibrary alloc] init];
    [templateLibrary loadLibrary];
    NSArray* templates = [templateLibrary templatesForNodeType:@"PCParticleSystem"];

    NSArray *tokens = Underscore.array(templates).map(^PCToken *(PCTemplate *template) {
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:template.name evaluationType:PCTokenEvaluationTypeTemplate value:template.name];
        return [PCToken tokenWithDescriptor:descriptor];
    }).unwrap;

    return tokens;
}

+ (NSArray *)keyValueTokens {
    NSArray *configs = [AppDelegate appDelegate].currentProjectSettings.keyConfigStore.configs;
    NSArray *tokens = Underscore.arrayMap(configs, ^PCToken *(PCKeyValueStoreKeyConfig *config) {
        PCTokenKVSKeyDescriptor *descriptor = [PCTokenKVSKeyDescriptor descriptorWithKeyConfig:[config copy]];
        return [PCToken tokenWithDescriptor:descriptor];
    });
    return tokens;
}

+ (NSString *)nameForObjectWithUUID:(NSUUID *)UUID {
    SKNode *node = [self nodeWithUUID:UUID];
    return [node.displayName stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString *)nameForCardWithUUID:(NSUUID *)UUID {
    NSArray *cards = [AppDelegate appDelegate].currentProjectSettings.slideList;
    __block NSString *name;
    [cards enumerateObjectsUsingBlock:^(PCSlide *card, NSUInteger idx, BOOL *stop) {
        if (![card.uuid isEqual:UUID.UUIDString]) return;
        name = [NSString stringWithFormat:@"Card %@", @(idx + 1)];
        *stop = YES;
    }];
    return name;
}

+ (NSString *)displayNameForObjectType:(PCNodeType)type {
    return [[[PlugInManager sharedManager] pluginNodeForType:type].displayName stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString *)javaScriptNameForObjectType:(PCNodeType)type {
    return [[PlugInManager sharedManager] pluginNodeForType:type].javaScriptClassName;
}

+ (NSArray *)objectTypes {
    static NSArray *tokens;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *objectTypes = [Constants userCreatableNodeTypes];
        NSMutableArray *mutableTokens = [[NSMutableArray alloc] init];
        for (NSNumber *objectType in objectTypes) {
            NSString *displayName = [self displayNameForObjectType:(PCNodeType)[objectType integerValue]];
            PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:displayName evaluationType:PCTokenEvaluationTypeNodeType value:objectType];
            [mutableTokens addObject:[PCToken tokenWithDescriptor:descriptor]];
        }
        tokens = [mutableTokens copy];
    });

    return tokens;
}

+ (NSArray *)propertyTokensForNodeToken:(PCToken *)token filterBlock:(BOOL (^)(NSDictionary *))filterBlock {
    PCNodeType nodeType = token.nodeType;
    if (nodeType == PCNodeTypeUnknown) return @[];
    
    PlugInNode *plugin = [[PlugInManager sharedManager] pluginNodeForType:nodeType];

    NSArray *tokens = Underscore.array(plugin.nodeProperties).filter(^BOOL(NSDictionary *propertyInfo) {
        NSDictionary *scriptingInfo = propertyInfo[@"scriptingInfo"];
        if (!scriptingInfo) return NO;

        // Sometimes you might not want a node subclass to allow a property to be changeable, so check for a disabled key inside set to true inside
        BOOL scriptingInfoDisabled = [scriptingInfo[@"disabled"] boolValue];
        if (scriptingInfoDisabled) return NO;

        PCPropertyType propertyType = [PlugInNode propertyTypeForPropertyInfo:propertyInfo];
        if (propertyType == PCPropertyTypeNotSupported) return NO;

        if (filterBlock) {
            if (!filterBlock(propertyInfo)) return NO;
        }

        return YES;
    }).map(^PCToken *(NSDictionary *propertyInfo) {
        PCPropertyType propertyType = [PlugInNode propertyTypeForPropertyInfo:propertyInfo];
        NSDictionary *scriptingInfo = propertyInfo[@"scriptingInfo"];
        NSString *propertyName = scriptingInfo[@"propertyName"] ?: propertyInfo[@"name"];
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:propertyInfo[@"displayName"] evaluationType:PCTokenEvaluationTypeProperty value:@{ @"propertyName": propertyName, @"propertyType": @(propertyType) }];
        return [PCToken tokenWithDescriptor:descriptor];
    }).unwrap;

    return [tokens copy];
}

+ (NSArray *)propertyTokensForNodeToken:(PCToken *)token {
    return [self propertyTokensForNodeToken:token filterBlock:nil];
}

+ (NSArray *)animatablePropertyTokensForNodeToken:(PCToken *)token {
    return [self propertyTokensForNodeToken:token filterBlock:^BOOL(NSDictionary *propertyInfo) {
        return [propertyInfo[@"animatable"] boolValue];
    }];
}

+ (NSArray *)subPropertyTokensForPropertyType:(PCPropertyType)type {
    NSMutableArray *properties = [NSMutableArray array];
    switch (type) {
        case PCPropertyTypePoint:
            [properties addObject:[PCTokenValueDescriptor descriptorWithName:@"x" evaluationType:PCTokenEvaluationTypeProperty value:@{ @"propertyName": @"x", @"propertyType": @(PCPropertyTypeFloat) }]];
            [properties addObject:[PCTokenValueDescriptor descriptorWithName:@"y" evaluationType:PCTokenEvaluationTypeProperty value:@{ @"propertyName": @"y", @"propertyType": @(PCPropertyTypeFloat) }]];
            break;
        case PCPropertyTypeSize:
            [properties addObject:[PCTokenValueDescriptor descriptorWithName:@"width" evaluationType:PCTokenEvaluationTypeProperty value:@{ @"propertyName": @"width", @"propertyType": @(PCPropertyTypeFloat) }]];
            [properties addObject:[PCTokenValueDescriptor descriptorWithName:@"height" evaluationType:PCTokenEvaluationTypeProperty value:@{ @"propertyName": @"height", @"propertyType": @(PCPropertyTypeFloat) }]];
            break;
        case PCPropertyTypeScale:
            [properties addObject:[PCTokenValueDescriptor descriptorWithName:@"x" evaluationType:PCTokenEvaluationTypeProperty value:@{ @"propertyName": @"x", @"propertyType": @(PCPropertyTypeFloat) }]];
            [properties addObject:[PCTokenValueDescriptor descriptorWithName:@"y" evaluationType:PCTokenEvaluationTypeProperty value:@{ @"propertyName": @"y", @"propertyType": @(PCPropertyTypeFloat) }]];
            break;
        default:
            break;
    }
    for (NSInteger i = 0; i < [properties count]; i++) {
        PCTokenValueDescriptor *descriptor = properties[i];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        properties[i] = token;
    }

    return [properties copy];
}

+ (NSArray *)subPropertyTokensForPropertyToken:(PCToken *)token {
    return [self subPropertyTokensForPropertyType:token.propertyType];
}

+ (NSArray *)viewTokensForMultiViewToken:(PCToken *)multiViewToken indicesOnly:(BOOL)indicesOnly {
    if (multiViewToken.nodeType != PCNodeTypeMultiView) return @[];

    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    if (!indicesOnly) {
        [tokens addObjectsFromArray:[self tokensForDescriptors:[PCTokenMultiViewCellDescriptor allChangeTypeDescriptorsForMulitViewToken:multiViewToken]]];
    }

    PCSKMultiViewNode *node = (id)[self nodeWithUUID:multiViewToken.nodeUUID];
    if (node) {
        [node.cells enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
            PCTokenMultiViewCellDescriptor *descriptor = [PCTokenMultiViewCellDescriptor descriptorForMultiViewToken:multiViewToken viewIndex:index];
            [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
        }];
    }

    return [tokens copy];
}

+ (NSArray *)cellTokensForTableViewToken:(PCToken *)tableViewToken {
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    PCSKTableNode *node = (id)[self nodeWithUUID:tableViewToken.nodeUUID];
    if (node) {
        [node.cells enumerateObjectsUsingBlock:^(PCTableCellInfo *cellInfo, NSUInteger index, BOOL *stop) {
            NSUUID *cellUUID = [[NSUUID alloc] initWithUUIDString:cellInfo.uuid];
            PCTokenTableCellDescriptor *descriptor = [PCTokenTableCellDescriptor descriptorForTableViewToken:tableViewToken cellUUID:cellUUID];
            [tokens addObject:[PCToken tokenWithDescriptor:descriptor]];
        }];
    }
    return [tokens copy];
}

+ (NSString *)displayNameForTableViewToken:(PCToken *)tableViewToken cellUUID:(NSUUID *)cellUUID {
    PCSKTableNode *node = (id)[self nodeWithUUID:tableViewToken.nodeUUID];
    if (!node) return @"";

    PCTableCellInfo *cellInfo = Underscore.array(node.cells).find(^BOOL(PCTableCellInfo *info){
        return [info.uuid isEqual:[cellUUID UUIDString]];
    });
    if (!cellInfo) return @"";

    NSInteger index = [node.cells indexOfObject:cellInfo];
    return [NSString stringWithFormat:@"%@ - %@", @(index), cellInfo.title];
}

+ (NSArray *)allGlobalTokens {
    return [@[
              [self objectTokens],
              [self objectTypes],
              [self timelineTokens],
              [self beaconTokens],
              [self cardTokens],
              ] valueForKeyPath:@"@unionOfArrays.self"];
}

+ (void)performWithMockedDocument:(CCBDocument *)newMockedDocument block:(dispatch_block_t)block {
    NSMutableArray *mockedDocumentSequences = newMockedDocument.sequences;
    [newMockedDocument loadSequencesFromDocumentData:newMockedDocument.docData];

    SKNode *rootNode = [CCBReaderInternal spriteKitNodeGraphFromDocumentDictionary:newMockedDocument.docData parentSize:CGSizeZero];
    rootSceneNode = rootNode;
    mockedDocument = newMockedDocument;
    block();
    rootSceneNode = nil;
    mockedDocument = nil;
    newMockedDocument.sequences = mockedDocumentSequences;
}

+ (SKNode *)nodeWithUUID:(NSUUID *)UUID {
    if (!UUID) return nil;
    SKNode *node = Underscore.find([self allNodesForCurrentCard], ^BOOL(SKNode *node) {
        return [node.uuid isEqual:[UUID UUIDString]];
    });
    return node;
}

#pragma mark - Private

static SKNode *rootSceneNode = nil;
static CCBDocument *mockedDocument = nil;

+ (NSArray *)allNodesForCurrentCard {
    return [(rootSceneNode ?: [PCStageScene scene].rootNode) allNodes];
}

+ (NSArray *)tokensForDescriptors:(NSArray *)descriptors {
    return Underscore.arrayMap(descriptors, ^id(NSObject<PCTokenDescriptor, PCJavaScriptRepresentable> *descriptor){
        return [PCToken tokenWithDescriptor:descriptor];
    });
}

@end
