//
//  CCBPublisherTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 14-12-23.
//
//

#import <Cocoa/Cocoa.h>
#import <Kiwi/Kiwi.h>
#import "PCWhen.h"
#import "PCKeyPressedStatement.h"
#import "PCExpression.h"
#import "PCTokenValueDescriptor.h"
#import "PCChangePropertyStatement.h"
#import "CCBPublisher.h"

@interface CCBPublisher (Tests)

- (NSArray *)keyPressInfoFromWhens:(NSArray *)whens;

@end

SPEC_BEGIN(CCBPublisherTests)

describe(@"keyPressInfoFromWhens", ^{
    context(@"when there are duplicate key press whens", ^{
        let(whens, ^id {
            PCWhen *when1 = [PCWhen new];
            PCKeyPressedStatement *statement = [PCKeyPressedStatement new];
            PCExpression *expression = [PCExpression new];

            NSDictionary *value = @{ @"keycode" : @"a", @"keycodeModifier" : @"0" };
            PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:@"" evaluationType:PCTokenEvaluationTypeKeyboardInput value:value];
            PCToken *token = [PCToken tokenWithDescriptor:descriptor];
            expression.token = token;

            statement.keyExpression = expression;
            when1.statement = statement;

            PCWhen *when2 = [PCWhen new];
            statement.keyExpression = expression;
            when2.statement = statement;

            PCWhen *when3 = [PCWhen new];
            when3.statement = [PCChangePropertyStatement new];

            return @[ when1, when2, when3 ];
        });

        let(publisher, ^id {
            return [CCBPublisher new];
        });

        it(@"returns the correct number of key press info arrays", ^{
            [[[publisher keyPressInfoFromWhens:whens] should] haveCountOf:1];
        });
    });
});

SPEC_END
