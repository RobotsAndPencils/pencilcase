//
//  PCSlideNodeContactDelegateTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 2014-12-17.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

@import SpriteKit;
#import <Kiwi/Kiwi.h>

#import "PCSlideNode.h"
#import "PCJSContext.h"
#import "SKNode+JavaScript.h"
#import "PCContextCreation.h"

@interface PCSlideNode (Tests) <SKPhysicsContactDelegate>

@end

SPEC_BEGIN(PCSlideNodeContactDelegateTests)

describe(@"didBeginContact:", ^{
    __block PCSlideNode *slideNode;
    __block PCJSContext *context;
    __block SKPhysicsContact *contact;
    beforeEach(^{
        slideNode = [PCSlideNode new];
        context = [PCJSContext new];
        slideNode.context = context;

        SKNode *nodeA = [SKNode new];
        nodeA.name = @"nodeA";
        nodeA.uuid = [[NSUUID UUID] UUIDString];
        [slideNode addChild:nodeA];
        context[@"nodeA"] = nodeA;
        [context evaluateScript:@"var sentinelA; nodeA.on('collision', function(nodeA, nodeB) { sentinelA = arguments; });"];

        SKNode *nodeB = [SKNode new];
        nodeB.name = @"nodeB";
        nodeB.uuid = [[NSUUID UUID] UUIDString];
        [slideNode addChild:nodeB];
        context[@"nodeB"] = nodeB;
        [context evaluateScript:@"var sentinelB; nodeB.on('collision', function(nodeB, nodeA) { sentinelB = arguments; });"];

        // The regular implementation depends on a view controller
        [PCContextCreation stubMessagePattern:[[KWMessagePattern alloc] initWithSelector:@selector(nodeWithUUID:)] withBlock:^id(NSArray *params) {
            if ([params.firstObject isEqual:nodeA.uuid]) return nodeA;
            if ([params.firstObject isEqual:nodeB.uuid]) return nodeB;
            return nil;
        }];

        contact = [SKPhysicsContact new];
        SKPhysicsBody *bodyA = [SKPhysicsBody new];
        [bodyA stub:@selector(node) andReturn:nodeA];
        [contact stub:@selector(bodyA) andReturn:bodyA];
        SKPhysicsBody *bodyB = [SKPhysicsBody new];
        [bodyB stub:@selector(node) andReturn:nodeB];
        [contact stub:@selector(bodyB) andReturn:bodyB];
    });

    it(@"should trigger nodeA's listener callback", ^{
        [[[context[@"sentinelA"] toArray] shouldEventually] haveCountOf:2];
        [slideNode didBeginContact:contact];
    });

    it(@"should contain the colliding nodes in nodeA's callback arguments", ^{
        [[[context[@"sentinelA"] toArray] shouldEventually] containObjectsInArray:slideNode.children];
        [slideNode didBeginContact:contact];
    });

    it(@"should trigger nodeB's listener callback", ^{
        [[[context[@"sentinelB"] toArray] shouldEventually] haveCountOf:2];
        [slideNode didBeginContact:contact];
    });

    it(@"should contain the colliding nodes in nodeB's callback arguments", ^{
        [[[context[@"sentinelB"] toArray] shouldEventually] containObjectsInArray:slideNode.children];
        [slideNode didBeginContact:contact];
    });
});

SPEC_END