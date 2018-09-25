//
//  NSString+CamelCase.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-12-16.
//
//

#import "NSString+CamelCase.h"

@implementation NSString (CamelCase)

- (NSString *)pc_upperCamelCaseString {
    NSString *withoutWhitespace = [self pc_stringWithoutWhitespace];
    return [[[withoutWhitespace substringToIndex:1] uppercaseString] stringByAppendingString:[withoutWhitespace substringFromIndex:1]];
}

- (NSString *)pc_lowerCamelCaseString {
    NSString *withoutWhitespace = [self pc_stringWithoutWhitespace];
    return [[[withoutWhitespace substringToIndex:1] lowercaseString] stringByAppendingString:[withoutWhitespace substringFromIndex:1]];
}

- (NSString *)pc_stringWithoutWhitespace {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
}

- (BOOL)pc_beginsWithCharacterInSet:(NSCharacterSet *)characterSet {
    if (self.length < 1) return NO;
    return [characterSet characterIsMember:[self characterAtIndex:0]];
}

- (NSString *)pc_stringByReplacingCharactersInSet:(NSCharacterSet *)characterSet withString:(NSString *)newString {
    return [[self componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:newString];
}

@end
