/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "PlugInNode.h"
#import "AppDelegate.h"
#import "SKNode+NodeInfo.h"

@implementation PlugInNode

@synthesize nodeClassName;
@synthesize nodeEditorClassName;
@synthesize displayName;
@synthesize descr;
@synthesize ordering;
@synthesize supportsTemplates;
@synthesize nodeProperties;
@synthesize nodePropertiesDict;
@synthesize dropTargetSpriteFrameClass;
@synthesize dropTargetSpriteFrameProperty;
@synthesize canBeRoot;
@synthesize canHaveChildren;
@synthesize isAbstract;
@synthesize requireParentClass;
@synthesize requireChildClass;
@synthesize icon;

- (void) setupNodePropsDict
{
    // Transform the nodes info array to a dictionary for quicker lookups of properties
    
    for (int i = 0; i < [nodeProperties count]; i++)
    {
        NSDictionary* propInfo = [nodeProperties objectAtIndex:i];
        
        NSString* propName = [propInfo objectForKey:@"name"];
        if (propName)
        {
            [nodePropertiesDict setObject:propInfo forKey:propName];
        }
    }
}

- (NSDictionary *)setupMigrationDictWithBundle:(NSBundle *)b {
    NSArray *migratableProperties = [self loadInheritableAndOverridableArrayForKey:@"migratedProperties" withUniqueIDKey:@"name" forBundle:b];
    NSMutableDictionary *temporaryMigrationDict = [NSMutableDictionary dictionary];
    for (NSDictionary *dictionary in migratableProperties) {
        temporaryMigrationDict[dictionary[@"originalName"]] = dictionary[@"newName"];
    }
    return [temporaryMigrationDict copy];
}

- (id) initWithBundle:(NSBundle*) b
{
    self = [super init];
    if (!self) return NULL;
    
    bundle = b;
    
    // Load properties
    NSURL* propsURL = [bundle URLForResource:@"CCBPProperties" withExtension:@"plist"];
    NSMutableDictionary* props = [NSMutableDictionary dictionaryWithContentsOfURL:propsURL];
    
    self.comingSoon = [[props objectForKey:@"comingSoon"] boolValue];
    
    nodeClassName = [props objectForKey:@"className"];
    _nodeSpriteKitClassName = props[@"spriteKitClassName"];
    nodeEditorClassName = [props objectForKey:@"editorClassName"];
    _nodeEditorSpriteKitClassName = props[@"editorSpriteKitClassName"];
    
    displayName = [props objectForKey:@"displayName"];
    _javaScriptClassName = props[@"javaScriptClassName"];
    descr = [props objectForKey:@"description"];
    ordering = [[props objectForKey:@"ordering"] intValue];
    supportsTemplates = [[props objectForKey:@"supportsTemplates"] boolValue];

    self.nodeChangeProperties = [self loadInheritableAndOverridableArrayForKey:@"actionChangeableProperties" withUniqueIDKey:@"propertyName" forBundle:b];
    
    if (!displayName) displayName = [nodeClassName copy];
    if (!ordering) ordering = 100000;
    if (!descr) descr = [@"" copy];

    nodeProperties = [[self loadInheritableAndOverridableArrayForKey:@"properties" withUniqueIDKey:@"name" forBundle:b] mutableCopy];

    nodePropertiesDict = [[NSMutableDictionary alloc] init];
    [self setupNodePropsDict];

    migratedPropertiesDict = [self setupMigrationDictWithBundle:b];

    // Support for spriteFrame drop targets
    NSDictionary* spriteFrameDrop = [props objectForKey:@"spriteFrameDrop"];
    if (spriteFrameDrop)
    {
        dropTargetSpriteFrameClass = [spriteFrameDrop objectForKey:@"className"];
        dropTargetSpriteFrameProperty = [spriteFrameDrop objectForKey:@"property"];
    }
    
    // Check if node type can be root node and which children are allowed
    canBeRoot = [[props objectForKey:@"canBeRootNode"] boolValue];
    canHaveChildren = [[props objectForKey:@"canHaveChildren"] boolValue];
    isAbstract = [[props objectForKey:@"isAbstract"] boolValue];
    requireChildClass = [props objectForKey:@"requireChildClass"];
    requireParentClass = [props objectForKey:@"requireParentClass"];
    positionProperty = [props objectForKey:@"positionProperty"];
    
    return self;
}

- (NSBundle *)bundle {
    return bundle;
}

- (BOOL) acceptsDroppedSpriteFrameChildren
{
    if (dropTargetSpriteFrameClass && dropTargetSpriteFrameProperty) return YES;
    return NO;
}

- (BOOL) dontSetInEditorProperty: (NSString*) prop
{
    NSDictionary* propInfo = [nodePropertiesDict objectForKey:prop];
    BOOL dontSetInEditor = [[propInfo objectForKey:@"dontSetInEditor"] boolValue];
    if ([[propInfo objectForKey:@"type"] isEqualToString:@"Separator"]
        || [[propInfo objectForKey:@"type"] isEqualToString:@"SeparatorSub"])
    {
        dontSetInEditor = YES;
    }
    
    return dontSetInEditor;
}

- (NSString *)migratedNameForPropertyNamed:(NSString *)name {
    return migratedPropertiesDict[name];
}

- (NSString*) positionProperty
{
    if (positionProperty) return positionProperty;
    return @"position";
}

- (NSArray *)localizablePropertiesForNode:(SKNode *)node {
    NSMutableArray *propertyNames = [NSMutableArray array];
    for (NSDictionary *propertyInfo in nodeProperties) {
        NSString *propertyType = propertyInfo[@"type"];
        if (!([propertyType isEqualTo:@"String"] || [propertyType isEqualToString:@"Text"])) continue;
        if (propertyInfo[@"localizable"] && ![propertyInfo[@"localizable"] boolValue]) continue;
        if ([[propertyInfo objectForKey:@"readOnly"] boolValue]) continue;

        [propertyNames addObject:propertyInfo[@"name"]];
    }
    return propertyNames;
}

- (NSArray *)animatablePropertiesForSpriteKitNode:(SKNode *)node {
    BOOL useFlashSkew = node.usesFlashSkew;
    
    if (!useFlashSkew && cachedAnimatableProperties) return cachedAnimatableProperties;
    if (useFlashSkew && cachedAnimatablePropertiesFlashSkew) return cachedAnimatablePropertiesFlashSkew;
    
    NSMutableArray *props = [NSMutableArray array];
    
    for (NSDictionary *propInfo in nodeProperties) {
        if (useFlashSkew && [propInfo[@"name"] isEqualToString:@"rotation"]) continue;
        if (!useFlashSkew && [propInfo[@"name"] isEqualToString:@"rotationX"]) continue;
        if (!useFlashSkew && [propInfo[@"name"] isEqualToString:@"rotationY"]) continue;
        
        // To keep it consistent, readonly property should not be animatable.
        if ([propInfo[@"readOnly"] boolValue]) continue;
        
        if ([propInfo[@"animatable"] boolValue]) {
            [props addObject:propInfo[@"name"]];
        }
    }
    
    if (!useFlashSkew) cachedAnimatableProperties = props;
    else cachedAnimatablePropertiesFlashSkew = props;
    
    return props;
}

- (BOOL) isAnimatableProperty:(NSString*)prop spriteKitNode:(SKNode*)node
{
    for (NSString* animProp in [self animatablePropertiesForSpriteKitNode:node])
    {
        if ([animProp isEqualToString:prop])
        {
            return YES;
        }
    }
    return NO;
}

- (NSString*) propertyTypeForProperty:(NSString*)property
{
    return nodePropertiesDict[property][@"type"];
}

#pragma mark - Loading Properties

- (NSArray *)loadInheritableArrayForKey:(NSString *)key forBundle:(NSBundle *)b {
    NSMutableDictionary *props = [self propertiesDictionaryForBundle:b];
    NSArray *value = props[key];

    NSString *inheritsFrom = [props objectForKey:@"inheritsFrom"];
    if (inheritsFrom) {
        NSBundle *superBundle = [self bundleForPluginNamed:inheritsFrom];
        value = [[self loadInheritableArrayForKey:key forBundle:superBundle] arrayByAddingObjectsFromArray:value];
    }

    return value;
}

/**
 Loads an array type property where each value is expected to be a dictionary containing the unique ID key.
 Values are recursively loaded from parent plugins.
 Values can be overridden from parents by setting [key]Overridden property. Overridden values are merged.

 @param key         The property key
 @param uniqueIDKey The unique identifying key in the dictionaries
 @param b           The bundle to load from

 @return The resulting array after inheriting and merging.
 */
- (NSArray *)loadInheritableAndOverridableArrayForKey:(NSString *)key withUniqueIDKey:(NSString *)uniqueIDKey forBundle:(NSBundle *)b {
    NSMutableDictionary *props = [self propertiesDictionaryForBundle:b];
    NSArray *value = props[key];

    NSString *inheritsFrom = [props objectForKey:@"inheritsFrom"];
    if (inheritsFrom) {
        NSBundle *superBundle = [self bundleForPluginNamed:inheritsFrom];
        NSMutableArray *superValues = [[self loadInheritableAndOverridableArrayForKey:key withUniqueIDKey:uniqueIDKey forBundle:superBundle] mutableCopy];

        // Merge our overridden dictionaries into our super values
        NSArray *overrides = [props objectForKey:[NSString stringWithFormat:@"%@Overridden", key]];
        if (overrides) {
            for (NSDictionary *info in overrides) {
                NSString *uniqueID = info[uniqueIDKey];
                NSDictionary *superInfo = Underscore.array(superValues).find(^BOOL(NSDictionary *value){
                    return [value[uniqueIDKey] isEqualToString:uniqueID];
                });
                if (superInfo) {
                    NSInteger index = [superValues indexOfObjectIdenticalTo:superInfo];
                    NSMutableDictionary *merged = [superInfo mutableCopy];
                    [merged addEntriesFromDictionary:info];
                    [superValues replaceObjectAtIndex:index withObject:merged];
                }
                else {
                    NSLog(@"Overridden value with unique ID: %@ has nothing to override in bundle: %@!", info[uniqueIDKey], b);
                }
            }
        }

        value = [superValues arrayByAddingObjectsFromArray:value];
    }

    return value;
}

- (NSMutableDictionary *)propertiesDictionaryForBundle:(NSBundle *)b {
    NSURL *propsURL = [b URLForResource:@"CCBPProperties" withExtension:@"plist"];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithContentsOfURL:propsURL];
    return props;
}

- (NSBundle *)bundleForPluginNamed:(NSString *)name {
    NSBundle *appBundle = [NSBundle mainBundle];
    NSURL *plugInDir = [appBundle builtInPlugInsURL];
    NSURL *bundleURL = [plugInDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.ccbPlugNode", name]];
    NSBundle *b = [NSBundle bundleWithURL:bundleURL];
    return b;
}

#pragma mark Drag and Drop

- (id) pasteboardPropertyListForType:(NSString *)pbType
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    if ([pbType isEqualToString:PCPasteboardTypePluginNode])
    {
        [dict setObject:self.nodeClassName forKey:@"nodeClassName"];
        return dict;
    }
    return NULL;
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableArray* pbTypes = [NSMutableArray arrayWithObject: PCPasteboardTypePluginNode];
    return pbTypes;
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)pbType pasteboard:(NSPasteboard *)pasteboard
{
    if ([pbType isEqualToString:PCPasteboardTypePluginNode]) return NSPasteboardWritingPromised;
    return 0;
}

- (NSArray *)readOnlyProperties {
    NSMutableArray *readOnlyProperties = [[NSMutableArray alloc] init];
    for (NSDictionary *property in self.nodeProperties) {
        if ([property[@"readOnly"] boolValue] == YES){
            [readOnlyProperties addObject:property[@"name"]];
        }
    }
    return readOnlyProperties;
}

+ (NSDictionary *)nodeTypesByNameMapping {
    static NSDictionary *nodeTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nodeTypes = @{
                      @"PCNodeColor": @(PCNodeTypeColor),
                      @"PCLabelTTF": @(PCNodeTypeLabel),
                      @"PCTextView": @(PCNodeTypeTextView),
                      @"PCTextField": @(PCNodeTypeTextField),
                      @"PCTextInputView": @(PCNodeTypeTextInput),
                      @"PCFingerPaintView": @(PCNodeTypeFingerPaint),
                      @"PCParticleSystem": @(PCNodeTypeParticle),
                      @"PCButton": @(PCNodeTypeButton),
                      @"PCShareButton": @(PCNodeTypeShareButton),
                      @"PCWebViewNode": @(PCNodeTypeWebView),
                      @"PCCameraCaptureNode": @(PCNodeTypeCameraNode),
                      @"PCTextView": @(PCNodeTypeTextView),
                      @"PCTableNode": @(PCNodeTypeTable),
                      @"PCShapeNode": @(PCNodeTypeShape),
                      @"PCSwitchNode": @(PCNodeTypeSwitch),
                      @"PCSliderNode": @(PCNodeTypeSlider),
                      @"PCMultiViewNode": @(PCNodeTypeMultiView),
                      @"PCMultiViewCellNode": @(PCNodeTypeMultiViewCell),
                      @"PCScrollViewNode": @(PCNodeTypeScrollView),
                      @"PCSprite": @(PCNodeTypeImage),
                      @"PCVideoPlayer": @(PCNodeTypeVideo),
                      @"PC3DNode": @(PCNodeType3D),
                      @"PCForceNode": @(PCNodeTypeForce),
                      @"PCNodeGradient": @(PCNodeTypeGradient),
                      @"PCSlideNode": @(PCNodeTypeCard),
                      @"PCScrollContentNode": @(PCNodeTypeScrollContent),
                      @"CCNode": @(PCNodeTypeNode),
                      };
    });
    return nodeTypes;
}

- (PCNodeType)nodeType {
    NSString *name = self.nodeClassName;
    NSNumber *nodeTypeNumber = [self.class nodeTypesByNameMapping][name];
    NSAssert(nodeTypeNumber != nil, @"Missing Node Type!");
    return [nodeTypeNumber integerValue];
}

+ (NSDictionary *)propertyTypesByNameMapping {
    static NSDictionary *propertyTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertyTypes = @{
                          @"Position": @(PCPropertyTypePoint),
                          @"Point": @(PCPropertyTypePoint),
                          @"Size": @(PCPropertyTypeSize),
                          @"ScaleLock": @(PCPropertyTypeScale),
                          @"Check": @(PCPropertyTypeBool),
                          @"Degrees": @(PCPropertyTypeInteger),
                          @"Float": @(PCPropertyTypeFloat),
                          @"Integer": @(PCPropertyTypeInteger),
                          @"StringSimple": @(PCPropertyTypeString),
                          @"Color3": @(PCPropertyTypeColor),
                          @"Color4": @(PCPropertyTypeColor),
                          @"SpriteFrame": @(PCPropertyTypeTexture),
                          @"KeyboardInput": @(PCPropertyTypeKeyboardInput),
                          @"Text": @(PCPropertyTypeString),
                          @"String": @(PCPropertyTypeString)
                          };
    });
    return propertyTypes;
}

+ (PCPropertyType)propertyTypeForPropertyInfo:(NSDictionary *)propertyInfo {
    NSString *typeName = propertyInfo[@"type"];
    NSNumber *propertyTypeNumber = [self propertyTypesByNameMapping][typeName];
    if (!propertyTypeNumber) {
        NSLog(@"Unsupported scripting property type: %@", typeName);
        return PCPropertyTypeNotSupported;
    }
    return [propertyTypeNumber integerValue];
}

@end
