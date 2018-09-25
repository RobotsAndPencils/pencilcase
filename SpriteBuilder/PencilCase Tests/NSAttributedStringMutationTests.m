//
//  NSStringMutationTests.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-06.
//
//

#import <Cocoa/Cocoa.h>
#import <Kiwi/Kiwi.h>
#import "NSAttributedString+MutationHelpers.h"

SPEC_BEGIN(NSAttributedStringMutationTests)
context(@"When stripping white space from a string", ^{
    specify(^{
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"  hi!"];
        [[[string pc_stringByRemovingLeadingAndTrailingWhitespace].string should] equal:@"hi!"];
    });

    specify(^{
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"hi!" ];
        [[[string pc_stringByRemovingLeadingAndTrailingWhitespace].string should] equal:@"hi!"];
    });

    specify(^{
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"  hi!  "];
        [[[string pc_stringByRemovingLeadingAndTrailingWhitespace].string should] equal:@"hi!"];
    });

    specify(^{
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"hi!"];
        [[[string pc_stringByRemovingLeadingAndTrailingWhitespace].string should] equal:@"hi!"];
    });

    specify(^{
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@" It's me, Mario! "];
        [[[string pc_stringByRemovingLeadingAndTrailingWhitespace].string should] equal:@"It's me, Mario!"];
    });
});

SPEC_END