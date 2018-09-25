//
//  PCLRetainCycleIntegrationTests.m
//  PencilCaseLauncherDemo
//
//  Created by Cody Rayment on 2015-05-19.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import <PencilcaseLauncher/PencilCaseLauncher.h>
#import <PencilcaseLauncher/PCCard.h>
#import <PencilcaseLauncher/PCJSContext.h>
#import <PencilCaseLauncher/OALSimpleAudio.h>

@interface PCLRetainCycleIntegrationTests : XCTestCase

@end

@implementation PCLRetainCycleIntegrationTests

- (void)setUp {
    id audioMock = [OALSimpleAudio nullMock];
    [OALSimpleAudio stub:@selector(sharedInstance) andReturn:audioMock];
}

- (void)testJSContextRetainCycle {
    __weak PCAppViewController *weakViewController;
    __weak PCCard *weakCard;
    __weak PCJSContext *weakContext;

    XCTestExpectation *viewControllerDismissedExpectation = [self expectationWithDescription:@"view controller dismissed"];

    @autoreleasepool {
        PCApp *app = [PCApp createWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test_creation" withExtension:@"creation"]];
        PCAppViewController *viewController = [[PCAppViewController alloc] initWithApp:app startSlideIndex:0];

        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootViewController presentViewController:viewController animated:NO completion:^{}];

        weakViewController = viewController;
        weakCard = weakViewController.cardAtCurrentIndex;
        weakContext = weakCard.context;

        XCTAssertNotNil(weakViewController);
        XCTAssertNotNil(weakCard);
        XCTAssertNotNil(weakContext);
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssertNil(weakViewController);
                XCTAssertNil(weakCard);
                XCTAssertNil(weakContext);
                [viewControllerDismissedExpectation fulfill];
            });
        }];
    });

    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {}];
}

- (void)tearDown {
    [OALSimpleAudio clearStubs];
}

@end
