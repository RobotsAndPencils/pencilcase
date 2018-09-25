//
//  PCExpressionTests.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-10.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCExpression.h"
#import "PCToken.h"

SPEC_BEGIN(PCExpressionTests)

describe(@"PCExpression", ^{

    __block PCExpression *expression;

    beforeEach(^{
        expression = [[PCExpression alloc] init];
    });

    it(@"is simple by default", ^{
        [[theValue(expression.isSimpleExpression) should] beTrue];
    });

    describe(@"hasValue", ^{
        it(@"is false by default", ^{
            [[theValue([expression hasValue]) should] beFalse];
        });

        it(@"is true if token set", ^{
            expression.token = [[PCToken alloc] init];
            [[theValue([expression hasValue]) should] beTrue];
        });

        it(@"is true if advancedChunks set and in advanced mode", ^{
            expression.isSimpleExpression = NO;
            expression.advancedChunks = @[ @"" ];
            [[theValue([expression hasValue]) should] beTrue];
        });
    });

});

SPEC_END
