//
//  PCResourceManagerMigrationTest.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-11-20.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCResourceManager+Migration.h"
#import "PCResourceManagerDictionaryKeys.h"

SPEC_BEGIN(PCResourceManagerMigrationTests)

describe(@"When user opens a v0.1.9 file", ^{
    __block NSDictionary *rawDictionary;
    beforeEach(^{
        rawDictionary = @{ PCActiveDirectoriesKey : @[@"/PencilCase Resources"],
                           PCDirectoriesKey : @{@"/PencilCase Resources" : [[PCResourceDirectory alloc] init],
                                                @"/PencilCase Resources/resources" : [[PCResourceDirectory alloc] init] } };
    });
    context(@"And the user is running v0.1.10 or greater", ^{
        __block NSMutableDictionary *migratedDictionary;
        beforeEach(^{
            migratedDictionary = [rawDictionary mutableCopy];
            [PCResourceManager upgradeDictionaryFromV0_1_9ToV0_1_10:migratedDictionary];
        });

        it(@"Has a root resource folder that matches the first active directory", ^{
            [[migratedDictionary[PCRootDirectoryKey] should] equal:[rawDictionary[PCActiveDirectoriesKey] firstObject]];
        });

        it(@"Has a root resource folder that matches the first active directory", ^{
            [[migratedDictionary[PCRootResourceDirectoryKey] should] equal:[[rawDictionary[PCActiveDirectoriesKey] firstObject] stringByAppendingPathComponent:PCResourceFolderName]];
        });

        it(@"has a root directory that matches a real directory", ^{
            [[migratedDictionary[PCDirectoriesKey][migratedDictionary[PCRootDirectoryKey]] shouldNot] beNil];
        });

        it(@"has a root resource directory that matches a real directory", ^{
            [[migratedDictionary[PCDirectoriesKey][migratedDictionary[PCRootResourceDirectoryKey]] shouldNot] beNil];
        });
    });
});

SPEC_END
