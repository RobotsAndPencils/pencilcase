//
//  SKNode+LifeCycleTests.m
//  PencilCaseLauncherDemo
//
//  Created by Cody Rayment on 2014-11-04.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import <PencilCaseLauncher/SKNode+LifeCycle.h>

@interface SKNodeLifeCycleTests : XCTestCase

@end

@implementation SKNodeLifeCycleTests

// We can revisit needing pc_scene if Apple makes this test pass.
- (void)testDemonstrateAppleBug {
    // Create a scene and add a node to it and let the scene be released
    __weak SKScene *weakScene;
    SKNode *node;
    @autoreleasepool {
        SKScene *scene = [SKScene sceneWithSize:CGSizeMake(100, 100)];
        node = [SKNode node];
        [scene addChild:node];
        weakScene = scene;
        scene = nil;
    }
    XCTAssertNil(weakScene);
    // Line below will crash - can't test because it's not an exception - EXC_BAD_ACCESS
//    XCTAssertNil(node.scene);
}

@end

SPEC_BEGIN(SKNodeLifeCycle)

describe(@"pc_scene", ^{
    __block SKScene *scene;
    __block SKView *view;

    beforeEach(^{
        scene = [SKScene sceneWithSize:CGSizeMake(100, 100)];
        view = [[SKView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    });

    context(@"when the scene is presented in a view", ^{
        beforeEach(^{
            [view presentScene:scene];
        });

        context(@"when adding a node to the scene", ^{
            __block SKNode *node;
            beforeEach(^{
                node = [SKNode node];
                [scene addChild:node];
            });

            it(@"should set the pc_scene", ^{
                [[node.pc_scene shouldNot] beNil];
                [[node.pc_scene should] equal:scene];
            });
        });
    });

    context(@"when the scene is not presented", ^{
        context(@"when adding a node to the scene", ^{
            __block SKNode *node;
            beforeEach(^{
                node = [SKNode node];
                [scene addChild:node];
            });

            it(@"should set the pc_scene", ^{
                [[node.pc_scene should] equal:scene];
            });
        });
    });

});

describe(@"SKNode", ^{

    __block SKNode *child;
    __block SKNode *parent;
    beforeEach(^{
        child = [SKNode node];
        parent = [SKNode node];
    });

    specify(^{
        [[child.addedAt should] beNil];
    });

    context(@"When child added to parent", ^{

        beforeEach(^{
            [parent addChild:child];
        });

        specify(^{
            [[child.addedAt shouldNot] beNil];
        });

        context(@"When child removed from parent", ^{
            
            beforeEach(^{
                [child removeFromParent];
            });

            specify(^{
                [[child.addedAt should] beNil];
            });
        });
    });
});

SPEC_END
