//
//  PCProjectSettingsTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-08-05.
//
//

#import <XCTest/XCTest.h>

#import "PCProjectSettings.h"
#import "NSError+PencilCaseErrors.h"
#import "Constants.h"
#import <Kiwi/Kiwi.h>

@interface PCProjectSettings (Tests)

- (void)loadFileVersionsFromFile:(NSDictionary *)fileContents currentFileVersion:(NSInteger)pencilCaseVersion;
- (BOOL)validateSerialization:(NSDictionary *)serialization error:(NSError **)error;

@end

@interface PCProjectSettingsTests : XCTestCase

@end

@implementation PCProjectSettingsTests

- (void)testProjectValidation {
    // Contains key with supported version
    NSDictionary *validProjectVersionDictionary = @{ @"fileType": PCProjectFileType, @"makerFileFormatVersion": @(PCMakerFileFormatVersion) };
    // Contains key with unsupported version
    NSDictionary *invalidProjectVersionDictionary = @{ @"fileType": PCProjectFileType, @"makerFileFormatVersion": @(PCMakerFileFormatVersion + 1) };
    // Doesn't contain key
    NSDictionary *invalidProjectDictionary = @{ @"fileType": @"PagesOrSomething" };
    
    NSError *loadGraphError;
    [PCProjectSettings validateSerialization:validProjectVersionDictionary error:&loadGraphError];

    XCTAssert(loadGraphError == nil, @"Error from loading valid graph wasn't nil");
    
    loadGraphError = nil;
    [PCProjectSettings validateSerialization:invalidProjectVersionDictionary error:&loadGraphError];
    
    XCTAssert(loadGraphError != nil, @"Error from loading invalid graph is not initialized properly");
    XCTAssert(loadGraphError.code == PCErrorCodeUnsupportedProjectVersion, @"Error from loading invalid graph returns an incorrect error code");
    
    loadGraphError = nil;
    [PCProjectSettings validateSerialization:invalidProjectDictionary error:&loadGraphError];
    
    XCTAssert(loadGraphError != nil, @"Error from loading invalid graph is not initialized properly");
    XCTAssert(loadGraphError.code == PCErrorCodeUnsupportedProjectType, @"Error from loading invalid graph returns an incorrect error code");
}

@end


SPEC_BEGIN(ProjectSettingsTests)

describe(@"PCProjectSettings", ^{
    __block NSDictionary *projectSettingsDictionary;
    __block PCProjectSettings *projectSettings;
    __block PCSerializationStatus status;
    __block NSError *error;
    
    context(@"When I update the app version number by 1", ^{
        beforeAll(^{
            NSInteger pencilCaseVersion = [[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue];
            projectSettingsDictionary = @{ @"fileType": PCProjectFileType, @"authorVersion": @(pencilCaseVersion), @"previousAuthorVersion": @(pencilCaseVersion - 1), @"createdAuthorVersion": @(pencilCaseVersion -1)};
            projectSettings = [[PCProjectSettings alloc] initWithValidSerialization:projectSettingsDictionary fromPackageURL:nil];

            [projectSettings loadFileVersionsFromFile:projectSettingsDictionary currentFileVersion:pencilCaseVersion + 1];
        });
        
        it(@"the authorVersion should update", ^{
            [[theValue(projectSettings.authorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue] + 1)];
        });
        it(@"the previousAuthorVersion should update", ^{
            [[theValue(projectSettings.previousAuthorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue])];
        });
        it(@"the createdAuthorVersion should be the same", ^{
            [[theValue(projectSettings.createdAuthorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue] - 1)];
        });
        
    });
    
    context(@"When I update the author version number by more than 1", ^{
        beforeAll(^{
            NSInteger pencilCaseVersion = [[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue];
            projectSettingsDictionary = @{ @"fileType": PCProjectFileType, @"authorVersion": @(pencilCaseVersion), @"previousAuthorVersion": @(pencilCaseVersion - 1), @"createdAuthorVersion": @(pencilCaseVersion -1)};
            projectSettings = [[PCProjectSettings alloc] initWithValidSerialization:projectSettingsDictionary fromPackageURL:nil];
            
            [projectSettings loadFileVersionsFromFile:projectSettingsDictionary currentFileVersion:pencilCaseVersion + 2];
        });
        
        it(@"the authorVersion should update", ^{
            [[theValue(projectSettings.authorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue] + 2)];
        });
        it(@"the previousAuthorVersion should update", ^{
            [[theValue(projectSettings.previousAuthorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue])];
        });
        it(@"the createdAuthorVersion should be the same", ^{
            [[theValue(projectSettings.createdAuthorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue] - 1)];
        });
        
    });
    
    context(@"When I update the author version number by 1 with missing project setting keys", ^{
        beforeEach(^{
            projectSettingsDictionary = @{ @"fileType": PCProjectFileType, @"authorVersion": @10 };
            projectSettings = [[PCProjectSettings alloc] initWithValidSerialization:projectSettingsDictionary fromPackageURL:nil];
            [projectSettings loadFileVersionsFromFile:projectSettingsDictionary currentFileVersion:[[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue] + 1];
        });
        
        it(@"the authorVersion should update", ^{
            [[theValue(projectSettings.authorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue] + 1)];
        });
        it(@"the previousAuthorVersion should update", ^{
            [[theValue(projectSettings.previousAuthorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue])];
        });
        it(@"the createdAuthorVersion should be the same", ^{
            [[theValue(projectSettings.createdAuthorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue])];
        });
        
    });
    
    context(@"When I update the author version number by more than 1 with missing project setting keys", ^{
        beforeEach(^{
            projectSettingsDictionary = @{ @"fileType": PCProjectFileType, @"fileVersion": @10 };
            projectSettings = [[PCProjectSettings alloc] initWithValidSerialization:projectSettingsDictionary fromPackageURL:nil];
            [projectSettings loadFileVersionsFromFile:projectSettingsDictionary currentFileVersion:[[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue] + 2];
        });
        
        it(@"the authorVersion should update", ^{
            [[theValue(projectSettings.authorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue] + 2)];
        });
        it(@"the previousAuthorVersion should update", ^{
            [[theValue(projectSettings.previousAuthorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue])];
        });
        it(@"the createdAuthorVersion should be the same", ^{
            [[theValue(projectSettings.createdAuthorVersion) should] equal:theValue([[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue])];
        });
    });
    
    context(@"When I try to load an un supported file", ^{
        beforeEach(^{
            projectSettingsDictionary = @{ @"fileType": @"notCocosbuilderProject", @"makerFileFormatVersion": @(PCMakerFileFormatVersion) };
            status = [PCProjectSettings validateSerialization:projectSettingsDictionary error:&error];
        });
        
        it(@"should give me an unsupported project version error", ^{
            [[theValue(status) should] equal:theValue(PCSerializationStatusUnsupportedFileType)];
        });
        
    });
    
    
    context(@"When I try to load an newer fileFormatVersion", ^{
        beforeEach(^{
            projectSettingsDictionary = @{ @"fileType": PCProjectFileType, @"makerFileFormatVersion": @(PCMakerFileFormatVersion + 1) };
            status = [PCProjectSettings validateSerialization:projectSettingsDictionary error:&error];
        });
        
        it(@"should give me an unsupported project version error", ^{
            [[theValue(status) should] equal:theValue(PCSerializationStatusUnsupportedVersion)];
        });
        
    });
    
    context(@"When I try to load an old fileFormatVersion", ^{
        beforeEach(^{
            projectSettingsDictionary = @{ @"fileType": PCProjectFileType, @"makerFileFormatVersion": @(PCMakerFileFormatVersion - 1) };
            status = [PCProjectSettings validateSerialization:projectSettingsDictionary error:&error];
        });
        
        it(@"should inform me to update", ^{
            [[theValue(status) should] equal:theValue(PCSerializationStatusNeedsUpdate)];
        });
        
    });
    
    context(@"When I try to load a valid serialization", ^{
        beforeEach(^{
            projectSettingsDictionary = @{ @"fileType": PCProjectFileType, @"makerFileFormatVersion": @(PCMakerFileFormatVersion) };
            status = [PCProjectSettings validateSerialization:projectSettingsDictionary error:&error];
        });
        
        it(@"should give a valid return", ^{
            [[theValue(status) should] equal:theValue(PCSerializationStatusValid)];
        });
        
    });
    
});

SPEC_END
