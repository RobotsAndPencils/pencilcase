//
//  PCWhenJavaScriptRepresentableTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 14-12-11.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCWhen.h"
#import "PCThen.h"
#import "PCTapStatement.h"
#import "PCCreateObjectStatement.h"
#import "PCChangePropertyStatement.h"
#import "PCApplyForceStatement.h"

@interface PCWhen (JavaScriptRepresentableTests)

- (NSArray *)javascriptRepresentationsOfThens:(NSArray *)thens;
- (NSArray *)groupParallelThens:(NSArray *)thens;

@end

SPEC_BEGIN(PCWhenJavaScriptRepresentableTests)

describe(@"When generating the javascript representation of thens", ^{
    __block PCWhen *when;
    beforeEach(^{
        when = [PCWhen new];
        when.statement = [PCTapStatement new];
    });

    context(@"and thens run in order", ^{
        beforeEach(^{
            PCThen *createObjectThen = [PCThen new];
            createObjectThen.statement = [PCCreateObjectStatement new];
            [when insertThen:createObjectThen atIndex:0];

            PCThen *changePropertyThen = [PCThen new];
            changePropertyThen.statement = [PCChangePropertyStatement new];
            [when insertThen:changePropertyThen atIndex:1];
        });

        it(@"should group thens appropriately", ^{
            NSArray *groupedThens = [when groupParallelThens:when.thens];
            [[groupedThens should] haveCountOf:2];
        });

        it(@"should generate the correct number of scripts", ^{
            NSArray *thenScripts = [when javascriptRepresentationsOfThens:when.thens];
            [[thenScripts should] haveCountOf:2];
        });

        it(@"should not prefix any script with 'yield ['", ^{
             NSArray *thenScripts = [when javascriptRepresentationsOfThens:when.thens];
            for (NSString *script in thenScripts) {
                [[script shouldNot] startWithString:@"yield ["];
            }
        });
    });

    context(@"and some thens run in parallel", ^{
        beforeEach(^{
            // The first two will run together
            PCThen *createObjectThen = [PCThen new];
            createObjectThen.statement = [PCCreateObjectStatement new];
            [when insertThen:createObjectThen atIndex:0];

            PCThen *changePropertyThen = [PCThen new];
            changePropertyThen.statement = [PCChangePropertyStatement new];
            changePropertyThen.runWithPrevious = YES;
            [when insertThen:changePropertyThen atIndex:1];

            PCThen *applyForceThen = [PCThen new];
            applyForceThen.statement = [PCApplyForceStatement new];
            [when insertThen:applyForceThen atIndex:2];
        });

        it(@"should group thens appropriately", ^{
            NSArray *groupedThens = [when groupParallelThens:when.thens];
            [[groupedThens should] haveCountOf:2];
        });

        it(@"should generate the correct number of scripts", ^{
            NSArray *thenScripts = [when javascriptRepresentationsOfThens:when.thens];
            [[thenScripts should] haveCountOf:2];
        });

        it(@"should prefix grouped scripts with 'yield [", ^{
            NSArray *thenScripts = [when javascriptRepresentationsOfThens:when.thens];
            NSString *groupedScript = thenScripts.firstObject;
            [[groupedScript should] containString:@"yield ["];
        });

        it(@"should suffix grouped scripts with ']'", ^{
            NSArray *thenScripts = [when javascriptRepresentationsOfThens:when.thens];
            NSString *groupedScript = thenScripts.firstObject;
            [[groupedScript should] endWithString:@"]"];
        });
    });
});

SPEC_END
