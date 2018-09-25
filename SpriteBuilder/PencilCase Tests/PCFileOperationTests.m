//
//  PCFileOperationTests.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-02-10.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "NSFileManager+FileUtilities.h"

@interface PCFileOperationTests : XCTestCase

@end

SPEC_BEGIN(PCFileOperationTrashTests)

context(@"For a given file URL", ^{
    __block NSURL *trashURL = [NSURL URLWithString:@"Users/test/.Trash/testname.fileName"];
    __block NSURL *hiddenFileURL = [NSURL URLWithString:@"Users/test/.Trashy/testname.fileName"];
    __block NSURL *regularURL = [NSURL URLWithString:@"Users/test/testname.fileName"];

    
    it(@"We should be able to destinguish if it is in the trash",^{
        [[theValue([NSFileManager pc_isFileInTrash:trashURL])  should] beTrue];
    });
    
    it(@"We should be able to destinguish if it is not in the trash but has a similar hidden format",^{
        [[theValue([NSFileManager pc_isFileInTrash:hiddenFileURL])  should] beFalse];
    });
    
    it(@"We should be able to destinguish if it is not the trash",^{
        [[theValue([NSFileManager pc_isFileInTrash:regularURL]) should] beFalse];
    });
});

SPEC_END

