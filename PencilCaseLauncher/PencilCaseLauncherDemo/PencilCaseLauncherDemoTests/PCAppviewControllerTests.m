//
//  PCAppviewControllerTests.m
//  PencilCaseLauncherDemo
//
//  Created by Orest Nazarewycz on 2014-11-20.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <PencilCaseLauncher/PCAppViewController.h>
#import <PencilCaseLauncher/OALSimpleAudio.h>
#import "PCJSContext.h"
#import "UIResponder+JSExport.h"
#import "NSString+KeyCodes.h"

@interface PCAppViewController (Tests)

- (void)keyHasBeenPressed:(UIKeyCommand *)keyCommand;

@end

SPEC_BEGIN(PCAppviewController)

describe(@"appview controller", ^{
    __block PCAppViewController *appViewController;
    beforeEach(^{
        appViewController = [[PCAppViewController alloc] init];
    });

    context(@"when the controller disappears", ^{
        it(@"OALSimpleAudioEngine should stop all effects", ^{
            id audioMock = [OALSimpleAudio mock];
            [OALSimpleAudio stub:@selector(sharedInstance) andReturn:audioMock];

            [[[audioMock should] receive] stopAllEffects];
            
            [appViewController viewDidDisappear:NO];
        });
    });

    context(@"keyPress events", ^{
        NSDictionary *(^createUserInfo)(UIKeyCommand *, NSNumber *) = ^(UIKeyCommand *keyCommand, NSNumber *count){
            NSString *keyCode = [NSString stringWithFormat:@"%ld", (long)[NSString pc_keyCodeForString:keyCommand.input]];
            NSString *modifierFlags = [NSString stringWithFormat:@"%ld", (long)keyCommand.modifierFlags];
            NSDictionary *userInfo = @{
                PCJSContextEventNotificationEventNameKey: @"keyPress",
                PCJSContextEventNotificationArgumentsKey: @[ keyCode, modifierFlags, count ]
            };
            return userInfo;
        };

        __block NSDictionary *userInfo;
        __block UIKeyCommand *keyCommand;
        beforeEach(^{
            [appViewController stub:@selector(isFirstResponder) andReturn:theValue(YES)];
            keyCommand = [UIKeyCommand keyCommandWithInput:@"a" modifierFlags:UIKeyModifierCommand action:nil];
        });

        it(@"should fire a global event notification", ^{
            userInfo = createUserInfo(keyCommand, @1);
            [[PCJSContextEventNotificationName should] bePostedWithObject:nil andUserInfo:userInfo];
            [appViewController keyHasBeenPressed:keyCommand];
        });

        it(@"should fire a global event notification with the correct count", ^{
            userInfo = createUserInfo(keyCommand, @2);
            [[PCJSContextEventNotificationName should] bePostedWithObject:nil andUserInfo:userInfo];
            [appViewController keyHasBeenPressed:keyCommand];
            [appViewController keyHasBeenPressed:keyCommand];
        });
    });
});

SPEC_END
