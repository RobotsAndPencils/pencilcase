//
//  SKNode(JavaScript)
//  PCPlayer
//
//  Created by brandon on 2/3/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "SKNode+JavaScript.h"
#import "RXCollection.h"
#import <objc/runtime.h>

NS_ENUM(NSInteger, BuildType) {
    NoneBuildType = 0,
    FadeBuildType,
    SlideLeftBuildType,
    BuildCount
};

NS_ENUM(NSInteger, EaseType) {
    LinearEaseType = 0,
    InEaseType,
    OutEaseType,
    InOutEaseType,
    BounceEaseType
};

NS_ENUM(NSInteger, BuildDirection) {
    InBuildDirection = 0,
    OutBuildDirection
};

static void *InstanceNameKey = &InstanceNameKey;
static void *EventScriptsKey = &EventScriptsKey;
static void *UUIDKey = &UUIDKey;
static void *OriginalVisibilityKey = &OriginalVisibilityKey;

@implementation SKNode (JavaScript)

#pragma mark - Properties

- (void)setGeneratedName:(NSString *)generatedName {
    objc_setAssociatedObject(self, InstanceNameKey, generatedName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)generatedName {
    return objc_getAssociatedObject(self, InstanceNameKey);
}

- (void)setEventScripts:(NSMutableDictionary *)eventScripts {
    objc_setAssociatedObject(self, EventScriptsKey, eventScripts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)eventScripts {
    return objc_getAssociatedObject(self, EventScriptsKey);
}

- (NSString *)uuid {
    return objc_getAssociatedObject(self, UUIDKey);
}

- (void)setUuid:(NSString *)uuid {
    objc_setAssociatedObject(self, UUIDKey, uuid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)originalOpacity {
    return [objc_getAssociatedObject(self, OriginalVisibilityKey) floatValue];
}

- (void)setOriginalOpacity:(CGFloat)originalOpacity {
    objc_setAssociatedObject(self, OriginalVisibilityKey, @(originalOpacity), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
