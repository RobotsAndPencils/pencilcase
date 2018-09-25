//
//  CCNode(JavaScript)
//  PROJECTNAME
//
//  Created by brandon on 2/3/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "SKNode+JavaScript.h"

static void *InstanceNameKey = &InstanceNameKey;
static void *BuildInKey = &BuildInKey;
static void *BuildOutKey = &BuildOutKey;
static void *EventScriptsKey = &EventScriptsKey;
static void *UUIDKey = &UUIDKey;
static void *OriginalVisibilityKey = &OriginalVisibilityKey;
static void *HasBuildInKey = &HasBuildInKey;
static void *HasBuildOutKey = &HasBuildOutKey;

@implementation SKNode (JavaScript)

#pragma mark - Properties

- (void)setGeneratedName:(NSString *)generatedName {
    objc_setAssociatedObject(self, InstanceNameKey, generatedName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSString *)uniqueInstanceName {
    NSString *uniqueString = [[NSUUID UUID] UUIDString];
    return [@"var" stringByAppendingString:[uniqueString stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}

- (NSString *)generatedName {
    return objc_getAssociatedObject(self, InstanceNameKey);
}

- (void)setBuildIn:(NSDictionary *)buildIn {
    objc_setAssociatedObject(self, BuildInKey, buildIn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)buildIn {
    return objc_getAssociatedObject(self, BuildInKey);
}

- (void)setBuildOut:(NSDictionary *)buildOut {
    objc_setAssociatedObject(self, BuildOutKey, buildOut, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)buildOut {
    return objc_getAssociatedObject(self, BuildOutKey);
}

- (CGFloat)originalOpacity {
    return [objc_getAssociatedObject(self, OriginalVisibilityKey) floatValue];
}

- (void)setOriginalOpacity:(CGFloat)originalOpacity {
    objc_setAssociatedObject(self, OriginalVisibilityKey, @(originalOpacity), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hasBuildIn {
    return [objc_getAssociatedObject(self, HasBuildInKey) boolValue];
}

- (void)setHasBuildIn:(BOOL)hasBuildIn {
    objc_setAssociatedObject(self, HasBuildInKey, @(hasBuildIn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hasBuildOut {
    return [objc_getAssociatedObject(self, HasBuildOutKey) boolValue];
}

- (void)setHasBuildOut:(BOOL)hasBuildOut {
    objc_setAssociatedObject(self, HasBuildOutKey, @(hasBuildOut), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)eventScripts {
    return nil;
}

- (void)setEventScripts:(NSMutableArray *)eventScripts {
}

#pragma mark - Public

- (NSArray *)allNodes {
    NSMutableArray *nodes = [@[ self ] mutableCopy];

    for (SKNode *child in self.children) {
        if ([child.children count] > 0) {
            [nodes addObjectsFromArray:[child allNodes]];
        } else {
            [nodes addObject:child];
        }
    }

    return nodes;
}

@end
