//
//  SKNode(NodeInfo) 
//  SpriteBuilder
//
//  Created by brandon on 14-07-11.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

// Header
#import "SKNode+NodeInfo.h"

// Third-party
#import <Underscore.m/Underscore.h>

// Categories
#import "SKNode+CocosCompatibility.h"
#import "SKNode+JavaScript.h"

// Project
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PCNodeChildrenManagement.h"
#import "CustomPropSetting.h"
#import "PCSwizzleHelper.h"
#import "InspectorValue.h"
#import "NodePhysicsBody.h"
#import "PCStageScene.h"
#import "NSString+NumericPostscript.h"

@implementation SKNode (NodeInfo)

// CCNode had visisble and no hidden property. SKNode has a hidden and no visible. This is a way to keep the extraProp in nodeInfo in sync.
__attribute__((constructor)) static void pc_setupHiddenSwizzle(void) {
    @autoreleasepool {
        PCReplaceMethodWithBlock([SKNode class], @selector(isHidden), ^(SKNode *_self) {
            return [[_self extraPropForKey:@"hidden"] boolValue];
        });
        
        __block IMP originalSetHidden = PCReplaceMethodWithBlock([SKNode class], @selector(setHidden:), ^(SKNode *_self, BOOL hidden) {
            if (_self.hidden != hidden) {
                [_self setExtraProp:@(hidden) forKey:@"hidden"];
            }
            ((void ( *)(id, SEL, BOOL))originalSetHidden)(_self, @selector(setHidden:), hidden);
        });
    }
}

- (void)setExtraProp:(id)prop forKey:(NSString *)key {
    NodeInfo *info = self.userObject;
    if (prop) {
        [info.extraProps setObject:prop forKey:key];
    }
    else {
        [info.extraProps removeObjectForKey:key];
    }
}

- (void)removeExtraPropForKey:(NSString *)key {
    NodeInfo *info = self.userObject;
    [info.extraProps removeObjectForKey:key];
}

- (id)extraPropForKey:(NSString *)key {
    NodeInfo *info = self.userObject;
    return [info.extraProps objectForKey:key];
}

- (void)setSeqExpanded:(BOOL)seqExpanded {
    [self setExtraProp:[NSNumber numberWithBool:seqExpanded] forKey:@"seqExpanded"];
}

- (BOOL)seqExpanded {
    return [[self extraPropForKey:@"seqExpanded"] boolValue];
}

- (void)setLocked:(BOOL)locked {
    [self setExtraProp:[NSNumber numberWithBool:locked] forKey:@"locked"];
}

- (BOOL)locked {
    return [[self extraPropForKey:@"locked"] boolValue];
}

- (void)setGeneratedName:(NSString *)generatedName {
    [self setExtraProp:generatedName forKey:@"generatedName"];
}

- (NSString *)generatedName {
    return [self extraPropForKey:@"generatedName"];
}

- (NSDictionary *)buildIn {
    return [self extraPropForKey:@"buildIn"];
}

- (void)setBuildIn:(NSDictionary *)buildIn {
    [self setExtraProp:buildIn forKey:@"buildIn"];
}

- (NSDictionary *)buildOut {
    return [self extraPropForKey:@"buildOut"];
}

- (void)setBuildOut:(NSDictionary *)buildOut {
    [self setExtraProp:buildOut forKey:@"buildOut"];
}

- (BOOL)hideFromUI {
    return [[self extraPropForKey:@"hideFromUI"] boolValue];
}

- (void)setHideFromUI:(BOOL)hideFromUI {
    [self setExtraProp:@(hideFromUI) forKey:@"hideFromUI"];
}

- (BOOL)selectable {
    BOOL anyParentNotSelectable = [self anyParentNotSelectable];
    if (anyParentNotSelectable) return NO;
    BOOL selectable = [[self extraPropForKey:@"selectable"] boolValue];
    return selectable;
}

- (void)setSelectable:(BOOL)selectable {
    [self setExtraProp:@(selectable) forKey:@"selectable"];
}

- (BOOL)anyParentNotSelectable {
    if (!self.parent || ![self.parent.userObject isKindOfClass:[NodeInfo class]]) return NO;
    if (!self.parent.selectable) return YES;
    return [self.parent anyParentNotSelectable];
}

- (BOOL)canParticipateInPhysics {
    return YES;
}

- (void)setUuid:(NSString *)uuid {
    [self setExtraProp:uuid forKey:@"uuid"];
}

- (NSString *)uuid {
    return [self extraPropForKey:@"uuid"];
}

- (NSUUID *)UUID {
    return [[NSUUID alloc] initWithUUIDString:self.uuid];
}

- (void)setUUID:(NSUUID *)UUID {
    self.uuid = [UUID UUIDString];
}

- (BOOL)parentHidden {
    SKNode *parent = self.parent;
    while (parent) {
        if (parent.hidden)
            return YES;

        parent = parent.parent;
    }

    return NO;
}

- (PlugInNode *)plugIn {
    NodeInfo *info = self.userObject;
    return info.plugIn;
}

- (id)baseValueForProperty:(NSString *)name {
    NodeInfo *info = self.userObject;
    return [info.baseValues objectForKey:name];
}

- (void)setBaseValue:(id)value forProperty:(NSString *)name {
    NodeInfo *info = self.userObject;
    [info.baseValues setObject:value forKey:name];
}

- (void)customVisit {
    if (self.hidden)
        return;

    // Has been swizzled in the app delegate
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(oldVisit) withObject:nil];
#pragma clang diagnostic pop
}

- (NSString *)displayName {
    return self.name;
}

- (void)ensureDisplayNameIsUnique {
    self.displayName = [self uniqueDisplayNameFromName:self.displayName withinNodes:[[PCStageScene scene].rootNode allNodes]];
}

- (void)setDisplayName:(NSString *)displayName {
    NodeInfo *info = self.userObject;
    NSString *formattedDisplayName = [self formatDisplayName:displayName];
    formattedDisplayName = formattedDisplayName.length == 0 ? self.name : formattedDisplayName;
    NSArray *allNodes = [[PCStageScene scene].rootNode allNodes];
    NSString *uniqueFormattedDisplayName = [self uniqueDisplayNameFromName:formattedDisplayName withinNodes:allNodes];
    info.displayName = uniqueFormattedDisplayName;
    self.name = uniqueFormattedDisplayName;
}

- (NSString *)uniqueDisplayNameFromName:(NSString *)name withinNodes:(NSArray *)nodes {
    NSInteger uniqueIncrement = [[name pc_numericPostscript] integerValue] + 1;
    NSString *rootName = [name pc_stringWithoutNumericPostscript];
    NSString *uniqueName = name;
    while (![self isUniqueDisplayName:uniqueName withinNodes:nodes]) {
        uniqueName = [NSString stringWithFormat:@"%@%ld", rootName, (long)uniqueIncrement];
        uniqueIncrement++;
    }
    return uniqueName;
}

- (BOOL)isUniqueDisplayName:(NSString *)proposedDisplayname withinNodes:(NSArray *)nodes {
    for (SKNode *sceneNode in nodes) {
        if ([sceneNode.displayName isEqualToString:proposedDisplayname] && ![self.uuid isEqual:sceneNode.uuid]) {
            return NO;
        }
    }
    return YES;
}

- (NSString *)formatDisplayName:(NSString *)displayName {
    displayName = [[displayName componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    if (displayName.length > 0 && [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[displayName characterAtIndex:0]]) {
        displayName = [@"My" stringByAppendingString:displayName];
    }
    return displayName;
}

- (NSMutableArray *)customProperties {
    NodeInfo *info = self.userObject;
    return info.customProperties;
}

- (void)setCustomProperties:(NSMutableArray *)customProperties {
    NodeInfo *info = self.userObject;
    info.customProperties = customProperties;
}

- (NSString *)customPropertyNamed:(NSString *)name {
    for (CustomPropSetting *setting in self.customProperties) {
        if ([setting.name isEqualToString:name]) {
            return setting.value;
        }
    }
    return NULL;
}

- (void)setCustomPropertyNamed:(NSString *)name value:(NSString *)value {
    for (CustomPropSetting *setting in self.customProperties) {
        if ([setting.name isEqualToString:name]) {
            setting.value = value;
        }
    }
}

- (id)serializeCustomProperties {
    if ([self.customProperties count] == 0) {
        return NULL;
    }

    NSMutableArray *ser = [NSMutableArray array];

    for (CustomPropSetting *setting in self.customProperties) {
        [ser addObject:[setting serialization]];
    }

    return ser;
}

- (void)loadCustomPropertiesFromSerialization:(id)ser {
    if (!ser) return;

    NSMutableArray *customProps = [NSMutableArray array];

    for (id serSetting in ser) {
        [customProps addObject:[[CustomPropSetting alloc] initWithSerialization:serSetting]];
    }

    self.customProperties = customProps;
}

- (void)loadCustomPropertyValuesFromSerialization:(id)ser {
    if (!ser) return;

    for (id serSetting in ser) {
        CustomPropSetting *setting = [[CustomPropSetting alloc] initWithSerialization:serSetting];
        [self setCustomPropertyNamed:setting.name value:setting.value];
    }
}

- (CGPoint)transformStartPosition {
    NodeInfo *info = self.userObject;
    return info.transformStartPosition;
}

- (void)setTransformStartPosition:(CGPoint)transformStartPosition {
    NodeInfo *info = self.userObject;
    info.transformStartPosition = transformStartPosition;
}

- (CGPoint)transformStartAnchorPoint {
    NodeInfo *info = self.userObject;
    return info.transformStartAnchorPoint;
}

- (void)setTransformStartAnchorPoint:(CGPoint)transformStartAnchorPoint {
    NodeInfo *info = self.userObject;
    info.transformStartAnchorPoint = transformStartAnchorPoint;
}

- (void)setTransformStartScaleX:(float)transformStartScaleX {
    NodeInfo* info = self.userObject;
    info.transformStartScaleX= transformStartScaleX;
}

- (float)transformStartScaleX {
    NodeInfo* info = self.userObject;
    return info.transformStartScaleX;
}

- (void)setTransformStartScaleY:(float)transformStartScaleY {
    NodeInfo* info = self.userObject;
    info.transformStartScaleY= transformStartScaleY;
}

- (float)transformStartScaleY {
    NodeInfo* info = self.userObject;
    return info.transformStartScaleY;
}

- (void)setTransformStartSkewX:(float)transformStartSkewX {
    NodeInfo* info = self.userObject;
    info.transformStartSkewX= transformStartSkewX;
}

- (float)transformStartSkewX {
    NodeInfo* info = self.userObject;
    return info.transformStartSkewX;
}

- (void)setTransformStartSkewY:(float)transformStartSkewY {
    NodeInfo* info = self.userObject;
    info.transformStartSkewY= transformStartSkewY;
}

- (float)transformStartSkewY {
    NodeInfo* info = self.userObject;
    return info.transformStartSkewY;
}

- (void)setTransformStartRotation:(float)transformStartRotation {
    NodeInfo* info = self.userObject;
    info.transformStartRotation= transformStartRotation;
}

- (float)transformStartRotation {
    NodeInfo* info = self.userObject;
    return info.transformStartRotation;
}

- (void)setUsesFlashSkew:(BOOL)seqExpanded {
    [self setExtraProp:[NSNumber numberWithBool:seqExpanded] forKey:@"usesFlashSkew"];
}

- (BOOL)usesFlashSkew {
    return [[self extraPropForKey:@"usesFlashSkew"] boolValue];
}

- (void)setNodePhysicsBody:(NodePhysicsBody *)nodePhysicsBody {
    [self setExtraProp:nodePhysicsBody forKey:@"nodePhysicsBody"];
}

- (NodePhysicsBody *)nodePhysicsBody {
    return [self extraPropForKey:@"nodePhysicsBody"];
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourScale;
}

- (NSString *)propertyNameForResizeBehaviour {
    switch ([self editorResizeBehaviour]) {
        case PCEditorResizeBehaviourScale:
            return @"scale";
            break;
        case PCEditorResizeBehaviourContentSize:
            return @"contentSize";
            break;
        default:
            return @"";
    }
}

- (void)deselect {
    // Override in subclass
}

- (void)doubleClick:(NSEvent *)theEvent {
    // Override in subclass
}

- (SKNode *)childInsertionNode {
    SKNode *parent = self;
    while ([parent conformsToProtocol:@protocol(PCNodeChildInsertion)]) {
        SKNode *newParent = [(id <PCNodeChildInsertion>)parent insertionNode];
        if (!newParent || parent == newParent) break;
        parent = newParent;
    }
    return parent;
}

- (BOOL)hasNodeChangeProperties {
    NodeInfo* info = self.userObject;
    PlugInNode* plugIn = info.plugIn;
    return plugIn.nodeChangeProperties.count > 0;
}

- (BOOL)propertyIsReadOnly:(NSString *)propertyName {
    PlugInNode *plugin = self.plugIn;
    NSDictionary *propInfo = [plugin.nodePropertiesDict objectForKey:propertyName];
    return [[propInfo objectForKey:@"readOnly"] boolValue];
}

- (BOOL)allowsUserPositioning {
    return !self.locked && ![self propertyIsReadOnly:@"position"] && ![self isZeroScaleContentSizeNode];
}

- (BOOL)allowsUserSizing {
    return !self.locked && ![self propertyIsReadOnly:[self propertyNameForResizeBehaviour]] && ![self isZeroScaleContentSizeNode];
}

- (BOOL)isZeroScaleContentSizeNode {
    return (self.editorResizeBehaviour == PCEditorResizeBehaviourContentSize && (self.xScale == 0 || self.yScale == 0));
}

- (BOOL)allowsUserRotation {
    return !self.locked && ![self propertyIsReadOnly:@"rotation"];
}

- (BOOL)allowsUserAnchorPointChange {
    return !self.locked && ![self propertyIsReadOnly:@"anchorPoint"];
}

- (BOOL)allowsUserSkewChange {
    return !self.locked && ![self propertyIsReadOnly:@"skew"];
}

- (BOOL)applyForceCompatible {
    return self.nodePhysicsBody && self.nodePhysicsBody.dynamic;
}

- (BOOL)hasParent:(SKNode *)parent {
    if (!self.parent) return NO;
    if (self.parent == parent) return YES;
    return [self.parent hasParent:parent];
}

- (NSArray *)childrenOfClass:(Class)klass {
    NSArray *nodes = Underscore.array(self.children).filter(^BOOL(SKNode *child) {
        return [child isKindOfClass:klass];
    }).unwrap;
    return nodes;
}

- (NSArray *)recursiveChildrenOfClass:(Class)klass {
    NSMutableArray *nodes = [[self childrenOfClass:klass] mutableCopy];
    for (SKNode *child in self.children) {
        [nodes addObjectsFromArray:[child recursiveChildrenOfClass:klass]];
    }
    return [nodes copy];
}

- (SKNode *)recursiveChildNodeWithUUID:(NSString *)uuid {
    for (SKNode *child in self.children) {
        if ([child.uuid isEqualToString:uuid]) return child;
    }

    for (SKNode *child in self.children) {
        SKNode *result = [child recursiveChildNodeWithUUID:uuid];
        if (result != nil) return result;
    }

    return nil;
}

- (BOOL)hasPhysicsProperties {
    for (NSDictionary *propInfo in self.plugIn.nodeProperties) {
        if ([propInfo[@"propertyCategory"] isEqualToString:PCPropertyCategoryPhysics]) {
            return YES;
        }
    }
    return NO;
}

- (PCNodeType)nodeType {
    return self.plugIn.nodeType;
}

- (void)generateNameIfMissing {
    NSString *instanceName = self.name;
    if (PCIsEmpty(instanceName)) instanceName = self.generatedName;
    if (PCIsEmpty(instanceName)) instanceName = [SKNode uniqueInstanceName];
    self.name = instanceName;
}

- (void)showMissingResourceImageWithKey:(NSString *)key {
    CGSize nodeSize = CGSizeMake(self.size.width / self.scaleX, self.size.height / self.scaleY);
    NSImage *missingResourceImage = [NSImage imageNamed:@"PC_Mac_MissingIcon"];
    missingResourceImage.size = nodeSize;
    SKTexture *missingNodeTexture = [SKTexture textureWithImage:missingResourceImage];
    [self setValue:missingNodeTexture forKey:key];
}

- (void)showMissingResourceImageIfResourceMissing {
    //Does nothing by default. Nodes that should update when their backing resource is deleted should override this method to check if their backing resource is still valid, and if so, show the missing resource image.
}

@end
