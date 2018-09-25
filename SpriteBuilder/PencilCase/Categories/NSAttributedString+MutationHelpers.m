//
//  NSAttributedString+MutationHelpers.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-06.
//
//

#import "NSAttributedString+MutationHelpers.h"

@implementation NSAttributedString (MutationHelpers)

- (NSAttributedString *)pc_stringByRemovingLeadingAndTrailingWhitespace {
    if (0 == self.length) return [self copy];

    NSMutableAttributedString *result = [self mutableCopy];
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSInteger leadingWhitespaceChars = 0;
    while (leadingWhitespaceChars < result.string.length && [whitespaceCharacterSet characterIsMember:[result.string characterAtIndex:leadingWhitespaceChars]]) {
        leadingWhitespaceChars++;
    }
    if (leadingWhitespaceChars > 0) {
        [result replaceCharactersInRange:NSMakeRange(0, leadingWhitespaceChars) withString:@""];
    }

    if (result.length == 0) return [result copy];

    NSInteger trailingWhitespaceChars = 0;
    while (trailingWhitespaceChars < result.string.length - 1 && [whitespaceCharacterSet characterIsMember:[result.string characterAtIndex:result.string.length - 1 - trailingWhitespaceChars]]) {
        trailingWhitespaceChars++;
    }
    if (trailingWhitespaceChars > 0) {
        [result replaceCharactersInRange:NSMakeRange(result.length - trailingWhitespaceChars, trailingWhitespaceChars) withString:@""];
    }

    return [result copy];
}

@end
