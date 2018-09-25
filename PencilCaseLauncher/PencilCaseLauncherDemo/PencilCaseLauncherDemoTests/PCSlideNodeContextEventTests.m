//
//  PCSlideNodeContextEventTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 14-12-18.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <YapDatabase/YapDatabase.h>
#import "PCSlideNode.h"
#import "PCJSContext.h"
#import "PCTableNode.h"
#import "SKNode+LifeCycle.h"

SPEC_BEGIN(PCSlideNodeContextEventTests)

__block PCSlideNode *slideNode;
__block PCJSContext *jsContext;
beforeEach(^{
    slideNode = [PCSlideNode new];
    [slideNode pc_presentationDidStart];
    jsContext = [PCJSContext new];
    slideNode.context = jsContext;
});

describe(@"PCJSContextEventNotifications", ^{
    __block PCTableNode *tableNode;
    beforeEach(^{
        tableNode = [PCTableNode new];
    });

    context(@"When a non-nil object is passed", ^{
        it(@"should trigger a context event on an instance", ^{
            [[slideNode.context should] receive:@selector(triggerEventOnJavaScriptRepresentation:eventName:arguments:)];
            [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:tableNode userInfo:@{
                    PCJSContextEventNotificationEventNameKey: @"cellSelected",
                    PCJSContextEventNotificationArgumentsKey: @[ [[NSUUID UUID] UUIDString] ]
            }];
        });
    });

    context(@"When a nil object is passed", ^{
        it(@"should trigger a global context event", ^{
            [[slideNode.context should] receive:@selector(triggerEventWithName:arguments:)];
            [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:@{
                    PCJSContextEventNotificationEventNameKey: @"cellSelected",
                    PCJSContextEventNotificationArgumentsKey: @[ [[NSUUID UUID] UUIDString] ]
            }];
        });
    });
});

SPEC_END
