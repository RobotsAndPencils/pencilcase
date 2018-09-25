//
//  PCResourcePublishTest.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-06.
//
//

#import <Kiwi/Kiwi.h>
#import "PCFilePublisher.h"
#import "PCImageFilePublisher.h"
#import "PCSoundFilePublisher.h"
#import "PCPublishFile.h"
#import "CCBPublisher.h"
#import "FCFormatConverter.h"

@interface PCSoundFilePublisher(Tests)

- (NSInteger)soundFormatForFile:(PCPublishFile *)file publisher:(CCBPublisher *)publisher;

@end

SPEC_BEGIN(PCResourcePublishTests)

context(@"Given a file to publish", ^{
    NSDictionary *originalAttributes = @{ NSFileSize : @100, NSFileModificationDate : [NSDate date] };
    NSDictionary *changedAttributes  = @{ NSFileSize : @101, NSFileModificationDate : [NSDate date] };
    NSString *absolutePath = @"path/to/an/absolute/file/path.dat";
    NSString *rootPath = @"path/to/an/absolute";

    __block PCPublishFile *file;
    beforeEach(^{
        [[NSFileManager defaultManager] stub:@selector(attributesOfItemAtPath:error:) andReturn:originalAttributes];
        file = [[PCPublishFile alloc] initWithAbsolutePath:absolutePath rootPath:rootPath];
    });

    it(@"its relative path is a portion of its absolute path", ^{
        [[file.relativePath should] equal:@"/file/path.dat"];
    });

    context(@"that has been previously published", ^{

        context(@"and has not changed since last publish", ^{
            __block PCPublishFile *lastFile;
            beforeEach(^{
                [[NSFileManager defaultManager] stub:@selector(attributesOfItemAtPath:error:) andReturn:originalAttributes];
                lastFile = [[PCPublishFile alloc] initWithAbsolutePath:absolutePath rootPath:rootPath];
            });

            it(@"should not think there has been a change", ^{
                [[theValue([file hasChangedSince:lastFile]) should] equal:theValue(NO)];
            });
        });

        context(@"and changed since last publish", ^{
            __block PCPublishFile *lastFile;
            beforeEach(^{
                [[NSFileManager defaultManager] stub:@selector(attributesOfItemAtPath:error:) andReturn:changedAttributes];
                lastFile = [[PCPublishFile alloc] init];
            });

            it(@"should think there has been a change", ^{
                [[theValue([file hasChangedSince:lastFile]) should] equal:theValue(YES)];
            });
        });
    });

    context(@"and the file is about to be published", ^{
        __block PCFilePublisher *defaultPublisher;
        __block CCBPublisher *publisher;
        beforeEach(^{
            defaultPublisher = [[PCFilePublisher alloc] init];
            publisher = [CCBPublisher mock];
        });

        context(@"given a previous publish that included the file", ^{
            __block NSDictionary *previousManifest;

            context(@"and the file was not changed", ^{
                beforeEach(^{
                    [[NSFileManager defaultManager] stub:@selector(attributesOfItemAtPath:error:) andReturn:originalAttributes];
                    PCPublishFile *publishFile = [[PCPublishFile alloc] initWithAbsolutePath:absolutePath rootPath:rootPath];
                    previousManifest = @{ publishFile.relativePath : publishFile };
                });

                context(@"and the original file still exists", ^{
                    beforeEach(^{
                        [[NSFileManager defaultManager] stub:@selector(fileExistsAtPath:) andReturn:theValue(YES)];
                    });

                    it(@"should not want to publish", ^{
                        BOOL shouldPublish = [defaultPublisher shouldPublishFile:file to:@"output/path" previousManifest:previousManifest publisher:publisher];
                        [[theValue(shouldPublish) should] equal:theValue(NO)];
                    });
                });

                context(@"and the file no longer exists", ^{
                    beforeEach(^{
                        [[NSFileManager defaultManager] stub:@selector(fileExistsAtPath:) withBlock:^(NSArray *arguments) {
                            NSString *path = arguments.firstObject;
                            return theValue([path isEqualToString:file.absolutePath]);
                        }];
                    });

                    it(@"should want to publish", ^{
                        BOOL shouldPublish = [defaultPublisher shouldPublishFile:file to:@"output/path" previousManifest:previousManifest publisher:publisher];
                        [[theValue(shouldPublish) should] equal:theValue(YES)];
                    });
                });
            });

            context(@"and the file was changed", ^{
                beforeEach(^{
                    [[NSFileManager defaultManager] stub:@selector(attributesOfItemAtPath:error:) andReturn:changedAttributes];
                    PCPublishFile *publishFile = [[PCPublishFile alloc] initWithAbsolutePath:absolutePath rootPath:rootPath];
                    previousManifest = @{ publishFile.relativePath : publishFile };
                });

                context(@"and the original file still exists", ^{
                    beforeEach(^{
                        [[NSFileManager defaultManager] stub:@selector(fileExistsAtPath:) andReturn:theValue(YES)];
                    });

                    it(@"should want to publish", ^{
                        BOOL shouldPublish = [defaultPublisher shouldPublishFile:file to:@"output/path" previousManifest:previousManifest publisher:publisher];
                        [[theValue(shouldPublish) should] equal:theValue(YES)];
                    });
                });

                context(@"and the file no longer exists", ^{
                    beforeEach(^{
                        [[NSFileManager defaultManager] stub:@selector(fileExistsAtPath:) withBlock:^(NSArray *arguments) {
                            NSString *path = arguments.firstObject;
                            return theValue([path isEqualToString:file.absolutePath]);
                        }];
                    });

                    it(@"should want to publish", ^{
                        BOOL shouldPublish = [defaultPublisher shouldPublishFile:file to:@"output/path" previousManifest:previousManifest publisher:publisher];
                        [[theValue(shouldPublish) should] equal:theValue(YES)];
                    });
                });
            });
        });
    });

    context(@"and a default file publisher", ^{
        __block PCFilePublisher *defaultPublisher;
        __block CCBPublisher *publisher;
        beforeEach(^{
            defaultPublisher = [[PCFilePublisher alloc] init];
            publisher = [CCBPublisher mock];
        });

        context(@"when calculating the file output to `output/directory`", ^{
            __block NSArray *expectedOutput;
            beforeEach(^{
                expectedOutput = [defaultPublisher expectedOutputFilesForFile:file inOutputDirectory:@"output/directory" publisher:publisher]
                ;
            });

            it(@"should get one result", ^{
                [[theValue(expectedOutput.count) should] equal:theValue(1)];
            });

            it(@"should expect an output path in that directory", ^{
                [[expectedOutput.firstObject should] equal:@"output/directory/file/path.dat"];
            });
        });
    });

    context(@"and an image file publisher", ^{
        __block PCImageFilePublisher *imagePublisher;
        __block CCBPublisher *publisher;
        beforeEach(^{
            imagePublisher = [[PCImageFilePublisher alloc] init];
            publisher = [CCBPublisher mock];
        });

        context(@"With default iphone resolutions", ^{
            beforeEach(^{
                [publisher stub:@selector(publishForResolutions) andReturn:@[ @"phone", @"phone3x", @"phonehd" ]];
            });
            context(@"when calculating the file output to `output/directory`", ^{
                __block NSArray *expectedOutput;
                beforeEach(^{
                    expectedOutput = [imagePublisher expectedOutputFilesForFile:file inOutputDirectory:@"output/directory" publisher:publisher];
                });

                it(@"should get three results", ^{
                    [[theValue(expectedOutput.count) should] equal:theValue(3)];
                });

                it(@"should expect three outputs in that directory", ^{
                    [[theValue([expectedOutput containsObject:@"output/directory/file/resources-phone/path.png"]) should] equal:theValue(YES)];
                    [[theValue([expectedOutput containsObject:@"output/directory/file/resources-phone3x/path.png"]) should] equal:theValue(YES)];
                    [[theValue([expectedOutput containsObject:@"output/directory/file/resources-phonehd/path.png"]) should] equal:theValue(YES)];
                });
            });
        });

        context(@"With default ipad resolutions", ^{
            beforeEach(^{
                [publisher stub:@selector(publishForResolutions) andReturn:@[ @"tablet", @"tablethd" ]];
            });
            context(@"when calculating the file output to `output/directory`", ^{
                __block NSArray *expectedOutput;
                beforeEach(^{
                    expectedOutput = [imagePublisher expectedOutputFilesForFile:file inOutputDirectory:@"output/directory" publisher:publisher];
                });

                it(@"should get two results", ^{
                    [[theValue(expectedOutput.count) should] equal:theValue(2)];
                });

                it(@"should expect two outputs in that directory", ^{
                    [[theValue([expectedOutput containsObject:@"output/directory/file/resources-tablet/path.png"]) should] equal:theValue(YES)];
                    [[theValue([expectedOutput containsObject:@"output/directory/file/resources-tablethd/path.png"]) should] equal:theValue(YES)];
                });
            });
        });
    });

    context(@"and a sound file publisher", ^{
        __block PCSoundFilePublisher *soundPublisher;
        __block CCBPublisher *publisher;
        beforeEach(^{
            soundPublisher = [[PCSoundFilePublisher alloc] init];
            publisher = [CCBPublisher mock];
        });

        context(@"and the sound will export as m4a", ^{
            beforeEach(^{
                [soundPublisher stub:@selector(soundFormatForFile:publisher:) andReturn:theValue(kFCSoundFormatMP4)];
            });

            context(@"when calculating the file output to `output/directory`", ^{
                __block NSArray *expectedOutput;
                beforeEach(^{
                    expectedOutput = [soundPublisher expectedOutputFilesForFile:file inOutputDirectory:@"output/directory" publisher:publisher];
                });

                it(@"should have one result", ^{
                    [[theValue(expectedOutput.count) should] equal:theValue(1)];
                });

                it(@"should change the extension to m4a", ^{
                    [[expectedOutput.firstObject should] equal:@"output/directory/file/path.m4a"];
                });
            });
        });

        context(@"and the sound will export as caf", ^{
            beforeEach(^{
                [soundPublisher stub:@selector(soundFormatForFile:publisher:) andReturn:theValue(kFCSoundFormatCAF)];
            });

            context(@"when calculating the file output to `output/directory`", ^{
                __block NSArray *expectedOutput;
                beforeEach(^{
                    expectedOutput = [soundPublisher expectedOutputFilesForFile:file inOutputDirectory:@"output/directory" publisher:publisher];
                });

                it(@"should have one result", ^{
                    [[theValue(expectedOutput.count) should] equal:theValue(1)];
                });

                it(@"should change the extension to caf", ^{
                    [[expectedOutput.firstObject should] equal:@"output/directory/file/path.caf"];
                });
            });
        });
    });
});

SPEC_END
