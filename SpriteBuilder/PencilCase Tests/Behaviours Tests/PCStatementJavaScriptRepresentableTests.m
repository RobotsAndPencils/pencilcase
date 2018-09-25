//
//  PCStatementJavaScriptRepresentableTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 14-12-11.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import <GRMustache/GRMustacheTemplate.h>
#import "PCStatement.h"
#import "PCTapStatement.h"
#import "PCExpression.h"
#import "PCStatementRegistry.h"

@interface PCStatement (Testing)

@property (nonatomic, strong) PCExpression *objectExpression;

- (NSString* )representationTemplateString;
- (GRMustacheTemplate *)representationTemplate;
- (NSDictionary *)templateVariableToExpressionMapping;

@end

SPEC_BEGIN(PCStatementJavaScriptRepresentableTests)

it(@"All when subclasses should have a non-empty representation template", ^{
    for (Class whenStatementClass in [PCStatementRegistry sharedInstance].whenStatementClasses) {
        PCStatement *statement = (PCStatement *)[whenStatementClass new];

        // Log the empty class so it's easier to debug
        if ([statement representationTemplateString].length == 0) {
            NSLog(@"NSStringFromClass(whenStatementClass) = %@", NSStringFromClass(whenStatementClass));
        }

        [[[statement representationTemplateString] shouldNot] beEmpty];
    }
});

it(@"All when subclasses should include callback exposed tokens in their representation template", ^{
    for (Class whenStatementClass in [PCStatementRegistry sharedInstance].whenStatementClasses) {
        PCStatement *statement = (PCStatement *)[whenStatementClass new];
        NSString *exposedTokens = @"testExposedToken, anotherTestExposedToken";
        NSDictionary *templateObject = @{ @"exposedTokens" : exposedTokens };
        [[[[statement representationTemplate] renderObject:templateObject error:NULL] should] containString:exposedTokens options:0];
    }
});

it(@"All then subclasses should have a non-empty representation", ^{
    for (Class thenStatementClass in [PCStatementRegistry sharedInstance].thenStatementClasses) {
        PCStatement *statement = (PCStatement *)[thenStatementClass new];

        // Log the empty class so it's easier to debug
        if ([statement representationTemplateString].length == 0) {
            NSLog(@"NSStringFromClass(whenStatementClass) = %@", NSStringFromClass(thenStatementClass));
        }

        [[[statement representationTemplateString] shouldNot] beEmpty];
    }
});

context(@"Generating the representation of a statement subclass", ^{
    __block PCStatement *statement;
    __block NSString *objectRepresentation;
    beforeEach(^{
        statement = [PCTapStatement new];
        objectRepresentation = @"Creation.nodeWithUUID('0000-0000-0000-0000-0000')";

        PCExpression *expression = [PCExpression new];
        [expression stub:@selector(javaScriptRepresentation) andReturn:objectRepresentation];
        [statement stub:@selector(objectExpression) andReturn:expression];
    });

    specify(^{
        [[[statement javaScriptRepresentation] shouldNot] beNil];
    });

    specify(^{
        [[[statement javaScriptRepresentation] should] haveLengthOfAtLeast:1];
    });

    specify(^{
        [[[statement javaScriptRepresentation] should] containString:objectRepresentation];
    });

    specify(^{
        [[[statement javaScriptRepresentation] should] containString:@"tapLocation"];
    });

    specify(^{
        [[[statement javaScriptRepresentation] shouldNot] containString:@"\\n"];
    });
});

context(@"Generating a mapping of template variable names to expression properties", ^{
    __block PCStatement *statement;
    beforeEach(^{
        statement = [PCTapStatement new];
    });

    specify(^{
        [[[[statement templateVariableToExpressionMapping] allKeys] should] containObjectsInArray:@[ @"objectExpression" ]];
    });
});

SPEC_END


