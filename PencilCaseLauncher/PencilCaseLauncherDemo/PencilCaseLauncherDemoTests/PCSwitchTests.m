//
//  PCSwitchTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-08.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SKNode+JSExport.h"
#import "PCSwitchNode.h"
#import "PCJSContext.h"
#import "SKNode+JavaScript.h"

@interface PCSwitchNode (Tests)
@property (strong, nonatomic) UISwitch *overlaySwitch;
@end

SPEC_BEGIN(PCSwitchTests)

__block PCSwitchNode *switchNode;
beforeEach(^{
    switchNode = [PCSwitchNode new];
    switchNode.uuid = [[NSUUID UUID] UUIDString];
});

context(@"When a switch is off", ^{
    beforeEach(^{
        switchNode.isOn = NO;
    });
    context(@"and it's toggled on", ^{
        beforeEach(^{
            [switchNode.overlaySwitch stub:@selector(isOn) andReturn:theValue(YES)];
        });

        it(@"should trigger a JS event for toggling on", ^{
            [[PCJSContextEventNotificationName should] bePostedWithObject:switchNode andUserInfo:
                @{
                    PCJSContextEventNotificationEventNameKey : @"toggled",
                    PCJSContextEventNotificationArgumentsKey : @[ switchNode, @"on" ]
                }];

            [switchNode.overlaySwitch sendActionsForControlEvents:UIControlEventValueChanged];
        });
    });
});

context(@"When a switch is on", ^{
    beforeEach(^{
        switchNode.isOn = YES;
    });

    context(@"and it's toggled off", ^{
        beforeEach(^{
            [switchNode.overlaySwitch stub:@selector(isOn) andReturn:theValue(NO)];
        });

        it(@"should trigger a JS event for toggling off", ^{
            [[PCJSContextEventNotificationName should] bePostedWithObject:switchNode andUserInfo:
                @{
                    PCJSContextEventNotificationEventNameKey : @"toggled",
                    PCJSContextEventNotificationArgumentsKey : @[ switchNode, @"off" ]
            }];

            [switchNode.overlaySwitch sendActionsForControlEvents:UIControlEventValueChanged];
        });
    });
});

SPEC_END
