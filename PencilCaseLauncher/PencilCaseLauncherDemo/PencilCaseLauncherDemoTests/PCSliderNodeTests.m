//
//  PCSliderNodeTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-08.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SKSpriteNode+JSExport.h"
#import "PCSliderNode.h"
#import "PCJSContext.h"

@interface PCSliderNode (Tests)
@property (strong, nonatomic) UISlider *overlaySlider;
@end

SPEC_BEGIN(PCSliderNodeTests)

__block PCSliderNode *sliderNode;
beforeEach(^{
    sliderNode = [PCSliderNode new];
});

context(@"When the slider value changes", ^{
    it(@"should trigger a JS event with the slider node as an argument", ^{
        [[PCJSContextEventNotificationName should] bePostedWithObject:sliderNode andUserInfo:@{
            PCJSContextEventNotificationEventNameKey: @"valueChanged",
            PCJSContextEventNotificationArgumentsKey: @[ sliderNode ]
        }];

        [sliderNode.overlaySlider sendActionsForControlEvents:UIControlEventValueChanged];
    });
});

SPEC_END
