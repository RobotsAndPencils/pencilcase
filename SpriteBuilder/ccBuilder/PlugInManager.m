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

#import <SpriteKit/SpriteKit.h>
#import "SKNode+CocosCompatibility.h"
#import "PlugInManager.h"
#import "PlugInExport.h"
#import "SKNode+LifeCycle.h"

#if !CCB_BUILDING_COMMANDLINE
#import "PlugInNode.h"
#import "NodeInfo.h"
#import "CCBReaderInternal.h"
#endif

@implementation PlugInManager

#if !CCB_BUILDING_COMMANDLINE
@synthesize plugInsNodeNames, plugInsNodeNamesCanBeRoot;
#endif

@synthesize plugInsExporters;

+ (PlugInManager*) sharedManager
{
    static PlugInManager* manager = NULL;
    if (!manager) manager = [[PlugInManager alloc] init];
    return manager;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
#if !CCB_BUILDING_COMMANDLINE
    plugInsNode = [[NSMutableDictionary alloc] init];
    plugInsNodeNames = [[NSMutableArray alloc] init];
    plugInsNodeNamesCanBeRoot = [[NSMutableArray alloc] init];
#endif
    
    plugInsExporters = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) loadPlugIns
{
    // Locate the plug ins
#if CCB_BUILDING_COMMANDLINE
    // This shouldn't be hardcoded.
    NSURL* appURL = nil;
    OSStatus error = LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)@"com.robotsandpencils.PencilCase", NULL, NULL, (CFURLRef *)&appURL);
    NSBundle *appBundle = nil;
    
    if (error == noErr)
    {
        appBundle = [NSBundle bundleWithURL:appURL];
        [appURL release]; // LS documents that the URL returned must be released.
    }
    else
        appBundle = [NSBundle bundleWithIdentifier:@"com.robotsandpencils.PencilCase"]; // last-ditch effort
    
    if (!appBundle)
        return;
#else
    NSBundle* appBundle = [NSBundle mainBundle];
#endif
    
    NSURL* plugInDir = [appBundle builtInPlugInsURL];
    
    NSArray* plugInPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:plugInDir includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];

#if !CCB_BUILDING_COMMANDLINE    
    // Load PlugIn nodes
    for (int i = 0; i < [plugInPaths count]; i++)
    {
        NSURL* plugInPath = [plugInPaths objectAtIndex:i];
        
        // Verify that this is a node plug-in
        if (![[plugInPath pathExtension] isEqualToString:@"ccbPlugNode"]) continue;
        
        // Load the bundle
        NSBundle* bundle = [NSBundle bundleWithURL:plugInPath];
        
        if (bundle)
        {
            PCLog(@"Loading PlugIn: %@", [plugInPath lastPathComponent]);

            // Don't try to dynamically load code if it won't work.
            // Note that checking principalClass will load the code if it isn't
            // already.
            NSError *bundleLoadError;
            if ([bundle preflightAndReturnError:&bundleLoadError]) {
                [bundle load];
            }
            else {
                PCLog(@"%@", bundleLoadError);
            }
            
            PlugInNode* plugIn = [[PlugInNode alloc] initWithBundle:bundle];
            NSString *pluginName = plugIn.nodeClassName;
            if (plugIn && !plugIn.isAbstract)
            {
                [plugInsNode setObject:plugIn forKey:plugIn.nodeClassName];

                NSArray *pcasePlugins = @[ @"PCNodeColor", @"PCTextView", @"PCFingerPaintView", @"PCLabelTTF", @"PCNodeGradient", @"PCParticleSystem", @"PCButton", @"PCForceNode", @"PCTextField", @"PCWebViewNode", @"PCCameraCaptureNode", @"PCTextInputView", @"PCTableNode", @"PCShapeNode", @"PCSwitchNode", @"PCSliderNode", @"PCMultiViewNode", @"PCScrollViewNode" ];
                
                if (![pcasePlugins containsObject:pluginName]) continue;
                
                [plugInsNodeNames addObject:plugIn.nodeClassName];
                
                if (plugIn.canBeRoot)
                {
                    [plugInsNodeNamesCanBeRoot addObject:plugIn.nodeClassName];
                }
            }
            
            // Load icon
            plugIn.icon = [bundle imageForResource:@"Icon"];
        }
    }
#endif
    plugInsNodeNames = [self orderPluginList:self.plugInsNodeNames];
    // Load PlugIn exporters
    for (int i = 0; i < [plugInPaths count]; i++)
    {
        NSURL* plugInPath = [plugInPaths objectAtIndex:i];
        
        // Verify that this is an exporter plug-in
        if (![[plugInPath pathExtension] isEqualToString:@"ccbPlugExport"]) continue;
        
        // Load the bundle
        NSBundle* bundle = [NSBundle bundleWithURL:plugInPath];
        if (bundle)
        {
            PCLog(@"Loading PlugIn: %@", [plugInPath lastPathComponent]);
            
            // Don't try to dynamically load code if it won't work.
            // Note that checking principalClass will load the code if it isn't
            // already.
            NSError *bundleLoadError;
            if ([bundle preflightAndReturnError:&bundleLoadError]) {
                [bundle load];
            }
            else {
                PCLog(@"%@", bundleLoadError);
            }
            
            PlugInExport* plugIn = [[PlugInExport alloc] initWithBundle:bundle];
            if (plugIn)
            {
                NSString* plugInName = [[plugInPath lastPathComponent] stringByDeletingPathExtension];
                plugIn.pluginName = plugInName;
                
                [plugInsExporters addObject:plugIn];
            }
        }
    }
}

- (NSMutableArray *)orderPluginList:(NSMutableArray *)pluginNames {
    NSMutableArray *sortedNames = [@[ @"PCButton", @"PCNodeColor", @"PCNodeGradient", @"PCLabelTTF", @"PCTextView", @"PCTextField", @"PCTextInputView", @"PCTableNode", @"PCWebViewNode", @"PCSwitchNode", @"PCSliderNode", @"PCMultiViewNode", @"PCScrollViewNode", @"PCCameraCaptureNode", @"PCFingerPaintView", @"PCShapeNode", @"PCForceNode", @"PCParticleSystem" ] mutableCopy];
    
    // Add any names we haven't accounted for to the end
    for (NSString *pluginName in pluginNames) {
        if (![sortedNames containsObject:pluginName]) {
            [sortedNames addObject:pluginName];
        }
    }
    
    // Remove any names that have been deleted but forgot to update this list
    for (NSString *pluginName in sortedNames) {
        if (![pluginNames containsObject:pluginName]) {
            [sortedNames removeObject:pluginName];
        }
    }
    
    return sortedNames;
}

#if !CCB_BUILDING_COMMANDLINE
- (PlugInNode*) plugInNodeNamed:(NSString*)name
{
    return [plugInsNode objectForKey:name];
}

- (PlugInNode *)pluginNodeForType:(PCNodeType)type {
    for (PlugInNode *plugin in [plugInsNode allValues]) {
        if (plugin.nodeType == type) return plugin;
    }
    NSAssert(NO, @"Missing Plugin Type");
    return nil;
}

- (SKNode *)createDefaultSpriteKitNodeOfType:(NSString *)name andConfigureWithBlock:(void (^)(SKNode *))block {
    PlugInNode* plugin = [self plugInNodeNamed:name];
    if (!plugin) return nil;
    if (plugin.comingSoon) return nil;
    
    Class editorClass = NSClassFromString(plugin.nodeEditorSpriteKitClassName);
    if (!editorClass) {
        NSLog(@"WARNING: class %@ not found, defined in plugin %@.", plugin.nodeEditorSpriteKitClassName, name);
        return nil;
    }
    
    SKNode *node = [[editorClass alloc] init];
    node.userObject = [NodeInfo nodeInfoWithPlugIn:plugin];
    
    NodeInfo *nodeInfo = node.userObject;
    NSMutableDictionary *extraProps = nodeInfo.extraProps;
    
    // Set default data
    NSMutableArray *plugInProps = plugin.nodeProperties;
    for (NSDictionary *propInfo in plugInProps) {
        id defaultValue = [propInfo objectForKey:@"default"];
        if (!defaultValue) continue;

        NSString* name = [propInfo objectForKey:@"name"];
        NSString* type = [propInfo objectForKey:@"type"];
        
        if ([[propInfo objectForKey:@"dontSetInEditor"] boolValue]) {
            // Use an extra prop instead of the real object property
            [extraProps setObject:defaultValue forKey:name];
        }
        else {
            // Set the property on the object
            [CCBReaderInternal setProp:name ofType:type toValue:defaultValue forSpriteKitNode:node parentSize:CGSizeZero];
        }
    }

    if (block) block(node);
    [node pc_didLoad];
    return node;
}
#endif

- (NSArray*) plugInsExportNames
{
    NSMutableArray* arr = [NSMutableArray array];
    for (int i = 0; i < [plugInsExporters count]; i++)
    {
        PlugInExport* plugIn = [plugInsExporters objectAtIndex:i];
        [arr addObject:plugIn.pluginName];
    }
    return arr;
}

- (PlugInExport*) plugInExportForIndex:(int)idx
{
    return [plugInsExporters objectAtIndex:idx];
}

- (PlugInExport*) plugInExportForExtension:(NSString*)ext
{
    for (int i = 0; i < [plugInsExporters count]; i++)
    {
        PlugInExport* plugIn = [plugInsExporters objectAtIndex:i];
        if ([[plugIn extension] isEqualToString:ext])
        {
            return plugIn;
        }
    }
    return NULL;
}

@end
