//
//  NSStringCamelCaseTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-12-16.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>

#import "NSString+CamelCase.h"

SPEC_BEGIN(NSStringCamelCaseTests)

describe(@"pc_upperCamelCaseString", ^{
    context(@"when the string starts with a letter", ^{
        let(letterString, ^id{
            return @"aA3Sas dFDf\tas";
        });

        it(@"should begin with a uppercase letter", ^{
            NSLog(@"letterString = %@", letterString);
            [[theValue([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[[letterString pc_upperCamelCaseString] characterAtIndex:0]]) should] beTrue];
        });
        it(@"should not change the case of any other letters", ^{
            NSString *originalStringWithoutWhitespace = [letterString pc_stringWithoutWhitespace];
            [[[[letterString pc_upperCamelCaseString] substringFromIndex:1] should] equal:[originalStringWithoutWhitespace substringFromIndex:1]];
        });
        it(@"should not contain any whitespace", ^{
            [[theValue([[letterString pc_upperCamelCaseString] rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location) should] equal:@(NSNotFound)];
        });
    });
});

describe(@"pc_lowerCamelCaseString", ^{
    context(@"when the string starts with a letter", ^{
        let(letterString, ^id{
            return @"AA3Sas dFDf\tas";
        });

        it(@"should begin with a lowercase letter", ^{
            NSLog(@"[letterString pc_lowerCamelCaseString] = %@", [letterString pc_lowerCamelCaseString]);
            [[theValue([[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[[letterString pc_lowerCamelCaseString] characterAtIndex:0]]) should] beTrue];
        });
        it(@"should not change the case of any other letters", ^{
            NSString *originalStringWithoutWhitespace = [letterString pc_stringWithoutWhitespace];
            [[[[letterString pc_lowerCamelCaseString] substringFromIndex:1] should] equal:[originalStringWithoutWhitespace substringFromIndex:1]];
        });
        it(@"should not contain any whitespace", ^{
            [[theValue([[letterString pc_lowerCamelCaseString] rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location) should] equal:@(NSNotFound)];
        });
    });
});

SPEC_END