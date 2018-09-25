//
//  PCButtonTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-08.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PCButton.h"
#import "PCJSContext.h"

SPEC_BEGIN(PCButtonTests)

__block PCButton *button;
beforeEach(^{
    button = [PCButton new];
    button.enabled = YES;
    button.togglesSelectedState = YES;
});

context(@"when the button is toggled", ^{
    context(@"and it's not selected", ^{
        it(@"should trigger a JS event that it's toggled on", ^{
            [[PCJSContextEventNotificationName should] bePostedWithObject:button andUserInfo:@{
                PCJSContextEventNotificationEventNameKey: @"toggled",
                PCJSContextEventNotificationArgumentsKey: @[ button, @"on" ]
            }];

            [button touchUpInside:nil withEvent:nil];
        });
    });

    context(@"and it's selected", ^{
        beforeEach(^{
            button.selected = YES;
        });

        it(@"should trigger a JS event that it's toggled off", ^{
            [[PCJSContextEventNotificationName should] bePostedWithObject:button andUserInfo:@{
                PCJSContextEventNotificationEventNameKey: @"toggled",
                PCJSContextEventNotificationArgumentsKey: @[ button, @"off" ]
            }];

            [button touchUpInside:nil withEvent:nil];
        });
    });
});

SPEC_END
