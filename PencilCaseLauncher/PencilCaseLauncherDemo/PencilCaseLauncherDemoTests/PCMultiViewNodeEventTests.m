//
//  PCMultiViewNodeEventTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 14-12-18.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

@import SpriteKit;
#import <Kiwi/Kiwi.h>
#import "PCMultiViewNode.h"
#import "PCJSContext.h"
#import "SKNode+JavaScript.h"

SPEC_BEGIN(PCMultiViewNodeEventTests)

__block PCMultiViewNode *multiViewNode;
beforeEach(^{
    multiViewNode = [PCMultiViewNode new];
    multiViewNode.uuid = [[NSUUID UUID] UUIDString];
});

describe(@"focusedCellChanged", ^{
    __block NSDictionary *userInfo;
    beforeEach(^{
        userInfo = @{
            PCJSContextEventNotificationEventNameKey: @"focusedViewChanged",
            PCJSContextEventNotificationArgumentsKey: @[ @1 ]
        };
    });

    context(@"when setting the focused cell index", ^{
        it(@"should fire a context event notification", ^{
            [[PCJSContextEventNotificationName should] bePostedWithObject:multiViewNode andUserInfo:userInfo];
            multiViewNode.focusedCellIndex = 1;
        });
    });
});

SPEC_END
