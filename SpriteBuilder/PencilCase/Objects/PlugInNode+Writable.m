//
//  PlugInNode+Writable.m
//  SpriteBuilder
//
//  Created by Quinn Thomson on 6/11/2014.
//
//

#import "PlugInNode+Writable.h"

@implementation PlugInNode (Writable)

NSString const *key = @"pluginNode+writable";

- (instancetype)initEmpty {
    self = [super init];
    if (!self) return NULL;
    
    self.comingSoon = NO;
    
    nodeClassName = @"emptyPlugin";
    nodeEditorClassName = @"emptyPlugin";
    
    displayName = @"emptyPlugin";
    descr = @"emptyPlugin";
    ordering = 100000;
    supportsTemplates = NO;
    
    NSURL *propsURL = [bundle URLForResource:@"CCBPProperties" withExtension:@"plist"];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithContentsOfURL:propsURL];
    NSBundle *appBundle = [NSBundle mainBundle];
    NSURL *plugInDir = [appBundle builtInPlugInsURL];
    NSArray *plugInPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:plugInDir includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
    NSURL *plugInPath;
    for (int i=0; i<[plugInPaths count];i++) {
        plugInPath = plugInPaths[i];
        if (![[plugInPath pathExtension] isEqualToString:@"ccbPlugNode"]) continue;
        break;
    }
    NSBundle *anyBundle = [NSBundle bundleWithURL:plugInPath];
    
    nodeProperties = [[self loadInheritableAndOverridableArrayForKey:@"properties" withUniqueIDKey:@"name" forBundle:anyBundle] mutableCopy];
    nodePropertiesDict = [[NSMutableDictionary alloc] init];

    [self setupNodePropsDict];
    
    // Support for spriteFrame drop targets
    NSDictionary *spriteFrameDrop = [props objectForKey:@"spriteFrameDrop"];
    if (spriteFrameDrop) {
        dropTargetSpriteFrameClass = [spriteFrameDrop objectForKey:@"className"];
        dropTargetSpriteFrameProperty = [spriteFrameDrop objectForKey:@"property"];
    }
    
    // Check if node type can be root node and which children are allowed
    canBeRoot = NO;
    canHaveChildren = NO;
    isAbstract = NO;
    requireChildClass = NO;
    requireParentClass = NO;
    positionProperty = [props objectForKey:@"positionProperty"];
    
    return self;
}

@end
