//
//  PCSlideNodeTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-07.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCSlideNode.h"
#import "PCJSContext.h"
#import "SKNode+LifeCycle.h"

SPEC_BEGIN(PCSlideNodeTests)

__block PCSlideNode *slideNode;
beforeEach(^{
    slideNode = [PCSlideNode new];
});

describe(@"pc_presentationTransitionCompleted", ^{
    it(@"should fire a cardLoad JS event", ^{
        [[PCJSContextEventNotificationName should] bePostedWithObject:nil andUserInfo:@{ PCJSContextEventNotificationEventNameKey: @"cardLoad" }];
        [slideNode pc_presentationDidStart];
    });
});

SPEC_END

