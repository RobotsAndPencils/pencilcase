//
//  AppDelegateTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-11-17.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>

#import "AppDelegate.h"
#import "NodeInfo.h"
#import "SKNode+NodeInfo.h"
#import "NSUUID+UUIDWithString.h"

SPEC_BEGIN(AppDelegateTests)

describe(@"AppDelegate", ^{
    context(@"When deleting nodes", ^{
        let(nodeCount, ^id{
            return @5;
        });

        __block NSArray *nodes;
        beforeEach(^{
            nodes = [NSArray array];
            for (NSUInteger nodeIndex = 0; nodeIndex < [nodeCount integerValue]; nodeIndex += 1) {
                SKNode *node = [SKNode new];
                node.userObject = [NodeInfo nodeInfoWithPlugIn:nil];
                node.uuid = [[NSUUID UUID] UUIDString];
                nodes = [nodes arrayByAddingObject:node];
            }
        });

        it(@"should fire a notification for each node", ^{
            NSUUID *nodeUUID = [NSUUID pc_UUIDWithString:[nodes.firstObject uuid]];
            [[PCNodeDeletedNotification should] bePostedWithObject:nil andUserInfo:@{ @"nodeUUID": nodeUUID }];

            AppDelegate *appDelegate = [[AppDelegate alloc] init];
            [appDelegate deleteNode:nodes.firstObject];
        });
    });
});

SPEC_END