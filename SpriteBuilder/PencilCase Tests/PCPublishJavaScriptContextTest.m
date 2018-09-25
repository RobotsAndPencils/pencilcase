//
//  PCPublishJavaScriptContextTest.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-05-14.
//
//

#import <Kiwi/Kiwi.h>
#import "PCPublishJavascriptContext.h"

@interface PCPublishJavascriptContext (Tests)
- (NSString *)shimGeneratorScript:(NSString *)generatorScript;
@end

SPEC_BEGIN(PCPublishJavascriptContextTests)

describe(@"shimGeneratorScript:", ^{
    let(context, ^id(){
        return [[PCPublishJavascriptContext alloc] init];
    });

    describe(@"script without newline", ^{
        let(script, ^id(){
            return @"// Card 1\n"
                    "\n"
                    "Creation.nodeWithUUID('C6EB020B-D323-4B87-9A54-B34538C0EA12').addTapRecognizer(1, 1);\n"
                    "Creation.nodeWithUUID('C6EB020B-D323-4B87-9A54-B34538C0EA12').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedVideo) {\n"
                    "if (numberOfTaps !== 1 || numberOfTouches !== 1) return;\n"
                    "co(function *() {\n"
                    "var yieldResult;\n"
                    "composer.on(\"finished\", function(result, error) {\n"
                    "   console.log(\"result: \" + result + \"\" + error);\n"
                    "});;\n"
                    "});\n"
                    "})";
        });

        it(@"should return a non-empty string", ^{
            [[[context shimGeneratorScript:script] shouldNot] equal:@"undefined"];
        });
    });

    describe(@"script containing newline in a string", ^{
        let(script, ^id() {
            return @"// Card 1\n"
                    "\n"
                    "Creation.nodeWithUUID('C6EB020B-D323-4B87-9A54-B34538C0EA12').addTapRecognizer(1, 1);\n"
                    "Creation.nodeWithUUID('C6EB020B-D323-4B87-9A54-B34538C0EA12').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedVideo) {\n"
                    "if (numberOfTaps !== 1 || numberOfTouches !== 1) return;\n"
                    "co(function *() {\n"
                    "var yieldResult;\n"
                    "composer.on(\"finished\", function(result, error) {\n"
                    "   console.log(\"result: \" + result + \"\\n\" + error);\n"
                    "});;\n"
                    "});\n"
                    "})";
        });

        it(@"should return a non-empty string", ^{
            [[[context shimGeneratorScript:script] shouldNot] equal:@"undefined"];
        });
    });
});

SPEC_END

