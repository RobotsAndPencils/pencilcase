//
//  CCBAnimationManagerTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-07.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "CCBAnimationManager.h"
#import "PCJSContext.h"
#import "CCBSequence.h"

@interface CCBAnimationManager (Tests)
- (void)sequenceCompleted:(NSInteger)seqId;
@end

SPEC_BEGIN(CCBAnimationManagerTests)

describe(@"JavaScriptEvents", ^{
    __block CCBAnimationManager *animationManager;
    __block NSDictionary *userInfo;
    beforeEach(^{
        animationManager = [CCBAnimationManager new];

        CCBSequence *defaultSequence = [CCBSequence new];
        defaultSequence.name = @"Default Timeline";
        defaultSequence.sequenceId = 0;

        [animationManager.sequences addObject:defaultSequence];

        userInfo = @{
            PCJSContextEventNotificationEventNameKey : @"timelineFinished",
            PCJSContextEventNotificationArgumentsKey : @[ defaultSequence.name ]
        };
    });

    it(@"should post a JS event notification when a timeline completes", ^{
        [[PCJSContextEventNotificationName should] bePostedWithObject:nil andUserInfo:userInfo];
        [animationManager sequenceCompleted:0];
    });
});

SPEC_END


