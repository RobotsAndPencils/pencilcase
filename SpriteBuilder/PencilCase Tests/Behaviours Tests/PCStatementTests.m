//
//  PCStatementTests.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-10.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCStatement.h"
#import "PCExpression.h"
#import "PCTokenVariableDescriptor.h"

SPEC_BEGIN(PCStatementTests)

describe(@"PCStatement", ^{

    __block PCStatement *statement;

    beforeEach(^{
        statement = [[PCStatement alloc] init];
    });

    it(@"initializes with a UUID", ^{
        [[statement.UUID shouldNot] beNil];
    });

    context(@"setup with expression", ^{
        __block PCExpression *expressionA;
        __block PCExpression *expressionB;

        beforeEach(^{
            expressionA = [[PCExpression alloc] init];
            expressionB = [[PCExpression alloc] init];

            [statement appendString:@"start "];
            [statement appendExpression:expressionA];
            [statement appendString:@" middle "];
            [statement appendExpression:expressionB withOrder:1];
            [statement appendString:@" end"];
        });

        describe(@"search", ^{

            it(@"doesn't match if not in string", ^{
                [[theValue([statement matchesSearch:@"asdf"]) should] beFalse];
            });

            it(@"searches on string chunks", ^{
                [[theValue([statement matchesSearch:@"start"]) should] beTrue];
                [[theValue([statement matchesSearch:@"middle"]) should] beTrue];
                [[theValue([statement matchesSearch:@"end"]) should] beTrue];
            });

            it(@"searches expression chunks", ^{
                [expressionA stub:@selector(hasValue) andReturn:theValue(YES)];
                [expressionA stub:@selector(simpleAttributedStringValueWithDefaultAttributes:) andReturn:[[NSAttributedString alloc] initWithString:@"expressionA" attributes:@{}]];
                [expressionB stub:@selector(hasValue) andReturn:theValue(YES)];
                [expressionB stub:@selector(simpleAttributedStringValueWithDefaultAttributes:) andReturn:[[NSAttributedString alloc] initWithString:@"expressionB" attributes:@{}]];

                [[theValue([statement matchesSearch:@"expressionA"]) should] beTrue];
                [[theValue([statement matchesSearch:@"expressionB"]) should] beTrue];
            });

        });

        describe(@"expression validation", ^{

            __block NSObject<PCStatementDelegate> *mockDelegate;

            beforeEach(^{
                PCTokenVariableDescriptor *descriptorA = [PCTokenVariableDescriptor descriptorWithVariableName:@"descriptorA" evaluationType:PCTokenEvaluationTypeNumber sourceUUID:[NSUUID UUID]];
                expressionA.token = [PCToken tokenWithDescriptor:descriptorA];

                PCTokenVariableDescriptor *descriptorB = [PCTokenVariableDescriptor descriptorWithVariableName:@"descriptorB" evaluationType:PCTokenEvaluationTypeNumber sourceUUID:[NSUUID UUID]];
                expressionB.token = [PCToken tokenWithDescriptor:descriptorB];

                expressionA.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNumber) ];
                expressionB.supportedTokenTypes = @[ @(PCTokenEvaluationTypeNumber) ];

                mockDelegate = [KWMock mockForProtocol:@protocol(PCStatementDelegate)];
                [mockDelegate stub:@selector(statementNeedsDisplay:)];
                statement.delegate = mockDelegate;
            });

            context(@"token is no longer available", ^{
                beforeEach(^{
                    [mockDelegate stub:@selector(statementAvailableTokens:) andReturn:@[]];
                });

                it(@"is an invalid reference", ^{
                    [statement validateExpressions];
                    [[theValue(expressionA.token.isInvalidReference) should] beTrue];
                });

                it(@"doesn't validate", ^{
                    [[theValue([statement validateExpressions]) should] beFalse];
                });
            });

            context(@"token is still available", ^{
                beforeEach(^{
                    [mockDelegate stub:@selector(statementAvailableTokens:) andReturn:@[ expressionA.token ]];
                });

                it(@"is still a valid reference", ^{
                    [statement validateExpressions];
                    [[theValue(expressionA.token.isInvalidReference) should] beFalse];
                });

                it(@"doesn't validate", ^{
                    [[theValue([statement validateExpressions]) should] beFalse];
                });
            });

            context(@"both tokens are still available", ^{
                beforeEach(^{
                    [mockDelegate stub:@selector(statementAvailableTokens:) andReturn:@[ expressionA.token, expressionB.token]];
                });

                it(@"validates", ^{
                    [[theValue([statement validateExpressions]) should] beTrue];
                });
            });

        });

    });

});

SPEC_END
