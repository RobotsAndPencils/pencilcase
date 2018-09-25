//
//  PCToken.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-18.
//
//

#import "PCBrowseTokenNode.h"

#import <Underscore.m/Underscore.h>

#import "PCStageScene.h"
#import "PlugInNode.h"
#import "PCBrowseTokenProperty.h"

#import "SKNode+JavaScript.h"
#import "SKNode+NodeInfo.h"

@interface PCBrowseTokenNode ()

@property (strong, nonatomic, readwrite) SKNode *node;

@end


@implementation PCBrowseTokenNode

+ (instancetype)tokenWithNode:(SKNode *)node {
    return [[self alloc] initWithNode:node];
}

- (instancetype)initWithNode:(SKNode *)node {
    self = [super init];
    if (self) {
        _node = node;
    }
    return self;
}

+ (NSArray *)tokensForObjectsOnCurrentCard {
    return Underscore.array([self filteredNodes]).map(^id(SKNode *node){
        return [self tokenForNode:node];
    }).unwrap;
}

+ (NSArray *)filteredNodes {
    return Underscore.array([[PCStageScene scene].rootNode allNodes]).filter(^BOOL(SKNode *node){
        return !PCIsEmpty(node.name);
    }).unwrap;
}

+ (PCBrowseTokenNode *)tokenForNode:(SKNode *)node {
    return [PCBrowseTokenNode tokenWithNode:node];
}

#pragma mark - PCTokenBrowsable

- (NSString *)browseDisplayName {
    return self.node.name;
}

- (NSArray *)browseChildren {
    PlugInNode *plugin = self.node.plugIn;
    NSMutableArray *tokens = [NSMutableArray array];
    for (NSDictionary *propertyInfo in plugin.nodeProperties) {
        [tokens addObjectsFromArray:[PCBrowseTokenProperty propertyTokensFromPropertyInfo:propertyInfo]];
    }
    return tokens;
}

- (BOOL)isSelectable {
    return YES;
}

@end
