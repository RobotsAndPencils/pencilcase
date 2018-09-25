//
//  PCWhenTests.m
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

SPEC_BEGIN(PCWhenTests)

describe(@"PCWhen", ^{

    __block PCWhen *when;

    beforeEach(^{
        when = [[PCWhen alloc] init];
    });

    context(@"with a few thens", ^{

        __block PCThen *thenA;
        __block PCThen *thenB;
        __block PCThen *thenC;

        beforeEach(^{
            thenA = [[PCThen alloc] init];
            [when insertThen:thenA atIndex:0];

            thenB = [[PCThen alloc] init];
            [when insertThen:thenB atIndex:1];

            thenC = [[PCThen alloc] init];
            [when insertThen:thenC atIndex:2];
        });

        describe(@"Removing a Then", ^{

            specify(^{
                [[theBlock(^{
                    [when removeThen:thenB];
                }) should] change:^NSInteger{
                    return when.thens.count;
                } by:-1];
            });

            it(@"does not contain the removed Then", ^{
                [when removeThen:thenB];
                [[theValue([when.thens indexOfObjectIdenticalTo:thenB]) should] equal:theValue(NSNotFound)];
            });

        });

        describe(@"Inserting a Then", ^{

            __block PCThen *newThen;

            beforeEach(^{
                newThen = [[PCThen alloc] init];
            });

            specify(^{
                [[theBlock(^{
                    [when insertThen:newThen atIndex:1];
                }) should] change:^NSInteger{
                    return when.thens.count;
                } by:1];
            });

            it(@"contains the added Then", ^{
                [when insertThen:newThen atIndex:1];
                [[theValue([when.thens indexOfObjectIdenticalTo:newThen]) should] equal:theValue(1)];
            });

            it(@"sets the When reference on the Then", ^{
                [when insertThen:newThen atIndex:1];
                [[newThen.when should] equal:when];
            });
            
        });

        it(@"knows the previous Then for a Then", ^{
            [[[when previousThenForThen:thenB] should] beIdenticalTo:thenA];
        });

        it(@"knows the next Then for a Then", ^{
            [[[when nextThenForThen:thenB] should] beIdenticalTo:thenC];
        });

        context(@"with a delegate", ^{

            __block NSObject<PCWhenDelegate> *mockDelgate;

            beforeEach(^{
                mockDelgate = [KWMock mockForProtocol:@protocol(PCWhenDelegate)];
                when.delegate = mockDelgate;
            });

            it(@"notifies delegate when inserting a Then", ^{
                PCThen *then = [[PCThen alloc] init];
                [[mockDelgate should] receive:@selector(didAddThen:atIndex:) withArguments:then, theValue(1)];
                [when insertThen:then atIndex:1];
            });

            it(@"notifies delegate when removing Then", ^{
                [[mockDelgate should] receive:@selector(didRemoveThen:) withArguments:thenB];
                [when removeThen:thenB];
            });
        });

        context(@"with statements", ^{

            beforeEach(^{
                when.statement = [[PCStatement alloc] init];
                thenA.statement = [[PCStatement alloc] init];
                thenB.statement = [[PCStatement alloc] init];
                thenC.statement = [[PCStatement alloc] init];
            });

            context(@"When statement matches search", ^{

                beforeEach(^{
                    [when.statement stub:@selector(matchesSearch:) andReturn:theValue(YES)];
                    [thenA.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                    [thenB.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                    [thenC.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                });

                specify(^{
                    [[theValue([when matchesSearch:@""]) should] beTrue];
                });

            });

            context(@"single Then statement matches search", ^{

                beforeEach(^{
                    [when.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                    [thenA.statement stub:@selector(matchesSearch:) andReturn:theValue(YES)];
                    [thenB.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                    [thenC.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                });

                specify(^{
                    [[theValue([when matchesSearch:@""]) should] beTrue];
                });
                
            });

            context(@"No statements match search", ^{

                beforeEach(^{
                    [when.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                    [thenA.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                    [thenB.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                    [thenC.statement stub:@selector(matchesSearch:) andReturn:theValue(NO)];
                });

                specify(^{
                    [[theValue([when matchesSearch:@""]) should] beFalse];
                });
                
            });

            describe(@"available tokens", ^{
                __block PCToken *exposedAToken;
                __block PCToken *exposedBToken;
                __block PCToken *exposedCToken;

                beforeEach(^{
                    exposedAToken = [PCToken nullMock];
                    exposedBToken = [PCToken nullMock];
                    exposedCToken = [PCToken nullMock];
                    [thenA.statement stub:@selector(exposedTokens) andReturn:@[ exposedAToken ]];
                    [thenB.statement stub:@selector(exposedTokens) andReturn:@[ exposedBToken ]];
                    [thenC.statement stub:@selector(exposedTokens) andReturn:@[ exposedCToken ]];
                });

                it(@"returns available tokens for previous thens", ^{
                    [[[when availableTokensForThen:thenC] should] containObjects:exposedAToken, exposedBToken, nil];
                    [[[when availableTokensForThen:thenC] shouldNot] contain:exposedCToken];

                    [[[when availableTokensForThen:thenB] should] contain:exposedAToken];
                    [[[when availableTokensForThen:thenB] shouldNot] containObjects:exposedBToken, exposedCToken, nil];

                    [[[when availableTokensForThen:thenA] shouldNot] containObjects:exposedAToken, exposedBToken, exposedCToken, nil];
                });

                context(@"linked Thens", ^{
                    beforeEach(^{
                        thenC.runWithPrevious = YES;
                    });

                    it(@"doesn't return tokens from linked Thens", ^{
                        [[[when availableTokensForThen:thenC] should] containObjects:exposedAToken, nil];
                        [[[when availableTokensForThen:thenC] shouldNot] containObjects:exposedBToken, exposedCToken, nil];
                    });
                });

            });

        });

    });

});

SPEC_END