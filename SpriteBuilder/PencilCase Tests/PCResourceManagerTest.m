//
//  PCResourceManagerTest.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-23.
//
//


#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCResourceManager.h"
#import "AppDelegate.h"
#import "NSString+FileNameFormatting.h"

SPEC_BEGIN(PCResourceManagerTests)

__block PCResourceManager *resourceManager;
__block PCResourceDirectory *activeDirectory;

beforeEach(^{
    // Wouldn't you know it, PCResourceManager has dependencies in AppDelegate so we have to set them up
    PCProjectSettings *currentProjectSettings = [[PCProjectSettings alloc] init];
    [currentProjectSettings stub:@selector(projectFilePath) andReturn:@"/file.ccbproj"];
    [AppDelegate appDelegate].currentProjectSettings = currentProjectSettings;

    // Because PCResourceManager uses file reference NSURLs, we need real files in the filesystem in order for some of the functionality to work
    NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *activeDirectoryURL = [temporaryDirectoryURL URLByAppendingPathComponent:@"filePath"];
    [[NSFileManager defaultManager] createDirectoryAtURL:activeDirectoryURL withIntermediateDirectories:NO attributes:nil error:NULL];
    // Convert to a file reference URL now that the directory exists
    // For some reason once it's a reference the path changes from /var to /private/var which would screw up child directory creation in later tests
    activeDirectoryURL = [activeDirectoryURL fileReferenceURL];

    resourceManager = [[PCResourceManager alloc] init];
    activeDirectory = [resourceManager addDirectory:[activeDirectoryURL path]];

    resourceManager.rootDirectory = [resourceManager resourceDirectoryForPath:activeDirectory.directoryPath];
    [PCResourceManager stub:@selector(sharedManager) andReturn:resourceManager];
    [[AppDelegate appDelegate].currentProjectSettings stub:@selector(movedResourceFrom:to:)];
});

afterEach(^{
    [[NSFileManager defaultManager] removeItemAtURL:activeDirectory.directoryReferenceURL error:NULL];
});

describe(@"When adding a resource", ^{
    context(@"to an existing folder", ^{
        __block NSUInteger originalDirectoryResourceCount;
        __block NSUInteger originalManagerResourceCount;
        __block PCResource *addedResource;
        beforeEach(^{
            originalDirectoryResourceCount = activeDirectory.resources.count;
            originalManagerResourceCount = [resourceManager allResources].count;
            [[NSFileManager defaultManager] createFileAtPath:[activeDirectory.directoryPath stringByAppendingPathComponent:@"file.png"] contents:nil attributes:nil];
            addedResource = [resourceManager addResourceWithAbsoluteFilePath:[activeDirectory.directoryPath stringByAppendingPathComponent:@"file.png"]];
        });

        it(@"the total folder resource count goes up by 1", ^{
            [[theValue(activeDirectory.resources.count) should] equal:theValue(originalDirectoryResourceCount + 1)];
        });

        it(@"The number of resources goes up by 1", ^{
            [[theValue([resourceManager allResources].count) should] equal:theValue(originalManagerResourceCount + 1)];
        });

        it(@"Exists in the directories resources", ^{
            [activeDirectory.resources containsObject:addedResource];
        });

        it(@"Exists in the resource managers resources", ^{
            [resourceManager.allResources containsObject:addedResource];
        });
    });
});


describe(@"When renaming a folder", ^{
    __block PCResource *testDirectoryResource;
    __block PCResourceDirectory *testDirectory;
    __block PCResource *testResource;
    __block PCResource *firstEmbeddedFolderResource;
    __block PCResourceDirectory *firstEmbeddedFolder;
    beforeEach(^{
        NSError *error;
        testDirectoryResource = [resourceManager addDirectoryNamed:@"testDirectory" toDirectory:activeDirectory addingSuffixOnNameCollision:NO error:&error];
        testDirectory = (PCResourceDirectory *)testDirectoryResource.data;

        testResource = [resourceManager addResourceWithAbsoluteFilePath:[testDirectory.directoryPath stringByAppendingPathComponent:@"file.png"]];
        if (error) {
            NSLog(@"Error creating directory: %@", error);
        }
    });

    context(@"with no embedded folder", ^{
        __block NSString *originalFileName;
        beforeEach(^{
            originalFileName = [testResource.filePath lastPathComponent];
            [resourceManager renameResourceFile:testDirectory.directoryPath toNewName:@"renameTest"];
        });
    });

    context(@"with one embedded folder", ^{
        __block PCResource *embeddedResource;
        __block NSString *originalFileName;
        beforeEach(^{
            firstEmbeddedFolderResource = [resourceManager addDirectoryNamed:@"moveTest" toDirectory:testDirectory addingSuffixOnNameCollision:NO error:nil];
            firstEmbeddedFolder = firstEmbeddedFolderResource.data;

            embeddedResource = [resourceManager addResourceWithAbsoluteFilePath:[firstEmbeddedFolder.directoryPath stringByAppendingPathComponent:@"test.png"]];
            originalFileName = [embeddedResource.filePath lastPathComponent];
            [resourceManager renameResourceFile:firstEmbeddedFolderResource.filePath toNewName:@"renameTest2"];
        });
    });
});

describe(@"When moving a resource to a folder", ^{
    __block PCResource *moveDirectoryResource;
    __block PCResourceDirectory *moveDirectory;

    beforeEach(^{
        moveDirectoryResource = [resourceManager addDirectoryNamed:@"move" toDirectory:activeDirectory addingSuffixOnNameCollision:NO error:nil];
        moveDirectory = moveDirectoryResource.data;
    });

    context(@"and the resource is not a folder", ^{
        __block PCResource *resourceToMove;
        __block NSString *originalFileName;
        beforeEach(^{
            resourceToMove = [resourceManager addResourceWithAbsoluteFilePath:[moveDirectory.directoryPath stringByAppendingPathComponent:@"moveTest1.png"]];
            originalFileName = [resourceToMove.filePath lastPathComponent];
            [resourceManager moveResourceFile:resourceToMove.filePath ofType:resourceToMove.type toDirectory:activeDirectory.directoryPath];
        });
    });

    context(@"and the resource is a folder with a resource", ^{
        __block PCResource *folderToMoveResource;
        __block PCResourceDirectory *folderToMove;
        __block PCResource *resourceToMove;
        beforeEach(^{
            folderToMoveResource = [resourceManager addDirectoryNamed:@"folderToMove" toDirectory:activeDirectory addingSuffixOnNameCollision:NO error:nil];
            folderToMove = folderToMoveResource.data;

            NSString *path = [folderToMove.directoryPath stringByAppendingPathComponent:@"fileToMove.png"];
            [[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data] attributes:nil];
            resourceToMove = [resourceManager addResourceWithAbsoluteFilePath:path];

            [resourceManager moveResourceFile:folderToMoveResource.filePath ofType:folderToMoveResource.type toDirectory:moveDirectory.directoryPath];
        });

        it(@"updates the path of the folder resource", ^{
            [[folderToMoveResource.filePath should] startWithString:moveDirectory.directoryPath];
        });

        context(@"and the folder is subsequently removed", ^{
            __block NSInteger originalActiveDirectoryResourceCount;
            __block NSInteger originalContainingDirectoryResourceCount;
            beforeEach(^{
                originalActiveDirectoryResourceCount = activeDirectory.resources.count;
                originalContainingDirectoryResourceCount = moveDirectory.resources.count;
                [resourceManager moveResourceFile:folderToMoveResource.filePath ofType:folderToMoveResource.type toDirectory:activeDirectory.directoryPath];
            });

            it(@"decrements the containing folders resource count by 1", ^{
                [[theValue(moveDirectory.resources.count) should] equal:theValue(originalContainingDirectoryResourceCount - 1)];
            });

            it(@"removes the folder from the containing folder", ^{
                [[moveDirectory.resources shouldNot] contain:folderToMoveResource];
            });

            it(@"Increments the new containing folders resource count by 1", ^{
                [[theValue(activeDirectory.resources.count) should] equal:theValue(originalActiveDirectoryResourceCount + 1)];
            });

            it(@"Adds the folder to the new containing folder", ^{
                [[activeDirectory.resources should] contain:folderToMoveResource];
            });
        });
    });

    context(@"and the resources is a folder with at least one embedded folder", ^{
        __block PCResource *rootFolderResource;
        __block PCResourceDirectory *rootFolder;
        __block PCResource *nestedFolderResource;
        __block PCResourceDirectory *nestedFolder;
        __block PCResource *nestedResource;
        __block NSString *nestedResourceFileName;
        __block NSString *originalNestedFolderPath;

        beforeEach(^{
            rootFolderResource = [resourceManager addDirectoryNamed:@"rootFolderToMove" toDirectory:activeDirectory addingSuffixOnNameCollision:NO error:nil];
            rootFolder = rootFolderResource.data;

            nestedFolderResource = [resourceManager addDirectoryNamed:@"embeddedFolder" toDirectory:rootFolder addingSuffixOnNameCollision:NO error:nil];
            nestedFolder = nestedFolderResource.data;

            originalNestedFolderPath = nestedFolder.directoryPath;
            nestedResource = [resourceManager addResourceWithAbsoluteFilePath:[nestedFolder.directoryPath stringByAppendingPathComponent:@"file.png"]];
            nestedResourceFileName = [nestedResource.filePath lastPathComponent];

            [resourceManager moveResourceFile:rootFolderResource.filePath ofType:rootFolderResource.type toDirectory:moveDirectory.directoryPath];
        });
    });
});


describe(@"When deleting a resource", ^{
    __block PCResource *resourceToDelete;
    __block PCResource *folderToDelete;
    beforeEach(^{
        NSString *path = [activeDirectory.directoryPath stringByAppendingPathComponent:@"deleteMe.png"];
        NSData *pngData = [NSData data]; // ignoring for now
        [[NSFileManager defaultManager] createFileAtPath:path contents:pngData attributes:nil];
        resourceToDelete = [resourceManager addResourceWithAbsoluteFilePath:path];
        folderToDelete = [resourceManager addDirectoryNamed:@"deleteMe" toDirectory:activeDirectory addingSuffixOnNameCollision:NO error:nil];
        [resourceManager addResourceWithAbsoluteFilePath:[folderToDelete.directoryPath stringByAppendingPathComponent:@"deleteMeToo.png"]];
    });
    
    context(@"and the resource is not a folder", ^{
        specify(^{
            [[theBlock(^{
                [resourceManager removeResource:resourceToDelete];
            }) should] change:^NSInteger{
                return resourceManager.allResources.count;
            } by:-1];
        });
    });

    context(@"and the resource is a folder", ^{
        specify(^{
            [[theBlock(^{
                [resourceManager removeResource:folderToDelete];
            }) should] change:^NSInteger{
                return resourceManager.allResources.count;
            } by:-2];
        });

        specify(^{
            [[theBlock(^{
                [resourceManager removeResource:folderToDelete];
            }) should] change:^NSInteger{
                return resourceManager.directories.count;
            } by:-1];
        });
    });
});

describe(@"When importing a new file from a filepath", ^{
    __block NSString *resourcePath;

    context(@"that has an @2x dependancy in the file name", ^{
        beforeAll(^{
            resourcePath = @"test/resolutionDependantFileName@2x.png";
            resourcePath = [NSString pc_trimFileNameResolutionDependencySuffix:resourcePath];
        });

        it(@"should remove the resolution dependancy", ^{
            [[resourcePath should] matchPattern:@"test/resolutionDependantFileName.png"];
        });
    });

    context(@"that has an @<decimal>x dependancy in the file name", ^{
        beforeAll(^{
            resourcePath = @"test/resolutionDependantFileName@23.5x.png";
            resourcePath = [NSString pc_trimFileNameResolutionDependencySuffix:resourcePath];
        });

        it(@"should remove the resolution dependancy", ^{
            [[resourcePath should] matchPattern:@"test/resolutionDependantFileName.png"];
        });
    });

    context(@"that has an @<multi digit number>x multi digit non decimal dependancy in the file name", ^{
        beforeAll(^{
            resourcePath = @"test/resolutionDependantFileName@23234x.png";
            resourcePath = [NSString pc_trimFileNameResolutionDependencySuffix:resourcePath];
        });

        it(@"should remove the resolution dependancy", ^{
            [[resourcePath should] matchPattern:@"test/resolutionDependantFileName.png"];
        });
    });

    context(@"that has an @<multi digit decimal>x large decimal dependancy in the file name", ^{
        beforeAll(^{
            resourcePath = @"test/resolutionDependantFileName@234.456x.png";
            resourcePath = [NSString pc_trimFileNameResolutionDependencySuffix:resourcePath];
        });

        it(@"should remove the resolution dependancy", ^{
            [[resourcePath should] matchPattern:@"test/resolutionDependantFileName.png"];
        });
    });
});

SPEC_END
