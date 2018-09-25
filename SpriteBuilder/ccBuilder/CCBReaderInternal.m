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

// Frameworks/Pods
#import <SpriteKit/SpriteKit.h>

// Categories
#import "SKNode+CocosCompatibility.h"
#import "SKNode+Sequencer.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+LifeCycle.h"

#import "CCBReaderInternal.h"
#import "PlugInManager.h"
#import "PlugInNode.h"
#import "NodeInfo.h"
#import "CCBWriterInternal.h"
#import "ResourcePropertySetter.h"
#import "AppDelegate.h"
#import "PCResourceManager.h"
#import "NodeGraphPropertySetter.h"
#import "PositionPropertySetter.h"
#import "StringPropertySetter.h"
#import "NodePhysicsBody.h"
#import "AppDelegate.h"
#import "PCProjectSettings.h"
#import "ResourceManagerUtil.h"
#import "PCResourceLibrary.h"

// Old positioning constants
enum
{
    kCCBPositionTypeRelativeBottomLeft,
    kCCBPositionTypeRelativeTopLeft,
    kCCBPositionTypeRelativeTopRight,
    kCCBPositionTypeRelativeBottomRight,
    kCCBPositionTypePercent,
    kCCBPositionTypeMultiplyResolution,
};

enum
{
    kCCBSizeTypeAbsolute,
    kCCBSizeTypePercent,
    kCCBSizeTypeRelativeContainer,
    kCCBSizeTypeHorizontalPercent,
    kCCBSzieTypeVerticalPercent,
    kCCBSizeTypeMultiplyResolution,
};

const CGFloat PCMinimumSupportedFileVersion = 4.0;

__strong NSDictionary* renamedProperties = nil;

@implementation CCBReaderInternal

+ (NSPoint) deserializePoint:(id) val
{
    float x = [[val objectAtIndex:0] floatValue];
    float y = [[val objectAtIndex:1] floatValue];
    return NSMakePoint(x,y);
}

+ (NSSize) deserializeSize:(id) val
{
    float w = [[val objectAtIndex:0] floatValue];
    float h = [[val objectAtIndex:1] floatValue];
    return NSMakeSize(w, h);
}

+ (float) deserializeFloat:(id) val
{
    return [val floatValue];
}

+ (int) deserializeInt:(id) val
{
    return [val intValue];
}

+ (BOOL) deserializeBool:(id) val
{
    return [val boolValue];
}

+ (NSColor *)deserializeNSColor:(id)val {
    CGFloat r,g,b,a;
    r = [[val objectAtIndex:0] floatValue];
    g = [[val objectAtIndex:1] floatValue];
    b = [[val objectAtIndex:2] floatValue];
    a = [[val objectAtIndex:3] floatValue];
    return [NSColor colorWithDeviceRed:r green:g blue:b alpha:a];
}

+ (void)setProp:(NSString *)name ofType:(NSString *)type toValue:(id)serializedValue forSpriteKitNode:(SKNode *)node parentSize:(CGSize)parentSize {
    // Handle removed ignoreAnchorPointForPosition property
    if ([name isEqualToString:@"ignoreAnchorPointForPosition"]) return;

    if ([type isEqualToString:@"Position"]) {
        float x = [serializedValue[0] floatValue];
        float y = [serializedValue[1] floatValue];
        [PositionPropertySetter setPosition:NSMakePoint(x, y) forSpriteKitNode:node prop:name];
    }
    else if ([type isEqualToString:@"Point"]
        || [type isEqualToString:@"PointLock"]) {
        NSPoint pt = [CCBReaderInternal deserializePoint:serializedValue];

        [node setValue:[NSValue valueWithPoint:pt] forKey:name];
    }
    else if ([type isEqualToString:@"Size"]) {
        float w = [serializedValue[0] floatValue];
        float h = [serializedValue[1] floatValue];

        NSSize size = NSMakeSize(w, h);
        [PositionPropertySetter setSize:size forSpriteKitNode:node prop:name];
    }
    else if ([type isEqualToString:@"Scale"]
        || [type isEqualToString:@"ScaleLock"]) {
        float x = [[serializedValue objectAtIndex:0] floatValue];
        float y = [[serializedValue objectAtIndex:1] floatValue];
        if ([(NSArray *)serializedValue count] >= 3) {
            [node setExtraProp:serializedValue[2] forKey:[NSString stringWithFormat:@"%@Lock", name]];
        }
        [PositionPropertySetter setScaledX:x Y:y forSpriteKitNode:node prop:name];
    }
    else if ([type isEqualToString:@"FloatXY"]) {
        float x = [[serializedValue objectAtIndex:0] floatValue];
        float y = [[serializedValue objectAtIndex:1] floatValue];
        [node setValue:[NSNumber numberWithFloat:x] forKey:[name stringByAppendingString:@"X"]];
        [node setValue:[NSNumber numberWithFloat:y] forKey:[name stringByAppendingString:@"Y"]];
    }
    else if ([type isEqualToString:@"Float"]
        || [type isEqualToString:@"Degrees"]) {
        float f = [CCBReaderInternal deserializeFloat:serializedValue];
        [node setValue:[NSNumber numberWithFloat:f] forKey:name];
    }
    else if ([type isEqualToString:@"FloatScale"]) {
        float f = 0;
        if ([serializedValue isKindOfClass:[NSNumber class]]) {
            // Support for old files
            f = [serializedValue floatValue];
        }
        else {
            f = [serializedValue[0] floatValue];
        }
        [PositionPropertySetter setFloatScale:f forNode:node prop:name];
    }
    else if ([type isEqualToString:@"FloatVar"]) {
        [node setValue:[serializedValue objectAtIndex:0] forKey:name];
        [node setValue:[serializedValue objectAtIndex:1] forKey:[NSString stringWithFormat:@"%@Range", name]];
    }
    else if ([type isEqualToString:@"Integer"]
        || [type isEqualToString:@"IntegerLabeled"]
        || [type isEqualToString:@"Byte"]) {
        int d = [CCBReaderInternal deserializeInt:serializedValue];
        [node setValue:[NSNumber numberWithInt:d] forKey:name];
    }
    else if ([type isEqualToString:@"Check"]) {
        BOOL check = [CCBReaderInternal deserializeBool:serializedValue];
        [node setValue:[NSNumber numberWithBool:check] forKey:name];
    }
    else if ([type isEqualToString:@"Flip"]) {
        [node setValue:[serializedValue objectAtIndex:0] forKey:[NSString stringWithFormat:@"%@X", name]];
        [node setValue:[serializedValue objectAtIndex:1] forKey:[NSString stringWithFormat:@"%@Y", name]];
    }
    else if ([type isEqualToString:@"SpriteFrame"]) {
        if (![serializedValue isKindOfClass:[NSString class]]) {
            NSLog(@"Invalid input for sprite frame: %@", serializedValue);
            return;
        }
        NSString *spriteUUID = serializedValue;
        PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:spriteUUID];
        if (!resource) {
            //HACK Until we convert buttons to templates - need to be able to load theirs from filename because UUID is not guaranteed
            spriteUUID = [ResourceManagerUtil uuidForResourceWithRelativePath:serializedValue];
            resource = [[PCResourceManager sharedManager] resourceWithUUID:spriteUUID];
        }

        if (resource) {
            [node setExtraProp:spriteUUID forKey:name];
            SKTexture *texture = [[PCResourceLibrary sharedLibrary] textureForResource:resource];
            if (texture) {
                [node setValue:texture forKey:name];
            } else {
                NSLog(@"WARNING: Could not find asset at path %@ for resource with UUID %@", resource.filePath, resource.uuid);
            }
        } else if (!PCIsEmpty(serializedValue)) {
            [node showMissingResourceImageWithKey:name];
        }
    }
    else if ([type isEqualToString:@"ResourceUUID"]) {
        NSString *resourceUUID = serializedValue;
        PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:resourceUUID];
        if (!resource) {
            return;
        }
        [node setExtraProp:resourceUUID forKey:name];
        [node setValue:resourceUUID forKey:name];
    }
    else if ([type isEqualToString:@"Color4"] ||
        [type isEqualToString:@"Color3"]) {
        NSColor *color = [CCBReaderInternal deserializeNSColor:serializedValue];
        [node setValue:color forKey:name];
    }
    else if ([type isEqualToString:@"Color4FVar"]) {
        NSColor *color = [CCBReaderInternal deserializeNSColor:[serializedValue objectAtIndex:0]];
        NSColor *colorVar = [CCBReaderInternal deserializeNSColor:[serializedValue objectAtIndex:1]];
        [node setValue:color forKey:name];
        [node setValue:colorVar forKey:[NSString stringWithFormat:@"%@Range", name]];
    }
    else if ([type isEqualToString:@"StringSimple"]) {
        NSString *str = serializedValue;
        if (!str) str = @"";
        [node setValue:str forKey:name];
    }
    else if ([type isEqualToString:@"Text"]
        || [type isEqualToString:@"String"]
        || [type isEqualToString:@"JavaScript"]) {
        NSString *str = nil;
        BOOL localized = NO;

        if ([serializedValue isKindOfClass:[NSString class]]) {
            str = serializedValue;
        }
        else {
            str = [serializedValue objectAtIndex:0];
            localized = [[serializedValue objectAtIndex:1] boolValue];
        }

        if (!str) str = @"";
        [StringPropertySetter setString:str forNode:node andProp:name];
        [StringPropertySetter setLocalized:localized forNode:node andProp:name];
    }
    else if ([type isEqualToString:@"Dictionary"]
        || [type isEqualToString:@"Build"]
        || [type isEqualToString:@"PCShape"]) {
        NSDictionary *dictionary = serializedValue;
        if (![dictionary isKindOfClass:[NSDictionary class]]) {
            dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:serializedValue];
        }
        [node setValue:dictionary forKey:name];
    }
    else if ([type isEqualToString:@"Array"]) {
        NSArray *array = serializedValue;
        if (![array isKindOfClass:[NSArray class]]) {
            array = [NSKeyedUnarchiver unarchiveObjectWithData:serializedValue];
        }
        [node setValue:array forKey:name];
    }
    else if ([type isEqualToString:@"MutableArray"]) {
        NSMutableArray *array = serializedValue;
        if (![array isKindOfClass:[NSMutableArray class]]) {
            array = [NSKeyedUnarchiver unarchiveObjectWithData:serializedValue];
        }
        [node setValue:array forKey:name];
    }
    else if ([type isEqualToString:@"FontTTF"]) {
        NSString *str = serializedValue;
        if (!str) str = @"";
        [ResourcePropertySetter setTtfForNode:node andProperty:name withFont:str];
    }
    else if ([type isEqualToString:@"Block"]) {
        NSString *selector = [serializedValue objectAtIndex:0];
        NSNumber *target = [serializedValue objectAtIndex:1];
        if (!selector) selector = @"";
        if (!target) target = [NSNumber numberWithInt:0];
        [node setExtraProp:selector forKey:name];
        [node setExtraProp:target forKey:[NSString stringWithFormat:@"%@Target", name]];
    }
    else if ([type isEqualToString:@"BlockCCControl"]) {
        NSString *selector = [serializedValue objectAtIndex:0];
        NSNumber *target = [serializedValue objectAtIndex:1];
        NSNumber *ctrlEvts = [serializedValue objectAtIndex:2];
        if (!selector) selector = @"";
        if (!target) target = [NSNumber numberWithInt:0];
        if (!ctrlEvts) ctrlEvts = [NSNumber numberWithInt:0];
        [node setExtraProp:selector forKey:name];
        [node setExtraProp:target forKey:[NSString stringWithFormat:@"%@Target", name]];
        [node setExtraProp:ctrlEvts forKey:[NSString stringWithFormat:@"%@CtrlEvts", name]];
    }
    else {
        NSLog(@"WARNING Unrecognized property type: %@", type);
    }
}

+ (NSDictionary *)getRenamedPropertiesDict {
    if (!renamedProperties) {
        renamedProperties = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CCBReaderInternalRenamedProps" ofType:@"plist"]];
        NSAssert(renamedProperties, @"Failed to load renamed properties dict");
    }
    return renamedProperties;
}

#pragma mark Sprite Kit

+ (SKNode*) spriteKitNodeGraphFromDictionary:(NSDictionary*) dict parentSize:(CGSize)parentSize {
    if (!renamedProperties)
    {
        renamedProperties = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CCBReaderInternalRenamedProps" ofType:@"plist"]];
        
        NSAssert(renamedProperties, @"Failed to load renamed properties dict");
    }
    
    NSArray* props = [dict objectForKey:@"properties"];
    NSString* baseClass = [dict objectForKey:@"baseClass"];
    NSArray* children = [dict objectForKey:@"children"];
    
    // Create the node
    SKNode *node = [[PlugInManager sharedManager] createDefaultSpriteKitNodeOfType:baseClass andConfigureWithBlock:^(SKNode *node) {

        // Fetch info and extra properties
        NodeInfo* nodeInfo = node.userObject;
        NSMutableDictionary* extraProps = nodeInfo.extraProps;
        PlugInNode* plugIn = nodeInfo.plugIn;

        // Flash skew compatibility
        if ([[dict objectForKey:@"usesFlashSkew"] boolValue])
        {
            [node setUsesFlashSkew:YES];
        }

        // Hidden node graph
        if ([[dict objectForKey:@"hidden"] boolValue])
        {
            node.hidden = YES;
        }

        // Locked node
        if ([[dict objectForKey:@"locked"] boolValue])
        {
            node.locked = YES;
        }

        // Set properties for the node
        int numProps = [props count];
        for (int i = 0; i < numProps; i++)
        {
            NSDictionary* propInfo = [props objectAtIndex:i];
            NSString* type = [propInfo objectForKey:@"type"];
            NSString* name = [propInfo objectForKey:@"name"];
            id serializedValue = [propInfo objectForKey:@"value"];

            // Check for renamings
            NSDictionary* renameRule = [renamedProperties objectForKey:name];
            if (renameRule)
            {
                name = [renameRule objectForKey:@"newName"];
            }
            else
            {
                name = [plugIn migratedNameForPropertyNamed:name] ? : name;
            }

            if ([plugIn dontSetInEditorProperty:name])
            {
                [extraProps setObject:serializedValue forKey:name];
            }
            else
            {
                [CCBReaderInternal setProp:name ofType:type toValue:serializedValue forSpriteKitNode:node parentSize:parentSize];
            }
            id baseValue = [propInfo objectForKey:@"baseValue"];
            if (baseValue) [node setBaseValue:baseValue forProperty:name];
        }

        // Set extra properties for code connections
        NSString* customClass = [dict objectForKey:@"customClass"];
        if (!customClass) customClass = @"";
        NSString* memberVarName = [dict objectForKey:@"memberVarAssignmentName"];
        if (!memberVarName) memberVarName = @"";
        int memberVarType = [[dict objectForKey:@"memberVarAssignmentType"] intValue];

        [extraProps setObject:customClass forKey:@"customClass"];
        [extraProps setObject:memberVarName forKey:@"memberVarAssignmentName"];
        [extraProps setObject:[NSNumber numberWithInt:memberVarType] forKey:@"memberVarAssignmentType"];

        // JS code connections
        NSString* jsController = [dict objectForKey:@"jsController"];
        if (jsController)
        {
            [extraProps setObject:jsController forKey:@"jsController"];
        }

        NSString* displayName = [dict objectForKey:@"displayName"];
        if (displayName)
        {
            node.displayName = displayName;
        }

        NSString *instanceName = [dict objectForKey:@"generatedName"];
        if (instanceName)
        {
            node.generatedName = instanceName;
        }

        NSNumber *hideFromUI = [dict objectForKey:@"hideFromUI"];
        if (hideFromUI) {
            node.hideFromUI = [hideFromUI boolValue];
        }

        NSString *uuid = [dict objectForKey:@"uuid"];
        if (uuid) {
            node.uuid = uuid;
        }

        id animatedProps = [dict objectForKey:@"animatedProperties"];
        [node loadAnimatedPropertiesFromSerialization:animatedProps];
        node.seqExpanded = [[dict objectForKey:@"seqExpanded"] boolValue];

        CGSize contentSize = node.contentSize;
        for (int i = 0; i < [children count]; i++)
        {
            SKNode* child = [CCBReaderInternal spriteKitNodeGraphFromDictionary:[children objectAtIndex:i] parentSize:contentSize];
            if (child) [[node childInsertionNode] addChild:child];
        }

        // Physics
        if ([dict objectForKey:@"physicsBody"])
        {
            node.nodePhysicsBody = [[NodePhysicsBody alloc] initWithSerialization:[dict objectForKey:@"physicsBody"] observingNode:node];
        }

        // Selections
        if ([[dict objectForKey:@"selected"] boolValue])
        {
            [[AppDelegate appDelegate].loadedSelectedSpriteKitNodes addObject:node];
        }

        BOOL isCCBSubFile = [baseClass isEqualToString:@"CCBFile"];
        
        // Load custom properties
        if (isCCBSubFile)
        {
            // For sub ccb files the custom properties are already loaded by the sub file and forwarded. We just need to override the values from the sub ccb file
            [node loadCustomPropertyValuesFromSerialization:[dict objectForKey:@"customProperties"]];
        }
        else
        {
            [node loadCustomPropertiesFromSerialization:[dict objectForKey:@"customProperties"]];
        }
    }];

    if (!node) {
        NSLog(@"WARNING! Plug-in missing for %@", baseClass);
    }

    return node;
}

+ (SKNode *)spriteKitNodeGraphFromDocumentDictionary:(NSDictionary *)dict parentSize:(CGSize)parentSize {
    if (!dict) {
        NSLog(@"WARNING! Trying to load invalid file type (dict is null)");
        return nil;
    }
    // Load file metadata
    
    NSString *fileType = [dict objectForKey:@"fileType"];
    int fileVersion = [[dict objectForKey:@"fileVersion"] intValue];
    
    if (!fileType  || ![fileType isEqualToString:@"CocosBuilder"]) {
        NSLog(@"WARNING! Trying to load invalid file type (%@)", fileType);
    }
    
    NSDictionary *nodeGraph = [dict objectForKey:@"nodeGraph"];
    if (fileVersion < PCMinimumSupportedFileVersion) {
        // project is to old to open in PencilCase - handle error here.
    }
    return [CCBReaderInternal spriteKitNodeGraphFromDictionary:nodeGraph parentSize:parentSize];
}

@end
