//
//  PCTableNodeEventTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 14-12-18.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

@import SpriteKit;
#import <Kiwi/Kiwi.h>
#import "PCTableNode.h"
#import "PCJSContext.h"
#import "PCTableCellInfo.h"

SPEC_BEGIN(PCTableNodeEventTests)

describe(@"cellSelected", ^{
    __block PCTableNode *tableNode;
    __block NSString *cellUUIDString;
    __block NSDictionary *userInfo;
    beforeEach(^{
        tableNode = [PCTableNode new];
        cellUUIDString = [[NSUUID UUID] UUIDString];
        PCTableCellInfo *cellInfo = [PCTableCellInfo new];
        [cellInfo setValue:cellUUIDString forKey:@"uuid"];
        [tableNode setValue:@[ cellInfo ] forKey:@"cells"];

        userInfo = @{
            PCJSContextEventNotificationEventNameKey : @"cellSelected",
            PCJSContextEventNotificationArgumentsKey : @[ cellUUIDString, @0 ]
        };
    });

    it(@"should post JS Context event notification", ^{
        [[PCJSContextEventNotificationName should] bePostedWithObject:tableNode andUserInfo:userInfo];
        [tableNode tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    });
});

describe(@"cellInfoButtonPressed", ^{
    __block PCTableNode *tableNode;
    __block NSString *cellUUIDString;
    __block NSDictionary *userInfo;
    beforeEach(^{
        tableNode = [PCTableNode new];
        cellUUIDString = [[NSUUID UUID] UUIDString];
        PCTableCellInfo *cellInfo = [PCTableCellInfo new];
        [cellInfo setValue:cellUUIDString forKey:@"uuid"];
        [tableNode setValue:@[ cellInfo ] forKey:@"cells"];

        userInfo = @{
                PCJSContextEventNotificationEventNameKey : @"cellInfoButtonPressed",
                PCJSContextEventNotificationArgumentsKey : @[ cellUUIDString, @0 ]
        };
    });

    it(@"should post JS Context event notification", ^{
        [[PCJSContextEventNotificationName should] bePostedWithObject:tableNode andUserInfo:userInfo];
        [tableNode tableView:nil accessoryButtonTappedForRowWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    });
});

SPEC_END
