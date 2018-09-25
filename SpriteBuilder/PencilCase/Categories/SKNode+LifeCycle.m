//
//  SKNode+LifeCycle.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-10.
//
//

#import "SKNode+LifeCycle.h"
#import "PCSwizzleHelper.h"

@implementation SKNode (LifeCycle)

+ (void)pc_setupLifecycleCallbacks {
    // Which methods to swizzle came from: https://github.com/KoboldKit/KoboldKit/blob/master/KoboldKit/KoboldKitFree/Framework/Nodes/Framework/KKNodeShared.h
    
    __block IMP originalAddChild = PCReplaceMethodWithBlock([SKNode class], @selector(addChild:), ^(SKNode *_self, SKNode *child) {
        [child pc_willMoveToParent:_self];
        BOOL enteringScene = (_self.scene || [_self isKindOfClass:[SKScene class]]);
        ((void ( *)(id, SEL, SKNode *))originalAddChild)(_self, @selector(addChild:), child);
        if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:pc_ElCapitanOperatingSystemVersion]) {
            //It looks like in El Cap, addChild has been modified to just call insertChild:atIndex:0. Makes sense, but it means that we are calling didEnterScene twice, once in our swizzle for that method and once here.
            [child pc_didMoveToParent];
            if (enteringScene) [child pc_didEnterScene];
        }
    });
    
    __block IMP originalInsertChildAtIndex = PCReplaceMethodWithBlock([SKNode class], @selector(insertChild:atIndex:), ^(SKNode *_self, SKNode *child, NSInteger index) {
        [child pc_willMoveToParent:_self];
        BOOL enteringScene = (_self.scene || [_self isKindOfClass:[SKScene class]]);
        ((void ( *)(id, SEL, SKNode *, NSInteger))originalInsertChildAtIndex)(_self, @selector(insertChild:atIndex:), child, index);
        [child pc_didMoveToParent];
        if (enteringScene) [child pc_didEnterScene];
    });
    
    __block IMP originalRemoveFromParent = PCReplaceMethodWithBlock([SKNode class], @selector(removeFromParent), ^(SKNode *_self) {
        if (_self.scene) [_self pc_willExitScene];
        [_self pc_willMoveToParent:nil];
        ((void ( *)(id, SEL))originalRemoveFromParent)(_self, @selector(removeFromParent));
        [_self pc_didMoveToParent];
    });
    
    __block IMP originalRemoveAllChildren = PCReplaceMethodWithBlock([SKNode class], @selector(removeAllChildren), ^(SKNode *_self) {
        for (SKNode *child in _self.children) {
            if (child.scene) [child pc_willExitScene];
            [child pc_willMoveToParent:nil];
        }
        ((void ( *)(id, SEL))originalRemoveAllChildren)(_self, @selector(removeAllChildren));
        for (SKNode *child in _self.children) {
            [child pc_didMoveToParent];
        }
    });
    
    __block IMP originalRemoveChildrenInArray = PCReplaceMethodWithBlock([SKNode class], @selector(removeChildrenInArray:), ^(SKNode *_self, NSArray *children) {
        for (SKNode *child in children) {
            if (child.scene) [child pc_willExitScene];
            [child pc_willMoveToParent:nil];
        }
        ((void ( *)(id, SEL, NSArray *))originalRemoveChildrenInArray)(_self, @selector(removeChildrenInArray:), children);
        for (SKNode *child in children) {
            [child pc_didMoveToParent];
        }
    });
}

#pragma mark - New Life Cycle Calls

- (void)pc_firstTimeSetup {}
- (void)pc_didLoad {}
- (void)pc_didMoveToParent {}
- (void)pc_willMoveToParent:(SKNode *)newParent {}

- (void)pc_didEnterScene {
    for (SKNode *child in self.children) {
        [child pc_didEnterScene];
    }
}

- (void)pc_willExitScene {
    for (SKNode *child in self.children) {
        [child pc_willExitScene];
    }
}

@end
