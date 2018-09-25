//
//  PCNodeManager.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-23.
//
//

#import "PCNodeManager.h"

#import "PlugInNode.h"
#import "PlugInNode+Writable.h"
#import "NodeInfo.h"
#import "CCBWriterInternal.h"
#import "AppDelegate.h"
#import "PositionPropertySetter.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SKNode+NodeInfo.h"
#import "PCDictionaryKeyValueStore.h"
#import "SKNode+EditorResizing.h"
#import "SKNode+Template.h"

@interface PCNodeManager ()<PCDictionaryKeyValueStore>

// This is used as a flag when iterating through nodes to decide if the properties of each node should be directly changed or just aggregated into the node manager's facade properties
// At least, I think...
// This is way too ambiguous...
// - Brandon
@property (assign, nonatomic) BOOL loading;
@property (assign, nonatomic) BOOL positionTypeChanged;
@property (assign, nonatomic) BOOL isNonEditableInMultiSelect;
@property (strong, nonatomic) SKNode *currentNodeBeingProcessed;

@end


@implementation PCNodeManager

#pragma mark - Lifecycle

- (instancetype)initWithNodes:(NSArray *)nodes uuid:(NSString *)uuid {
    self = [super init];
    _managedNodes = [NSArray arrayWithArray:nodes];
    self.uuid = uuid; // Want the setter here
    _mixedProperties = [NSMutableDictionary dictionary];
    _isMixedStateDict = [NSMutableDictionary dictionary];
    _loading = YES;
    
    [self copyFirstNode];
    [self findShared];

    SequencerSequence *sequencer = [SequencerHandler sharedHandler].currentSequence;
    self.storedTimelinePosition = sequencer.timelinePosition;
    
    _loading = NO;
    _positionTypeChanged = NO;
    _isNonEditableInMultiSelect = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNodeProperties) name:UpdateNodeManagerPropertiesNotification object:nil];
    
    return self;
}

#pragma mark - Properties

- (void)setManagedNodes:(NSArray *)managedNodes {
    _managedNodes = managedNodes;
    // Set loading to YES so we don't overwrite the managed nodes' properties
    self.loading = YES;
    [self findShared];
    self.loading = NO;
}

#pragma mark -

- (void)copyFirstNode {
    SKNode *firstNode = [self.managedNodes firstObject];
    self.currentNodeBeingProcessed = firstNode;
    
    [self determineEditableInMultiSelect:firstNode];
    
    NodeInfo *firstNodeInfo = firstNode.userObject;
    PlugInNode *firstPlugin = firstNodeInfo.plugIn;
    
    self.emptyPlugIn = [[PlugInNode alloc] initEmpty];
    [self setUserObject: [NodeInfo nodeInfoWithPlugIn:self.emptyPlugIn]];
    
    NodeInfo *managerInfo = self.userObject;
    PlugInNode *managerPlugIn = managerInfo.plugIn;
    
    // copy other miscellaneous
    self.canParticipateInPhysics = firstNode.canParticipateInPhysics;
    managerPlugIn.nodeClassName = firstPlugin.nodeClassName;
    managerPlugIn.supportsTemplates = firstPlugin.supportsTemplates;
    
    // load nodeProperties in order to build inspector
    NSMutableArray *managerNodeProperties = [NSMutableArray array];
    for (int i=0; i<[firstPlugin.nodeProperties count]; i++) {
        NSMutableDictionary *propInfo = [firstPlugin.nodeProperties[i] mutableCopy];
        [managerNodeProperties addObject:propInfo];
    }
    [managerPlugIn setNodeProperties:managerNodeProperties];
    [managerPlugIn setupNodePropsDict];
    
    // first pass, assign the values of the first node to the properties; create the mixedState flag
    [self addNodeProperties:firstNode];
    
    // add animatable properties
    NSMutableDictionary *firstNodeAnimatableProperties = firstNodeInfo.animatableProperties;
    NSMutableDictionary *managerAnimatableProperties = [NSMutableDictionary dictionaryWithDictionary:firstNodeAnimatableProperties];
    [managerInfo setAnimatableProperties:managerAnimatableProperties];
}

// Ensures that this manager represents its managed nodes correctly with only common attributes
- (void)findShared {
    // Skip first element
    for (int i = 1; i < self.managedNodes.count; i++) {
        SKNode *node = self.managedNodes[i];

        NodeInfo *nodeInfo = node.userObject;
        PlugInNode *nodePlugIn = nodeInfo.plugIn;
        
        NodeInfo *managerInfo = self.userObject;
        PlugInNode *managerPlugIn = managerInfo.plugIn;
        
        if (![managerPlugIn.nodeClassName isEqualToString:nodePlugIn.nodeClassName]) {
            managerPlugIn.nodeClassName = @"multipleNodeTypesSelected";
        }
        
        if (!nodePlugIn.supportsTemplates) {
            managerPlugIn.supportsTemplates = NO;
        }
        
        if (!node.canParticipateInPhysics) self.canParticipateInPhysics = NO;
        
        self.currentNodeBeingProcessed = node;
        
        [self determineEditableInMultiSelect:node];

        [self addNodeProperties:node];
        [self removeUncommonNodeProperties:node];
        [self removeUncommonAnimatableProperties:node];
    }
    [self setInspectorPropertiesToMixedIfNeeded];
}

- (void)reloadNodeProperties {
    self.isMixedStateDict = [NSMutableDictionary dictionary];
    self.mixedProperties = [NSMutableDictionary dictionary];
    self.loading = YES;
    for (SKNode *node in self.managedNodes) {
        [self addNodeProperties:node];
    }
    for (NSString *key in self.isMixedStateDict) {
        [self sendMixedStateNotificationChangeForProperty:key newState:self.isMixedStateDict[key]];
    }
    self.loading = NO;
}

- (BOOL)shouldAddProperty:(NSDictionary *)propertyInfo {
    NSString *type = propertyInfo[@"type"];
    if ([type isEqualToString:@"Separator"]
        || [type isEqualToString:@"SeparatorSub"]
        || [type isEqualToString:@"StartStop"])
    {
        return NO;
    }

    return YES;
}

- (BOOL)shouldSetExtraPropertyForPluginProperty:(NSDictionary *)pluginPropertyInfo {
    NSString *type = pluginPropertyInfo[@"type"];
    NSArray *permittedTypes = @[@"FloatScale", @"SpriteFrame", @"ResourceUUID", @"Text", @"String", @"JavaScript", @"FontTTF", @"Block", @"BlockCCControl"];
    if ([permittedTypes containsObject:type]) {
        return YES;
    }
    return NO;
}

- (void)addNodeProperties:(SKNode *)node { //adding values
    NodeInfo *nodeInfo = node.userObject;
    PlugInNode *plugIn = nodeInfo.plugIn;

    // Copy extraProps to fix things like scaleLock state that was set on the underlying nodes, but not
    // in node manager
    NSMutableDictionary *extraProps = nodeInfo.extraProps;
    for (NSString *prop in extraProps) {
        [self setExtraProp:extraProps[prop] forKey:prop];
    }
    
    for (NSDictionary *pluginPropertyInfo in plugIn.nodeProperties) {
        NSString *name = pluginPropertyInfo[@"name"];
        if (PCIsEmpty(name)) continue;

        BOOL addProperty = [self shouldAddProperty:pluginPropertyInfo];

        if ([plugIn dontSetInEditorProperty:name]) {
            if (addProperty) {
                id extraProp = [node extraPropForKey:name];
                if (extraProp) {
                    [self setExtraProp:extraProp forKey:name];
                }
            }
        } else {
            if (addProperty) {
                if ([name isEqualToString:@"scale"]) {
                    [self setValue:[node valueForKey:@"scaleX"] forKey:@"scaleX" dictionaryKey:nil updateUI:NO];
                    [self setValue:[node valueForKey:@"scaleY"] forKey:@"scaleY" dictionaryKey:nil updateUI:NO];
                    [self setValue:[node extraPropForKey:@"scaleLock"] forKey:@"scaleLock" dictionaryKey:nil updateUI:NO];
                } else {
                    [self setValue:[node valueForKey:name] forKey:name dictionaryKey:nil updateUI:NO];
                }
            }
            if ([self shouldSetExtraPropertyForPluginProperty:pluginPropertyInfo]) {
                id extraProp = [node extraPropForKey:name];
                if (extraProp) {
                    [self setExtraProp:extraProp forKey:name];
                }
            }
        }
        id baseValue = [node baseValueForProperty:name];
        if (baseValue) {
            [self setBaseValue:baseValue forProperty:name];
        }
    }
}

- (void)removeUncommonNodeProperties:(SKNode *)node {
    //update the nodeManager plugIn so that the inspector panel loads only the inspectors with common sections (as separated by separators)
    NodeInfo *nodeInfo = node.userObject;
    PlugInNode *plugIn = nodeInfo.plugIn;
    NodeInfo *managerInfo = self.userObject;
    PlugInNode *managerPlugIn = managerInfo.plugIn;
    
    BOOL managerShouldKeepProperty = YES;
    for (int i=0; i<[managerPlugIn.nodeProperties count]; i++) {
        NSMutableDictionary *managerPropInfo = managerPlugIn.nodeProperties[i];
        if ([managerPropInfo[@"type"] isEqualToString:@"Separator"]) {
            managerShouldKeepProperty = NO;
            
            if (!self.isNonEditableInMultiSelect || ![managerPropInfo[@"type"] isEqualToString:@"Separator"] || [managerPropInfo [@"displayName"] isEqualToString:@"Layer"] ||[managerPropInfo[@"displayName"] isEqualToString:@"Animations"]) {
                for (NSDictionary *propInfo in plugIn.nodeProperties) {
                    if ([propInfo[@"type"] isEqualToString:@"Separator"] && [propInfo[@"name"] isEqualToString:managerPropInfo[@"name"]]) {
                        managerShouldKeepProperty = YES;
                        break;
                    }
                }
            }
        }
        if (!managerShouldKeepProperty) {
            [managerPlugIn.nodeProperties removeObject:managerPropInfo];
            i--;
        }
    }
    
    for (NSString *managerKey in plugIn.nodePropertiesDict) {
        NSMutableDictionary *managerPropInfo = managerPlugIn.nodePropertiesDict[managerKey];
        NSMutableDictionary *propInfo = plugIn.nodePropertiesDict[managerKey];
        
        if ([propInfo[@"readOnly"] boolValue]) {
            managerPropInfo[@"readOnly"] = @YES;
        }
    }
    
    [managerPlugIn setupNodePropsDict];
}

- (void)removeUncommonAnimatableProperties:(SKNode *)node {
    //update the animatable properties so that it only loads common types
    NodeInfo *managerInfo = self.userObject;
    NSMutableDictionary *managerAnimatableProperties = managerInfo.animatableProperties;
    NodeInfo *nodeInfo = node.userObject;
    NSMutableDictionary *nodeAnimatableProperties = nodeInfo.animatableProperties;
    
    NSArray *managerKeys = [managerAnimatableProperties allKeys];
    
    BOOL managerShouldKeepAnimatableProperty = YES;
    for (NSString *managerKey in managerKeys) {
        managerShouldKeepAnimatableProperty = NO;
        for (NSString *nodeKey in nodeAnimatableProperties) {
            if ([nodeAnimatableProperties[nodeKey] isEqual:managerAnimatableProperties[managerKey]]) {
                managerShouldKeepAnimatableProperty = YES;
                break;
            }
        }
        if (!managerShouldKeepAnimatableProperty) {
            [managerAnimatableProperties removeObjectForKey:managerKey];
        }
    }
}

- (void)determineEditableInMultiSelect:(SKNode *)node {
    if ([[node className] isEqualToString:@"PCSKTableNode"] || [[node className] isEqualToString:@"PCSKTextView"] || [[node className] isEqualToString:@"PCSKVideoPlayer"] ) {
        self.isNonEditableInMultiSelect = YES;
    }
}

# pragma mark updating inspector views

- (void)setInspectorPropertiesToMixedIfNeeded {
    NodeInfo *managerInfo = self.userObject;
    PlugInNode *managerPlugIn = managerInfo.plugIn;
    for (NSDictionary *propInfo in managerPlugIn.nodeProperties) {
        NSString *type = propInfo[@"type"];
        NSString *key = propInfo[@"name"];
        if ([self.isMixedStateDict[key] boolValue]) {
            if ([type isEqualToString:@"Check"]) {
                if ([managerPlugIn dontSetInEditorProperty:key] || [[self extraPropForKey:@"customClass"] isEqualToString:key]) {
                    managerInfo.extraProps[key] = @(NSMixedState);
                } else {
                    self.mixedProperties[key] = @(NSMixedState);
                }
            }
            else if ([type isEqualToString:@"ScaleLock"]) self.mixedProperties[key] = @(NSMixedState);
            else if ([type isEqualToString:@"PCShape"]) {
                NSMutableDictionary *parameters = self.mixedProperties[key][@"parameters"];
                if ([self.isMixedStateDict[[key stringByAppendingString:@"fill"]] boolValue]) {
                    parameters[@"fill"] = @(NSMixedState);
                }
                if ([self.isMixedStateDict[[key stringByAppendingString:@"stroke"]] boolValue]) {
                    parameters[@"stroke"] = @(NSMixedState);
                }
            }
        } else if ([type isEqualToString:@"Flip"]) {
            if ([self.isMixedStateDict[[key stringByAppendingString:@"X"]] boolValue]) {
                self.mixedProperties[[key stringByAppendingString:@"X"]] = @(NSMixedState);
            }
            if ([self.isMixedStateDict[[key stringByAppendingString:@"Y"]] boolValue]) {
                self.mixedProperties[[key stringByAppendingString:@"Y"]] = @(NSMixedState);
            }
        }
    }
}

- (BOOL)isManagingNodes:(NSArray *)selectedNodes {
    return [self.managedNodes isEqualToArray:selectedNodes];
}

- (BOOL)determineMixedStateForProperty:(NSString *)prop {
    NSMutableDictionary *managerDict = self.mixedProperties[prop];
    if ([prop isEqualToString:@"blendFunc"]) {
        if (self.parameterKey) prop = [prop stringByAppendingString:self.parameterKey];
        return [self.isMixedStateDict[prop] boolValue];
    } else if ([self.mixedProperties[prop] isKindOfClass:[NSMutableDictionary class]] && managerDict[@"parameters"]) {
        if (self.parameterKey) prop = [prop stringByAppendingString:self.parameterKey];
        return [self.isMixedStateDict[prop] boolValue];
    } else {
        return [self.isMixedStateDict[prop] boolValue];
    }
    return NO;
}

#pragma mark value access

- (void)setValue:(id)value forKey:(NSString *)key {
    [self setValue:value forKey:key dictionaryKey:key updateUI:YES];
}

- (void)setValue:(id)value forKey:(NSString *)key dictionaryKey:(NSString *)dictionaryKey {
    [self setValue:value forKey:key dictionaryKey:dictionaryKey updateUI:YES];
}

- (void)setValue:(id)value forKey:(NSString *)key dictionaryKey:(NSString *)dictionaryKey updateUI:(BOOL)updateUI {
    if (!value || !key) return;
    if (PCIsEmpty(dictionaryKey)) dictionaryKey = key;

    // if loading, then set mixed state flag
    if (self.loading) {
        if (!self.mixedProperties[key]) {
            self.mixedProperties[key] = value;
        }
        [self updateMixedStateForProperty:key value:value];
    } else {
        if ([key isEqualToString:@"position"]) {
            [self setPositionForManagedNodes:value];
        } else if ([key isEqualToString:@"anchorPoint"]) {
            [self setAnchorPointForManagedNodes:value];
        } else if ([key isEqualToString:@"contentSize"]) {
            [self setContentSizeForManagedNodes:value];
        } else if ([key isEqualToString:@"scaleX"]) {
            [self setScaleXForManagedNodes:value];
        } else if ([key isEqualToString:@"scaleY"]) {
            [self setScaleYForManagedNodes:value];
        } else if ([value isKindOfClass:[NSMutableDictionary class]] && value[@"parameters"]) {
            NSMutableDictionary *parameterDict = value[@"parameters"];
            if (!self.parameterKey || [self.parameterKey isEqualToString:@"value"]) {
                NSMutableDictionary *managerDict = self.mixedProperties[dictionaryKey];
                managerDict[@"value"] = value[@"value"];
                for (SKNode *node in self.managedNodes) {
                    NodeInfo *nodeInfo = node.userObject;
                    NSMutableDictionary *nodeExtraProps = nodeInfo.extraProps;
                    NSMutableDictionary *nodeValue = [nodeExtraProps[key] mutableCopy];
                    nodeValue[@"value"] = value[@"value"];
                    
                    [node setValue:nodeValue forKey:key];
                }
                [self setMixedStateToNoForProperty:[key stringByAppendingString:self.parameterKey]];
            } else if (parameterDict[self.parameterKey]) {
                NSMutableDictionary *managerDict = self.mixedProperties[dictionaryKey];
                NSMutableDictionary *managerParamDict = managerDict[@"parameters"];
                managerParamDict[self.parameterKey] = parameterDict[self.parameterKey];
                for (SKNode *node in self.managedNodes) {
                    NodeInfo *nodeInfo = node.userObject;
                    NSMutableDictionary *nodeExtraProps = nodeInfo.extraProps;
                    NSMutableDictionary *nodeValue = nodeExtraProps[key];
                    NSMutableDictionary *nodeParamDict = [nodeValue[@"parameters"] mutableCopy];
                    nodeParamDict[self.parameterKey] = parameterDict[self.parameterKey];
                    [nodeValue setObject:nodeParamDict forKey:@"parameters"];
                    
                    [node setValue:nodeValue forKey:key];
                }
                
                [self setMixedStateToNoForProperty:[key stringByAppendingString:self.parameterKey]];
            }
        } else {
            self.mixedProperties[dictionaryKey] = value;
            for (SKNode *node in self.managedNodes) {
                [node setValue:value forKey:key];
            }
            [self setMixedStateToNoForProperty:key];
        }
        
        if ([key isEqualToString:@"scaleX"] || [key isEqualToString:@"scaleY"]) key = @"scale";
        else if ([key isEqualToString:@"skewX"] || [key isEqualToString:@"skewY"]) key = @"skew";
        
        // update animation
        if ([self.plugIn isAnimatableProperty:key spriteKitNode:self]) {
            for (SKNode *node in self.managedNodes) {
                NSString *propType = [self.plugIn propertyTypeForProperty:key];
                CCBKeyframeType keyframeType = [SequencerKeyframe keyframeTypeFromPropertyType:propType];
                NodeInfo *nodeInfo = node.userObject;
                PlugInNode *nodePlugIn = nodeInfo.plugIn;
                NSMutableDictionary *nodePropertiesDict = nodePlugIn.nodePropertiesDict;
                
                id value = [CCBWriterInternal serializePropertyForSpriteKitNode:node propInfo:nodePropertiesDict[key] excludeProps:NULL];
                
                [[AppDelegate appDelegate] updateSpriteKitNode:node withAnimateablePropertyValue:value propName:key type:keyframeType];
            }
        }
    }
    
    if (updateUI && ([key isEqualToString:@"name"] || [key isEqualToString:@"displayName"])) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadObjectHierarchyNotification object:nil];
    }
}

- (void)updateNodeManagerInspectorForProperty:(NSString *)prop {
    if ([prop isEqualToString:@"position"]) {
        SKNode *firstNode = self.managedNodes[0];
        self.mixedProperties[prop] = [NSValue valueWithPoint:firstNode.position];
    } else if ([prop isEqualToString:@"contentSize"]) {
        SKNode *firstNode = self.managedNodes[0];
        self.mixedProperties[prop] = [NSValue valueWithSize:firstNode.contentSize];
    } else if ([prop isEqualToString:@"preferredSize"]) {
        SKNode *firstNode = self.managedNodes[0];
        self.mixedProperties[prop] = [NSValue valueWithSize:[[firstNode valueForKey:prop] sizeValue]];
    } else if ([prop isEqualToString:@"anchorPoint"]) {
        SKNode *firstNode = self.managedNodes[0];
        self.mixedProperties[prop] = [NSValue valueWithPoint:firstNode.anchorPoint];
    } else if ([prop isEqualToString:@"scale"]) {
        SKNode *firstNode = self.managedNodes[0];
        NodeInfo *managerInfo = self.userObject;
        managerInfo.extraProps[@"scaleX"] = @(firstNode.scaleX);
        managerInfo.extraProps[@"scaleY"] = @(firstNode.scaleY);
        self.mixedProperties[@"scaleX"] = @(firstNode.scaleX);
        self.mixedProperties[@"scaleY"] = @(firstNode.scaleY);
    } else if ([prop isEqualToString:@"skew"]) {
        SKNode *firstNode = self.managedNodes[0];
        self.mixedProperties[@"skewX"] = @(firstNode.skewX);
        self.mixedProperties[@"skewY"] = @(firstNode.skewY);
    } else if ([prop isEqualToString:@"rotation"]) {
        SKNode *firstNode = self.managedNodes[0];
        self.mixedProperties[@"rotation"] = @(firstNode.rotation);
    }
    else {
        SKNode *firstNode = self.managedNodes[0];
        if ([firstNode respondsToSelector:NSSelectorFromString(prop)]) {
            if ([self.mixedProperties objectForKey:prop]) {
                self.mixedProperties[prop] = [firstNode valueForKey:prop];
            }
        }
    }
}

- (void)updateMixedStateForProperty:(NSString *)prop value:(id)newValue {
    if (!self.mixedProperties[prop]) return;
    
    NSString *type = [self inspectorTypeForProperty:prop];
    
    if ([type isEqualToString:@"Position"] || [type isEqualToString:@"Point"]) {
        NSPoint newPoint = [newValue pointValue];
        NSPoint managerPoint = [self.mixedProperties[prop] pointValue];
        NSString *xKey = [prop stringByAppendingString:@"X"];
        NSString *yKey = [prop stringByAppendingString:@"Y"];
        
        if (!self.isMixedStateDict[xKey]) self.isMixedStateDict[xKey] = @NO;
        else if (![self.isMixedStateDict[xKey] boolValue] && newPoint.x != managerPoint.x) self.isMixedStateDict[xKey] = @YES;
        
        if (!self.isMixedStateDict[yKey]) self.isMixedStateDict[yKey] = @NO;
        else if (![self.isMixedStateDict[yKey] boolValue] && newPoint.y != managerPoint.y) self.isMixedStateDict[yKey] = @YES;
        
    } else if ([type isEqualToString:@"Size"]) {
        NSSize newSize = [newValue sizeValue];
        NSSize managerSize = [self.mixedProperties[prop] sizeValue];
        NSString *xKey = [prop stringByAppendingString:@"X"];
        NSString *yKey = [prop stringByAppendingString:@"Y"];
        
        if (!self.isMixedStateDict[xKey]) self.isMixedStateDict[xKey] = @NO;
        else if (![self.isMixedStateDict[xKey] boolValue] && newSize.width != managerSize.width) self.isMixedStateDict[xKey] = @YES;
        
        if (!self.isMixedStateDict[yKey]) self.isMixedStateDict[yKey] = @NO;
        else if (![self.isMixedStateDict[yKey] boolValue] && newSize.height != managerSize.height) self.isMixedStateDict[yKey] = @YES;
    } else if ([type isEqualToString:@"SpriteFrame"]) {
        NSString *managerSpriteFile = [self extraPropForKey:prop];
        NSString *nodeSpriteFile = [self.currentNodeBeingProcessed extraPropForKey:prop];
        
        [self determineMixedStateForProperty:prop managerValue:managerSpriteFile newValue:nodeSpriteFile];
    } else if ([self.mixedProperties[prop] isKindOfClass:[NSMutableDictionary class]]) {
        NSMutableDictionary *managerDict = self.mixedProperties[prop];
        NSMutableDictionary *newDict = newValue;
        
        BOOL allEqual = YES;
        
        NSString *valueKey = [prop stringByAppendingString:@"value"];
        
        [self determineMixedStateForProperty:valueKey managerValue:managerDict[@"value"] newValue:newDict[@"value"]];
        
        if (![self.isMixedStateDict[valueKey] boolValue]) allEqual = NO;
        
        if (managerDict[@"parameters"]) {
            NSMutableDictionary *managerParams = managerDict[@"parameters"];
            NSMutableDictionary *newParams = newDict[@"parameters"];
            
            for (NSString *key in managerParams) {
                NSString *mixedStateKey = [prop stringByAppendingString:key];
                [self determineMixedStateForProperty:mixedStateKey managerValue:managerParams[key] newValue:newParams[key]];
                
                if (![self.isMixedStateDict[mixedStateKey] boolValue]) allEqual = NO;
            }
            
            self.isMixedStateDict[prop] = @(!allEqual);
            
        }
    } else {
        [self determineMixedStateForProperty:prop managerValue:self.mixedProperties[prop] newValue:newValue];
    }
    
}

- (void)determineMixedStateForProperty:(NSString *)prop managerValue:(id)managerValue newValue:(id)newValue {
    if (!self.isMixedStateDict[prop]) {
        self.isMixedStateDict[prop] = @NO;
    } else if (self.isMixedStateDict[prop] && ![managerValue isEqual:newValue]) {
        self.isMixedStateDict[prop] = @YES;
    }
}

- (void)setMixedStateToNoForProperty:(NSString *)prop {
    NSMutableDictionary *managerDict = self.mixedProperties[prop];
    
    if ([prop isEqualToString:@"blendFunc"]) {
        
        NSString *dstString = [prop stringByAppendingString:@"Dst"];
        NSString *srcString = [prop stringByAppendingString:@"Src"];
        
        self.isMixedStateDict[dstString] = @NO;
        self.isMixedStateDict[srcString] = @NO;
        
        [self sendMixedStateNotificationChangeForProperty:dstString newState:@NO];
        [self sendMixedStateNotificationChangeForProperty:srcString newState:@NO];
    }
    else if ([self.mixedProperties[prop] isKindOfClass:[NSMutableDictionary class]] && managerDict[@"parameters"]) {
        if (self.parameterKey) prop = [prop stringByAppendingString:self.parameterKey];
        self.isMixedStateDict[prop] = @NO;
        [self sendMixedStateNotificationChangeForProperty:prop newState:@NO];
        
        NSMutableDictionary *managerParams = managerDict[@"parameters"];
        BOOL allEqual = YES;
        for (NSString *key in managerParams) {
            NSString *mixedStateKey = [prop stringByAppendingString:key];
            if (!self.isMixedStateDict[mixedStateKey]) allEqual = NO;
        }
        if (allEqual) self.isMixedStateDict[prop] = @NO;
        else self.isMixedStateDict[prop] = @YES;
    } else {
        self.isMixedStateDict[prop] = @NO;
        [self sendMixedStateNotificationChangeForProperty:prop newState:@NO];
    }
}

- (void)sendMixedStateNotificationChangeForProperty:(NSString *)prop newState:(NSNumber *)newState {
    NSDictionary *userInfo;
    userInfo = @{@"prop":prop, @"newState":newState};
    [[NSNotificationCenter defaultCenter] postNotificationName:MixedStateDidChangeNotification object:nil userInfo:userInfo];
}

- (NSString *)inspectorTypeForProperty:(NSString *)prop {
    NodeInfo *managerInfo = self.userObject;
    PlugInNode *managerPlugIn = managerInfo.plugIn;
    NSMutableDictionary *managerNodePropertiesDict = managerPlugIn.nodePropertiesDict;
    NSString *type = managerNodePropertiesDict[prop][@"type"];
    NSString *inspectorType = managerNodePropertiesDict[prop][@"inspectorType"] ?: type;
    return inspectorType;
}


- (id)valueForKey:(NSString *)key {
    return self.mixedProperties[key];
}

- (void)setExtraProp:(id)prop forKey:(NSString *)key {
    // :/
    if ([key isEqualToString:@"uuid"]) {
        [super setExtraProp:prop forKey:key];
        return;
    }

    NodeInfo *info = self.userObject;
    if (self.loading) {
        if ([key isEqualToString:@"eventScripts"]) {
            // drop old 'eventScripts' property
        } else if (!info.extraProps[key]) {
            info.extraProps[key] = prop;
            self.isMixedStateDict[key] = @NO;
        } else if (![info.extraProps[key] isEqual:prop]) {
            self.isMixedStateDict[key] = @YES;
        }
    } else {
        for (SKNode *node in self.managedNodes) {
            [node setExtraProp:prop forKey:key];
        }
        info.extraProps[key] = prop;
        [self setMixedStateToNoForProperty:key];
    }
}

#pragma mark -

- (void)removeExtraPropForKey:(NSString*)key {
    NodeInfo *managedInfo = self.userObject;
    if (!self.loading) {
        [managedInfo.extraProps removeObjectForKey:key];
        for (SKNode *node in  self.managedNodes) {
            NodeInfo *nodeInfo = [node userObject];
            [nodeInfo.extraProps removeObjectForKey:key];
        }
        [self.isMixedStateDict removeObjectForKey:key];
    }
}

- (void) setBaseValue:(id)value forProperty:(NSString*)name {
    NodeInfo *managedInfo = self.userObject;
    if (self.loading) {
        if (!managedInfo.baseValues[name]) {
            managedInfo.baseValues[name] = value;
        }
    } else {
        managedInfo.baseValues[name] = value;
        for (SKNode *node in self.managedNodes) {
            NodeInfo *nodeInfo = [node userObject];
            nodeInfo.baseValues[name] = value;
        }
    }
}

//finds the common keyframes
- (SequencerNodeProperty*) sequenceNodeProperty:(NSString*)name sequenceId:(int)seqId
{
    SequencerNodeProperty *managerSequencerNodeProperty;
    for (int i=0; i<[self.managedNodes count]; i++) {
        SKNode *node = self.managedNodes[i];
        NodeInfo *nodeInfo = node.userObject;
        NSDictionary *animatablePropertiesDict = nodeInfo.animatableProperties[@(seqId)];
        SequencerNodeProperty *nodeSequencerNodeProperty = animatablePropertiesDict[name];
        
        if (!nodeSequencerNodeProperty) continue;
        
        if (!managerSequencerNodeProperty) managerSequencerNodeProperty = [[SequencerNodeProperty alloc] initWithProperty:name node:self];
        
        if ([[managerSequencerNodeProperty keyframes] count] == 0) {
            for (SequencerKeyframe *keyframe in [nodeSequencerNodeProperty keyframes]) {
                SequencerKeyframe *newKeyframe = [[SequencerKeyframe alloc] initWithSerialization:[keyframe serialization]];
                [[managerSequencerNodeProperty keyframes] addObject: newKeyframe];
            }
        } else {
            for (int j=0; j<[[managerSequencerNodeProperty keyframes] count]; j++) {
                BOOL managerShouldKeepKeyframe = NO;
                SequencerKeyframe *managerKeyframe = [managerSequencerNodeProperty keyframes][j];
                for (SequencerKeyframe *nodeKeyframe in [nodeSequencerNodeProperty keyframes]) {
                    if (![managerKeyframe compareTime:nodeKeyframe]) {
                        managerShouldKeepKeyframe = YES;
                        break;
                    }
                }
                if (!managerShouldKeepKeyframe) {
                    [[managerSequencerNodeProperty keyframes] removeObject:managerKeyframe];
                    j--;
                }
            }
        }
    }
    
    return managerSequencerNodeProperty;
}

- (BOOL)allowsUserPositioning {
    return Underscore.all(self.managedNodes, ^(SKNode *node){
        return node.allowsUserPositioning;
    });
}

- (BOOL)allowsUserSizing {
    return Underscore.all(self.managedNodes, ^(SKNode *node){
        return node.allowsUserSizing;
    });
}

- (BOOL)allowsUserRotation {
    return Underscore.all(self.managedNodes, ^(SKNode *node){
        return node.allowsUserRotation;
    });
}

- (BOOL)allowsUserAnchorPointChange {
    return Underscore.all(self.managedNodes, ^(SKNode *node){
        return node.allowsUserAnchorPointChange;
    });
}

- (BOOL)allowsUserSkewChange {
    return Underscore.all(self.managedNodes, ^(SKNode *node){
        return node.allowsUserSkewChange;
    });
}

- (BOOL)applyForceCompatible {
    return Underscore.all(self.managedNodes, ^(SKNode *node){
        return node.applyForceCompatible;
    });
}

#pragma mark special types

- (void)setPositionForManagedNodes:(id)newPosition {
    self.position = NSPointToCGPoint([newPosition pointValue]);

    NSPoint newPoint = self.position;
    NSPoint oldPoint = [self.mixedProperties[@"position"] pointValue];
    
    //store delta of new points, delta's are zero for positionType changes
    BOOL newX = NO;
    BOOL newY = NO;
    if (newPoint.x != oldPoint.x) newX = YES;
    if (newPoint.y != oldPoint.y) newY = YES;
    
    for (int i=0; i<[self.managedNodes count]; i++) {
        SKNode *node = self.managedNodes[i];
        
        // Get position in points
        CGPoint absPos = NSPointToCGPoint([[node valueForKey:@"position"] pointValue]);
        if (!self.positionTypeChanged) {
            if (newX) absPos.x = newPoint.x;
            if (newY) absPos.y = newPoint.y;
        }
        
        NSPoint newRelPos = absPos;
        [PositionPropertySetter setPosition:newRelPos forSpriteKitNode:node prop:@"position"];
    }
    self.positionTypeChanged = NO;
    
    self.mixedProperties[@"position"] = newPosition;
    
    if (newX) [self setMixedStateToNoForProperty:@"positionX"];
    if (newY) [self setMixedStateToNoForProperty:@"positionY"];
}

- (void)setAnchorPointForManagedNodes:(id)newAnchorPoint {
    self.anchorPoint = NSPointToCGPoint([newAnchorPoint pointValue]);
    
    NSPoint newPoint = [newAnchorPoint pointValue];
    NSPoint oldPoint = [self.mixedProperties[@"position"] pointValue];
    
    //store delta of new points, delta's are zero for positionType changes
    BOOL newX = NO;
    BOOL newY = NO;
    if (newPoint.x != oldPoint.x) newX = YES;
    if (newPoint.y != oldPoint.y) newY = YES;
    
    for (int i=0; i<[self.managedNodes count]; i++) {
        SKNode *node = self.managedNodes[i];
        
        // Get position in points
        CGPoint absPos = NSPointToCGPoint([[node valueForKey:@"position"] pointValue]);
        if (!self.positionTypeChanged) {
            if (newX) absPos.x = newPoint.x;
            if (newY) absPos.y = newPoint.y;
        }
        
        [self.managedNodes[i] setAnchorPoint:absPos];
    }
    self.positionTypeChanged = NO;
    
    self.mixedProperties[@"anchorPoint"] = newAnchorPoint;
    
    if (newX) [self setMixedStateToNoForProperty:@"anchorPointX"];
    if (newY) [self setMixedStateToNoForProperty:@"anchorPointY"];
}

- (void)setContentSizeForManagedNodes:(id)newSize {
    self.contentSize = NSSizeFromCGSize([newSize sizeValue]);
    
    NSSize newNSSize = self.contentSize;
    NSSize oldNSSize = [self.mixedProperties[@"contentSize"] sizeValue];
    
    //store delta of new points, delta's are zero for positionType changes
    BOOL newWidth = NO;
    BOOL newHeight = NO;
    if (newNSSize.width != oldNSSize.width) newWidth = YES;
    if (newNSSize.height != oldNSSize.height) newHeight = YES;
    
    if (newWidth) [self setMixedStateToNoForProperty:@"contentSizeX"];
    if (newHeight) [self setMixedStateToNoForProperty:@"contentSizeY"];
    
    for (int i=0; i<[self.managedNodes count]; i++) {
        SKNode *node = self.managedNodes[i];
        
        // Get position in points
        NSSize nodeSize = node.contentSize;
        if (!self.positionTypeChanged) {
            if (newWidth) nodeSize.width = newNSSize.width;
            if (newHeight) nodeSize.height = newNSSize.height;
        }
        
        [node setValue:[NSValue valueWithSize:nodeSize] forKey:@"contentSize"];
    }
    
    self.mixedProperties[@"contentSize"] = newSize;
}

- (void)setScaleXForManagedNodes:(id)newScaleX {
    self.scaleX = [newScaleX floatValue];
    
    for (int i=0; i<[self.managedNodes count]; i++) {
        SKNode *node = self.managedNodes[i];
        
        [PositionPropertySetter setScaledX:self.scaleX Y:node.scaleY forSpriteKitNode:node prop:@"scale"];
    }
    self.positionTypeChanged = NO;
    
    self.mixedProperties[@"scaleX"] = newScaleX;
    
    NodeInfo *managerInfo = self.userObject;
    managerInfo.extraProps[@"scaleX"] = newScaleX;
    
    [self setMixedStateToNoForProperty:@"scaleX"];
}

- (void)setScaleYForManagedNodes:(id)newScaleY {
    self.scaleY = [newScaleY floatValue];
    
    for (int i=0; i<[self.managedNodes count]; i++) {
        SKNode *node = self.managedNodes[i];
        
        [PositionPropertySetter setScaledX:node.scaleX Y:self.scaleY forSpriteKitNode:node prop:@"scale"];
    }
    self.positionTypeChanged = NO;
    
    self.mixedProperties[@"scaleY"] = newScaleY;
    
    NodeInfo *managerInfo = self.userObject;
    managerInfo.extraProps[@"scaleY"] = newScaleY;
    
    [self setMixedStateToNoForProperty:@"scaleY"];
}

#pragma mark - Editor Resizing

- (void)beginResizing {
    [self.managedNodes makeObjectsPerformSelector:@selector(beginResizing)];
}

- (void)finishResizing {
    [self.managedNodes makeObjectsPerformSelector:@selector(finishResizing)];
}

#pragma mark - Template

- (void)didApplyTemplate {
    [super didApplyTemplate];
    [self.managedNodes makeObjectsPerformSelector:_cmd];
}

@end
