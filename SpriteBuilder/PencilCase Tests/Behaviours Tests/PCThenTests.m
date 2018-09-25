//
//  PCThenTests.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-10.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCWhen.h"
#import "PCThen.h"
#import "PCStatement.h"
#import "PCToken.h"

SPEC_BEGIN(PCThenTests)

describe(@"PCThen", ^{

    __block PCThen *then;

    beforeEach(^{
        then = [[PCThen alloc] init];
        then.statement = [[PCStatement alloc] init];
    });

    describe(@"search", ^{
        it(@"searches on statement", ^{
            [[then.statement should] receive:@selector(matchesSearch:)];
            [then matchesSearch:@""];
        });

        it(@"matches search if statement matches", ^{
            [then.statement stub:@selector(matchesSearch:) andReturn:theValue(YES)];
            [[theValue([then matchesSearch:@""]) should] beTrue];
        });

        it(@"doesn't match if statement doesn't match", ^{
            [then.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
            [[theValue([then matchesSearch:@""]) should] beFalse];
        });
    });

});

SPEC_END
