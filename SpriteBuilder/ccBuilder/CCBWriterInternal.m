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

#import "CCBWriterInternal.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "ResourcePropertySetter.h"
#import "PositionPropertySetter.h"
#import "StringPropertySetter.h"
#import "SKNode+NodeInfo.h"
#import "AppDelegate.h"
#import "NodePhysicsBody.h"
#import "SKNode+CocosCompatibility.h"
#import "PCNodeChildrenManagement.h"
#import "SKNode+Sequencer.h"
#import "SKNode+NodeInfo.h"

@implementation CCBWriterInternal



#pragma mark Shortcuts for serializing properties

+ (id) serializePoint:(CGPoint)pt
{
    return @[@(pt.x), @(pt.y)];
}

+ (id) serializePoint:(CGPoint)pt lock:(BOOL)lock
{
    //Need extra 0 for backwards compatibility
    return @[@(pt.x), @(pt.y), @(lock), @0];
}

+ (id) serializeSize:(CGSize)size
{
    return @[@(size.width), @(size.height)];
}

+ (id) serializeBoolPairX:(BOOL)x Y:(BOOL)y
{
    return @[@(x), @(y)];
}

+ (id) serializeFloat:(float)f
{
    return @(f);
}

+ (id) serializeInt:(float)d
{
    return @(d);
}

+ (id) serializeBool:(float)b
{
    return @(b);
}

+ (id)serializeNSColor:(NSColor *)c {
    c = [c colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    CGFloat r,g,b,a;
    [c getRed:&r green:&g blue:&b alpha:&a];
    
    return @[ @(r), @(g), @(b), @(a) ];
}

+ (id) serializeFloatScale:(float)f
{
    //Need extra 0 for backwards compatibility
    return @[@(f), @0];
}

+ (id) serializeSizeWithTypeInfo:(NSSize)size
{
    //Need two empty 0s to be backwards compatible for when size had more info
    return @[@(size.width),@(size.height), @0, @0];
}

+ (id) serializePosition:(NSPoint)pt
{
    //Need three empty 0s for backwards compatibility.
    return @[@(pt.x), @(pt.y), @0, @0, @0];
}

#pragma mark Writer

+ (id) serializePropertyForSpriteKitNode:(SKNode*) node propInfo:(NSMutableDictionary*) propInfo excludeProps:(NSArray*) excludeProps
{
    NodeInfo* info = node.userObject;
    PlugInNode* plugIn = info.plugIn;
    NSMutableDictionary* extraProps = info.extraProps;
    
    NSString* type = [propInfo objectForKey:@"type"];
    NSString* name = [propInfo objectForKey:@"name"];
    id serializedValue = NULL;
    
    BOOL useFlashSkews = [node usesFlashSkew];
    if (useFlashSkews && [name isEqualToString:@"rotation"]) return NULL;
    if (!useFlashSkews && [name isEqualToString:@"rotationX"]) return NULL;
    if (!useFlashSkews && [name isEqualToString:@"rotationY"]) return NULL;
    
    // Check if this property should be excluded
    if (excludeProps && [excludeProps indexOfObject:name] != NSNotFound)
    {
        return NULL;
    }
    
    // Ignore separators and graphical stuff
    if ([type isEqualToString:@"Separator"]
        || [type isEqualToString:@"SeparatorSub"]
        || [type isEqualToString:@"StartStop"])
    {
        return NULL;
    }
    
    BOOL calculated = [[propInfo objectForKey:@"calculated"] boolValue];
    if (calculated) {
        return nil;
    }
    
    // Handle different type of properties
    if ([plugIn dontSetInEditorProperty:name])
    {
        // Get the serialized value from the extra props
        serializedValue = [extraProps objectForKey:name];
    }
    else if ([type isEqualToString:@"Position"])
    {
        NSPoint pt = [PositionPropertySetter positionForNode:node prop:name];
        serializedValue = [CCBWriterInternal serializePosition:pt];
    }
    else if([type isEqualToString:@"Point"]
            || [type isEqualToString:@"PointLock"])
    {
        CGPoint pt = NSPointToCGPoint( [[node valueForKey:name] pointValue] );
        serializedValue = [CCBWriterInternal serializePoint:pt];
    }
    else if ([type isEqualToString:@"Size"])
    {
        NSSize size = [PositionPropertySetter sizeForNode:node prop:name];
        serializedValue = [CCBWriterInternal serializeSizeWithTypeInfo:size];
    }
    else if ([type isEqualToString:@"FloatXY"])
    {
        float x = [[node valueForKey:[NSString stringWithFormat:@"%@X",name]] floatValue];
        float y = [[node valueForKey:[NSString stringWithFormat:@"%@Y",name]] floatValue];
        serializedValue = [CCBWriterInternal serializePoint:CGPointMake(x,y)];
    }
    else if ([type isEqualToString:@"ScaleLock"])
    {
        float x = [PositionPropertySetter scaleXForNode:node prop:name];
        float y = [PositionPropertySetter scaleYForNode:node prop:name];
        BOOL lock = [[extraProps objectForKey:[NSString stringWithFormat:@"%@Lock",name]] boolValue];
        serializedValue = [CCBWriterInternal serializePoint:CGPointMake(x,y) lock:lock];
    }
    else if ([type isEqualToString:@"Float"]
             || [type isEqualToString:@"Degrees"])
    {
        float f = [[node valueForKey:name] floatValue];
        serializedValue = [CCBWriterInternal serializeFloat:f];
    }
    else if ([type isEqualToString:@"FloatScale"])
    {
        float f = [PositionPropertySetter floatScaleForNode:node prop:name];
        serializedValue = [CCBWriterInternal serializeFloatScale:f];
    }
    else if ([type isEqualToString:@"FloatVar"])
    {
        float x = [[node valueForKey:name] floatValue];
        float y = [[node valueForKey:[NSString stringWithFormat:@"%@Range",name]] floatValue];
        serializedValue = [CCBWriterInternal serializePoint:CGPointMake(x,y)];
    }
    else if ([type isEqualToString:@"Integer"]
             || [type isEqualToString:@"IntegerLabeled"]
             || [type isEqualToString:@"Byte"])
    {
        int d = [[node valueForKey:name] intValue];
        serializedValue = [CCBWriterInternal serializeInt:d];
    }
    else if ([type isEqualToString:@"Check"])
    {
        BOOL check = [[node valueForKey:name] boolValue];
        serializedValue = [CCBWriterInternal serializeBool:check];
    }
    else if ([type isEqualToString:@"Flip"])
    {
        BOOL x = [[node valueForKey:[NSString stringWithFormat:@"%@X",name]] boolValue];
        BOOL y = [[node valueForKey:[NSString stringWithFormat:@"%@Y",name]] boolValue];
        serializedValue = [CCBWriterInternal serializeBoolPairX:x Y:y];
    }
    else if ([type isEqualToString:@"SpriteFrame"] || [type isEqualToString:@"ResourceUUID"])
    {
        serializedValue = [extraProps objectForKey:name] ? : @"";
    }
    else if ([type isEqualToString:@"Color3"])
    {
        NSColor* colorValue = [node valueForKey:name];
        serializedValue = [CCBWriterInternal serializeNSColor:colorValue];
    }
    else if ([type isEqualToString:@"Color4"])
    {
        NSColor* colorValue = [node valueForKey:name];
        serializedValue = [CCBWriterInternal serializeNSColor:colorValue];
    }
    else if ([type isEqualToString:@"Color4FVar"])
    {
        NSString* nameVar = [NSString stringWithFormat:@"%@Range",name];
        NSColor* cValue = [node valueForKey:name];
        NSColor* cVarValue = [node valueForKey:nameVar];
        
        serializedValue = [NSArray arrayWithObjects:
                           [CCBWriterInternal serializeNSColor:cValue],
                           [CCBWriterInternal serializeNSColor:cVarValue],
                           nil];
    }
    else if ([type isEqualToString:@"StringSimple"])
    {
        NSString* str = [StringPropertySetter stringForNode:node andProp:name];
        if (!str) str = @"";
        serializedValue = str;
    }
    
    else if ([type isEqualToString:@"Text"]
             || [type isEqualToString:@"String"]
             || [type isEqualToString:@"JavaScript"])
    {
        NSString* str = [StringPropertySetter stringForNode:node andProp:name];
        BOOL localized = [StringPropertySetter isLocalizedNode:node andProp:name];
        if (!str) str = @"";
        serializedValue = [NSArray arrayWithObjects:str, [NSNumber numberWithBool:localized], nil];
    }
    else if ([type isEqualToString:@"Dictionary"]
             || [type isEqualToString:@"Build"]
             || [type isEqualToString:@"PCShape"]) {
        NSDictionary *dictionary = [node extraPropForKey:name];
        if (!dictionary) dictionary = @{};
        
        NSData *propData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
        
        serializedValue = propData;
        
    }
    else if ([type isEqualToString:@"Array"]) {
        NSArray *array = [node extraPropForKey:name];
        if (!array) array = @[];
        
        NSData *propData = [NSKeyedArchiver archivedDataWithRootObject:array];
        
        serializedValue = propData;
    }
    else if ([type isEqualToString:@"MutableArray"]) {
        NSMutableArray *array = [node extraPropForKey:name];
        if (!array) array = [NSMutableArray array];
        
        NSData *propData = [NSKeyedArchiver archivedDataWithRootObject:array];
        
        serializedValue = propData;
    }
    else if ([type isEqualToString:@"FontTTF"])
    {
        NSString* str = [ResourcePropertySetter ttfForNode:node andProperty:name];
        if (!str) str = @"";
        serializedValue = str;
    }
    else if ([type isEqualToString:@"Block"])
    {
        NSString* selector = [extraProps objectForKey:name];
        NSNumber* target = [extraProps objectForKey:[NSString stringWithFormat:@"%@Target",name]];
        if (!selector) selector = @"";
        if (!target) target = [NSNumber numberWithInt:0];
        serializedValue = [NSArray arrayWithObjects:
                           selector,
                           target,
                           nil];
    }
    else if ([type isEqualToString:@"BlockCCControl"])
    {
        NSString* selector = [extraProps objectForKey:name];
        NSNumber* target = [extraProps objectForKey:[NSString stringWithFormat:@"%@Target",name]];
        NSNumber* ctrlEvts = [extraProps objectForKey:[NSString stringWithFormat:@"%@CtrlEvts",name]];
        if (!selector) selector = @"";
        if (!target) target = [NSNumber numberWithInt:0];
        if (!ctrlEvts) ctrlEvts = [NSNumber numberWithInt:0];
        serializedValue = [NSArray arrayWithObjects:
                           selector,
                           target,
                           ctrlEvts,
                           nil];
    }
    else
    {
        NSLog(@"WARNING Unrecognized property type: %@", type);
    }
    
    return serializedValue;
}

#pragma mark - Sprite Kit

+ (NSArray *)pluginPropertiesFromNode:(SKNode *)node {
    NodeInfo *info = node.userObject;
    if (!info) return @[];
    PlugInNode *plugIn = info.plugIn;
    return [self pluginPropertiesFromNode:node plugin:plugIn];
}

+ (NSArray *)pluginPropertiesFromNode:(SKNode *)node plugin:(PlugInNode *)plugIn {
    NSMutableArray *pluginProperties = [NSMutableArray array];
    NSMutableArray *plugInProps = plugIn.nodeProperties;
    int plugInPropsCount = [plugInProps count];
    for (int i = 0; i < plugInPropsCount; i++) {
        NSMutableDictionary *propInfo = plugInProps[i];
        id serializedValue = [CCBWriterInternal serializePropertyForSpriteKitNode:node propInfo:propInfo excludeProps:nil];
        if (!serializedValue) continue;

        NSString *type = propInfo[@"type"];
        NSString *name = propInfo[@"name"];
        NSString *platform = propInfo[@"platform"];
        BOOL hasKeyframes = [node hasKeyframesForProperty:name];

        NSMutableDictionary *prop = [NSMutableDictionary dictionary];

        prop[@"type"] = type;
        prop[@"name"] = name;
        prop[@"value"] = serializedValue;
        if (platform) prop[@"platform"] = platform;
        if (hasKeyframes) prop[@"baseValue"] = [node baseValueForProperty:name];

        [pluginProperties addObject:prop];
    }
    return [pluginProperties copy];
}

+ (NSArray *)dictionariesFromChildrenOfNode:(SKNode *)node plugin:(PlugInNode *)plugIn {
    // Children
    NSMutableArray *children = [NSMutableArray array];

    // Visit all children of this node
    if (plugIn.canHaveChildren) {
        NSArray *nodeChildren = [node children];
        if ([node conformsToProtocol:@protocol(PCNodeChildExport)]) {
            nodeChildren = [(id<PCNodeChildExport>)node exportChildren];
        }
        for (SKNode *node in nodeChildren) {
            [children addObject:[CCBWriterInternal dictionaryFromSKNode:node]];
        }
    }
    return [children copy];
}

+ (NSMutableDictionary *)dictionaryFromSKNode:(SKNode *)node {
    NodeInfo *info = node.userObject;
    if (!info) return [NSMutableDictionary dictionary];
    PlugInNode *plugIn = info.plugIn;
    NSMutableDictionary *extraProps = info.extraProps;

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *props = [self pluginPropertiesFromNode:node plugin:plugIn];

    // Create node
    NSString *baseClass = plugIn.nodeClassName;
    dict[@"properties"] = props;
    dict[@"baseClass"] = baseClass;
    dict[@"children"] = [self dictionariesFromChildrenOfNode:node plugin:plugIn];

    // Serialize any animations
    id anim = [node serializeAnimatedProperties];
    if (anim) dict[@"animatedProperties"] = anim;
    if (node.seqExpanded) dict[@"seqExpanded"] = @YES;

    if (node.displayName) dict[@"displayName"] = node.displayName;
    if (node.generatedName) dict[@"generatedName"] = node.generatedName;
    if (node.hideFromUI) dict[@"hideFromUI"] = @YES;
    if (node.uuid) dict[@"uuid"] = node.uuid;

    id customProps = [node serializeCustomProperties];
    if (customProps) dict[@"customProperties"] = customProps;
    if (node.usesFlashSkew) dict[@"usesFlashSkew"] = @YES;
    if (node.nodePhysicsBody) dict[@"physicsBody"] = [node.nodePhysicsBody serialization];
    if (node.hidden) dict[@"hidden"] = @YES;
    if (node.locked) dict[@"locked"] = @YES;

    NSArray *selection = [AppDelegate appDelegate].selectedSpriteKitNodes;
    if (selection && [selection containsObject:node]) dict[@"selected"] = @YES;

    dict[@"customClass"] = extraProps[@"customClass"] ?: @"";
    dict[@"memberVarAssignmentName"] = extraProps[@"memberVarAssignmentName"] ?: @"";
    dict[@"memberVarAssignmentType"] = extraProps[@"memberVarAssignmentType"];

    // JS code connections
    NSString *jsController = extraProps[@"jsController"];
    if (jsController && ![jsController isEqualToString:@""]) dict[@"jsController"] = jsController;

    return dict;
}

@end
