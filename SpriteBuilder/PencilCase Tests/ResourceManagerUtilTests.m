//
//  ResourceManagerUtilTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2015-10-26.
//
//

#import <Kiwi/Kiwi.h>
#import "AppDelegate.h"
#import "ResourceManagerUtil.h"

SPEC_BEGIN(ResourceManagerUtilTests)

__block PCProjectSettings *projectSettings;
beforeEach(^{
    projectSettings = [PCProjectSettings new];
    [AppDelegate appDelegate].currentProjectSettings = projectSettings;
});

describe(@"projectPathFromRelativePath", ^{
    context(@"nil projectDirectory", ^{
        it(@"doesn't throw an exception", ^{
            [[theBlock(^{
                [ResourceManagerUtil projectPathFromRelativePath:@""];
            }) shouldNot] raise];
        });
    });

    context(@"valid projectDirectory", ^{
        beforeEach(^{
            [projectSettings stub:@selector(projectDirectory) andReturn:@"/some_path"];
        });

        it(@"doesn't throw an exception", ^{
            [[theBlock(^{
                [ResourceManagerUtil projectPathFromRelativePath:@""];
            }) shouldNot] raise];
        });
        
        context(@"relative path doesn't already include absolute path", ^{
            it(@"appends relative path to projectDirectory", ^{
                [[[ResourceManagerUtil projectPathFromRelativePath:@"relative"] should] equal:@"/some_path/relative"];
            });
        });

        context(@"relative path already includes absolute path", ^{
            it(@"returns relative path", ^{
                [[[ResourceManagerUtil projectPathFromRelativePath:@"/some_path/relative"] should] equal:@"/some_path/relative"];
            });
        });

    });
});

SPEC_END
