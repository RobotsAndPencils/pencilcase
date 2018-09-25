//
//  PCBehaviourListTests.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-10.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCBehaviourList.h"
#import "PCWhen.h"

SPEC_BEGIN(PCBehaviourListTests)

describe(@"PCBehaviourListTests", ^{

    __block PCBehaviourList *behaviourList;

    beforeEach(^{
        behaviourList = [[PCBehaviourList alloc] init];
    });

    context(@"with a few Whens", ^{

        __block PCWhen *whenA;
        __block PCWhen *whenB;
        __block PCWhen *whenC;

        beforeEach(^{
            whenA = [[PCWhen alloc] init];
            [behaviourList insertWhen:whenA atIndex:0];

            whenB = [[PCWhen alloc] init];
            [behaviourList insertWhen:whenB atIndex:1];

            whenC = [[PCWhen alloc] init];
            [behaviourList insertWhen:whenC atIndex:2];
        });

        describe(@"Removing a When", ^{

            specify(^{
                [[theBlock(^{
                    [behaviourList removeWhen:whenB];
                }) should] change:^NSInteger{
                    return behaviourList.whens.count;
                } by:-1];
            });

            it(@"does not contain the removed When", ^{
                [behaviourList removeWhen:whenB];
                [[theValue([behaviourList.whens indexOfObjectIdenticalTo:whenB]) should] equal:theValue(NSNotFound)];
            });

        });

        describe(@"Inserting a When", ^{

            __block PCWhen *newWhen;

            beforeEach(^{
                newWhen = [[PCWhen alloc] init];
            });

            specify(^{
                [[theBlock(^{
                    [behaviourList insertWhen:newWhen atIndex:1];
                }) should] change:^NSInteger{
                    return behaviourList.whens.count;
                } by:1];
            });

            it(@"contains the added When", ^{
                [behaviourList insertWhen:newWhen atIndex:1];
                [[theValue([behaviourList.whens indexOfObjectIdenticalTo:newWhen]) should] equal:theValue(1)];
            });

        });

        context(@"with a delegate", ^{

            __block NSObject<PCBehaviourListDelegate> *mockDelgate;

            beforeEach(^{
                mockDelgate = [KWMock mockForProtocol:@protocol(PCBehaviourListDelegate)];
                behaviourList.delegate = mockDelgate;
            });

            it(@"notifies delegate when inserting a When", ^{
                PCWhen *when = [[PCWhen alloc] init];
                [[mockDelgate should] receive:@selector(didAddWhen:atIndex:) withArguments:when, theValue(1)];
                [behaviourList insertWhen:when atIndex:1];
            });

            it(@"notifies delegate when removing When", ^{
                [[mockDelgate should] receive:@selector(didRemoveWhen:) withArguments:whenB];
                [behaviourList removeWhen:whenB];
            });
        });

    });

});

SPEC_END