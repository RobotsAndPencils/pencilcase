//
//  PCPublisherTests.m
//  SpriteBuilder
//
//  Created by Michael Beauregard on 14-12-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Constants.h"
#import "PCPublisher.h"
#import "PCProjectSettings.h"
#import "PCWarningGroup.h"

@interface PCPublisher ()
- (void)exportProjectToPath:(NSString *)selectedPath projectName:(NSString *)destinationProjectName bundleID:(NSString *)destinationBundleID deviceTarget:(PCDeviceTargetType)deviceTarget deviceOrientation:(PCDeviceTargetOrientation)deviceOrientation;
@end

SPEC_BEGIN(PublisherTests)
    __block PCPublisher *publisher;
    __block PCWarningGroup *warnings;

    __block NSString *appName;
    __block NSString *exportPath;
    __block NSString *destinationPath;
    __block NSString *destinationProjectPath;
    __block NSString *bundleID;

    beforeEach(^{
        appName = @"TestProject";
        exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"PCPublisherTests"];
        destinationPath = [exportPath stringByAppendingPathComponent:appName];
        destinationProjectPath = [[destinationPath stringByAppendingPathComponent:appName] stringByAppendingPathExtension:@"xcodeproj"];
        bundleID = @"foo.bar";
        warnings = [[PCWarningGroup alloc] init];

        // remove any old test output first
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];

        // rebuild the output structure
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:exportPath withIntermediateDirectories:YES attributes:nil error:nil];
        [[theValue(result) should] beTrue];

        // export it
        publisher = [[PCPublisher alloc] initWithProjectSettings:nil warnings:warnings];
    });

    describe(@"When iPhone project is exported", ^{

        beforeEach(^{
            [publisher exportProjectToPath:exportPath projectName:appName bundleID:bundleID deviceTarget:PCDeviceTargetTypePhone deviceOrientation:PCDeviceTargetOrientationLandscape];
        });

        it(@"should not have any warnings", ^{
            [[warnings.warnings should] haveCountOf:0];
        });

        it(@"should create a subdirectory named after the app name", ^{
            BOOL isDirectory = NO;
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath isDirectory:&isDirectory];
            [[theValue(isDirectory) should] beTrue];
            [[theValue(exists) should] beTrue];
        });

        it(@"should rename project file", ^{
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:destinationProjectPath];
            [[theValue(exists) should] beTrue];
        });

        it(@"project should be set to iPhone", ^{
            NSString *pbxProj = [destinationProjectPath stringByAppendingPathComponent:@"project.pbxproj"];
            NSString *contents = [NSString stringWithContentsOfFile:pbxProj encoding:NSUTF8StringEncoding error:nil];
            [[contents should] containString:@"TARGETED_DEVICE_FAMILY = 1"];
        });

        it(@"supported orientations should be set to landscape + portrait", ^{
            NSString *plistPath = [destinationPath stringByAppendingPathComponent:@"Info.plist"];
            NSString *contents = [NSString stringWithContentsOfFile:plistPath encoding:NSUTF8StringEncoding error:nil];
            [[contents should] containString:@"UIInterfaceOrientationLandscapeLeft"];
            [[contents should] containString:@"UIInterfaceOrientationLandscapeRight"];
            [[contents should] containString:@"UIInterfaceOrientationPortrait"];
        });
    });

    describe(@"When iPad project is exported", ^{

        beforeEach(^{
            [publisher exportProjectToPath:exportPath projectName:appName bundleID:bundleID deviceTarget:PCDeviceTargetTypeTablet deviceOrientation:PCDeviceTargetOrientationLandscape];
        });

        it(@"project should be set to iPad", ^{
            NSString *pbxProj = [destinationProjectPath stringByAppendingPathComponent:@"project.pbxproj"];
            NSString *contents = [NSString stringWithContentsOfFile:pbxProj encoding:NSUTF8StringEncoding error:nil];
            [[contents should] containString:@"TARGETED_DEVICE_FAMILY = 2"];
        });

        it(@"supported orientations should be set to landscape", ^{
            NSString *plistPath = [destinationPath stringByAppendingPathComponent:@"Info.plist"];
            NSString *contents = [NSString stringWithContentsOfFile:plistPath encoding:NSUTF8StringEncoding error:nil];
            [[contents should] containString:@"UIInterfaceOrientationLandscapeLeft"];
            [[contents should] containString:@"UIInterfaceOrientationLandscapeRight"];
            [[contents shouldNot] containString:@"UIInterfaceOrientationPortrait"];
        });
    });

    describe(@"Makes valid bundle id for Xcode project", ^{
        it(@"Trims leading/trailing whitespace", ^{
            NSString *name = [publisher validBundleIDPartForForPencilCaseProjectName:@"  My Project   "];
            [[name should] equal:@"My-Project"];
        });

        it(@"Removes non alphanumeric characters", ^{
            NSString *name = [publisher validBundleIDPartForForPencilCaseProjectName:@"ABC 123 -+* •ª¡ ABC"];
            [[name should] equal:@"ABC-123---------ABC"];
        });

        it(@"Removes invalid leading characters", ^{
            NSString *name = [publisher validBundleIDPartForForPencilCaseProjectName:@"123 My Project 123"];
            [[name should] equal:@"-23-My-Project-123"];
        });

        it(@"Handles emoji", ^{
            NSString *name = [publisher validBundleIDPartForForPencilCaseProjectName:@"My 🎉 Project"];
            [[name should] equal:@"My---Project"];
        });

        it(@"Handles this crazy string", ^{
            NSString *name = [publisher validBundleIDPartForForPencilCaseProjectName:@"  😡123 ASdf §¶•  '`\"  🎉😜  "];
            [[name should] equal:@"-123-ASdf-------------"];
        });

        it(@"Handles nil and empty string", ^{
            NSString *name = [publisher validBundleIDPartForForPencilCaseProjectName:nil];
            [[name should] equal:@"my-project"];
            name = [publisher validBundleIDPartForForPencilCaseProjectName:@""];
            [[name should] equal:@"my-project"];
        });
    });

SPEC_END