//
//  StringPropertySetter.m
//  SpriteBuilder
//
//  Created by Viktor on 8/9/13.
//
//

#import "StringPropertySetter.h"
#import "AppDelegate.h"
#import "LocalizationEditorHandler.h"
#import "PlugInNode.h"
#import "SKNode+NodeInfo.h"
#import "PCStageScene.h"

@implementation StringPropertySetter

+ (void) refreshStringProp:(NSString*)prop forNode:(SKNode *)node
{
    NSString* str = [StringPropertySetter stringForNode:node andProp:prop];
    BOOL localize = [StringPropertySetter isLocalizedNode:node andProp:prop];
    
    if (localize)
    {
        str = [[AppDelegate appDelegate].localizationEditorHandler translationForKey:str];
    }
    
    [node setValue:str forKey:prop];
}

+ (void) setString:(NSString*)str forNode:(SKNode *)node andProp:(NSString*)prop
{
    if (!str) str = @"";
    [node setExtraProp:str forKey:prop];
    [StringPropertySetter refreshStringProp:prop forNode:node];
}

+ (NSString*) stringForNode:(SKNode*)node andProp:(NSString*)prop
{
    NSString* str = [node extraPropForKey:prop];
    if (!str)
    {
        str = [node valueForKey:prop];
    }
    if (!str)
    {
        str = @"";
    }
    return str;
}

+ (void) setLocalized:(BOOL)localized forNode:(SKNode*)node andProp:(NSString*)prop {
    [node setExtraProp: [NSNumber numberWithBool:localized] forKey:[prop stringByAppendingString:@"Localized"]];
    [StringPropertySetter refreshStringProp:prop forNode:node];
}

+ (BOOL) isLocalizedNode:(SKNode*)node andProp:(NSString*)prop
{
    return [[node extraPropForKey:[prop stringByAppendingString:@"Localized"]] boolValue];
}

+ (BOOL) hasTranslationForNode:(SKNode*)node andProp:(NSString*)prop
{
    NSString* str = [self stringForNode:node andProp:prop];
    return [[AppDelegate appDelegate].localizationEditorHandler hasTranslationForKey:str];
}

+ (void) refreshAllStringProps
{
    SKNode *rootNode = [PCStageScene scene].rootNode;
    [StringPropertySetter refreshStringPropsForNodeTree:rootNode];
}

+ (void)refreshStringPropsForNodeTree:(SKNode *)node {
    for (NSString *prop in [node.plugIn localizablePropertiesForNode:node]) {
        [StringPropertySetter refreshStringProp:prop forNode:node];
    }
    
    // Refresh all children also
    for (SKNode* child in node.children) {
        [StringPropertySetter refreshStringPropsForNodeTree:child];
    }
}

@end
