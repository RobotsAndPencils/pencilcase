//
//  SKNode+LifeCycle.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-10.
//
//

#import "SKNode+LifeCycle.h"
#import "PCSwizzleHelper.h"
#import <objc/runtime.h>
#import "PCContextCreation.h"
#import "PCSlideNode.h"
#import "SKNode+GeneralHelpers.h"

@implementation SKNode (LifeCycle)

__attribute__((constructor)) static void pc_setupHiddenSwizzle(void) {
    @autoreleasepool {
        [SKNode pc_setupLifecycleCallbacks];
    }
}

+ (void)pc_setupLifecycleCallbacks {
    // Which methods to swizzle came from: https://github.com/KoboldKit/KoboldKit/blob/master/KoboldKit/KoboldKitFree/Framework/Nodes/Framework/KKNodeShared.h
    
    __block IMP originalAddChild = PCReplaceMethodWithBlock([SKNode class], @selector(addChild:), ^(SKNode *_self, SKNode *child) {
        [child pc_willMoveToParent:_self];
        BOOL enteringScene = _self.pc_scene || [_self isKindOfClass:[SKScene class]];
        ((void ( *)(id, SEL, SKNode *))originalAddChild)(_self, @selector(addChild:), child);
        if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {  // In iOS 9 addChild: now calls insertChildAtIndex:0
            child.addedAt = [NSDate date];
            [child pc_didMoveToParent];
            if (enteringScene) [child pc_didEnterScene];
        }
    });
    
    __block IMP originalInsertChildAtIndex = PCReplaceMethodWithBlock([SKNode class], @selector(insertChild:atIndex:), ^(SKNode *_self, SKNode *child, NSInteger index) {
        [child pc_willMoveToParent:_self];
        BOOL enteringScene = _self.pc_scene || [_self isKindOfClass:[SKScene class]];
        ((void ( *)(id, SEL, SKNode *, NSInteger))originalInsertChildAtIndex)(_self, @selector(insertChild:atIndex:), child, index);
        child.addedAt = [NSDate date];
        [child pc_didMoveToParent];
        if (enteringScene) [child pc_didEnterScene];
    });
    
    __block IMP originalRemoveFromParent = PCReplaceMethodWithBlock([SKNode class], @selector(removeFromParent), ^(SKNode *_self) {
        if (_self.pc_scene) [_self pc_willExitScene];
        [_self pc_willMoveToParent:nil];
        ((void ( *)(id, SEL))originalRemoveFromParent)(_self, @selector(removeFromParent));
        _self.addedAt = nil;
        [_self pc_didMoveToParent];
    });
    
    __block IMP originalRemoveAllChildren = PCReplaceMethodWithBlock([SKNode class], @selector(removeAllChildren), ^(SKNode *_self) {
        for (SKNode *child in _self.children) {
            if (child.pc_scene) [child pc_willExitScene];
            [child pc_willMoveToParent:nil];
        }
        NSArray *originalChildren = _self.children;
        ((void ( *)(id, SEL))originalRemoveAllChildren)(_self, @selector(removeAllChildren));
        for (SKNode *child in originalChildren) {
            child.addedAt = nil;
            [child pc_didMoveToParent];
        }
    });
    
    __block IMP originalRemoveChildrenInArray = PCReplaceMethodWithBlock([SKNode class], @selector(removeChildrenInArray:), ^(SKNode *_self, NSArray *children) {
        for (SKNode *child in children) {
            if (child.pc_scene) [child pc_willExitScene];
            [child pc_willMoveToParent:nil];
        }
        ((void ( *)(id, SEL, NSArray *))originalRemoveChildrenInArray)(_self, @selector(removeChildrenInArray:), children);
        for (SKNode *child in children) {
            child.addedAt = nil;
            [child pc_didMoveToParent];
        }
    });
}

#pragma mark - New Life Cycle Calls

- (void)pc_didMoveToParent {}
- (void)pc_willMoveToParent:(SKNode *)newParent {}

- (void)pc_didEnterScene {
    [self set_pc_scene:self.scene];
    [[self slideNode] addNodeAndNodesChildrenToContext:self];

    for (SKNode *child in self.children) {
        [child pc_didEnterScene];
    }
}

- (void)pc_willExitScene {
    [[self slideNode] removeNodeAndNodesChildrenFromContext:self];

    for (SKNode *child in self.children) {
        [child pc_willExitScene];
    }
    [self set_pc_scene:nil];
}

- (void)pc_presentationDidStart {
    for (SKNode *child in self.children) {
        [child pc_presentationDidStart];
    }
}

- (void)pc_presentationCompleted {
    for (SKNode *child in self.children) {
        [child pc_presentationCompleted];
    }
}

- (void)pc_dismissTransitionWillStart {
    for (SKNode *child in self.children) {
        [child pc_dismissTransitionWillStart];
    }
}

#pragma mark pc_scene

- (SKScene *)pc_scene {
    return objc_getAssociatedObject(self, @selector(pc_scene));
}

- (void)set_pc_scene:(SKScene *)scene {
    objc_setAssociatedObject(self, @selector(pc_scene), scene, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark pc_addedAt

- (NSDate *)addedAt {
    return objc_getAssociatedObject(self, @selector(addedAt));
}

- (void)setAddedAt:(NSDate *)addedAt {
    objc_setAssociatedObject(self, @selector(addedAt), addedAt, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation SKScene (LifeCycle)

- (SKScene *)pc_scene {
    return self;
}

@end
