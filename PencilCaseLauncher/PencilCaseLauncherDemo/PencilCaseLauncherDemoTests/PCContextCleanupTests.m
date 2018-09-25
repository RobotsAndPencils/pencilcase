//
//  PCContextCleanupTests.m
//  PencilCaseLauncherDemo
//
//  Created by Stephen Gazzard on 2015-06-22.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PCSlideNode.h"
#import "SKNode+LifeCycle.h"
#import "PCJSContext.h"

SPEC_BEGIN(PCContextCleanupTests)

context(@"When dismissing a card", ^{
    __block PCSlideNode *slideNode;
    beforeEach(^{
        slideNode = [[PCSlideNode alloc] init];
    });

    it(@"its context should be cleaned", ^{
        [slideNode pc_dismissTransitionWillStart];
        [[slideNode.context should] beNil];
    });
});

SPEC_END

