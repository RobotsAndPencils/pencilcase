//
//  PCOpenSaveFilterTests.m
//  SpriteBuilder
//
//  Created by Michael Beauregard on 15-01-07.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "Kiwi.h"
#import "PCOpenSaveFilter.h"

SPEC_BEGIN(OpenSaveFilterTests)

    __block PCOpenSaveFilter *filter;

    beforeEach(^{
        filter = [[PCOpenSaveFilter alloc] init];
    });

    describe(@"when allowing only directory selection", ^{
        beforeEach(^{
            filter.allowDirectorySelection = YES;
            filter.allowFileSelection = NO;
            filter.allowFilePackageSelection = NO;
        });

        it(@"should allow a directory selection", ^{
            [[theValue([filter panelShouldEnableURL:[NSURL fileURLWithPath:@"/var/log"]]) should] beTrue];
        });
        it(@"should not allow a file selection", ^{
            [[theValue([filter panelShouldEnableURL:[NSURL fileURLWithPath:@"/var/log/system.log"]]) should] beFalse];
        });
        it(@"should not allow a file package selection", ^{
            [[theValue([filter panelShouldEnableURL:[NSURL fileURLWithPath:@"/Applications/Preview.app"]]) should] beFalse];
        });
    });

SPEC_END