//
//  PCExpressionJavaScriptRepresentationTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 14-12-11.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCExpression.h"

SPEC_BEGIN(PCExpressionJavaScriptRepresentationTests)

__block PCExpression *expression;
__block NSString *tokenRepresentation;
beforeEach(^{
    PCToken *token = [PCToken new];
    tokenRepresentation = @"Math.random()";
    [token stub:@selector(javaScriptRepresentation) andReturn:tokenRepresentation];

    expression = [PCExpression new];
    expression.token = token;
    expression.advancedChunks = @[ @"3 + ", token];
});

context(@"When the expression is simple", ^{
    beforeEach(^{
        expression.isSimpleExpression = YES;
    });

    it(@"should return that token's representation", ^{
        NSString *representation = [expression javaScriptRepresentation];
        [[representation should] equal:tokenRepresentation];
    });
});

context(@"When the expression is advanced", ^{
    beforeEach(^{
        expression.isSimpleExpression = NO;
    });

    it(@"should return the concatenation of the chunks", ^{
        NSString *representation = [expression javaScriptRepresentation];
        [[representation should] equal:@"3 + Math.random()"];
    });
});

SPEC_END


