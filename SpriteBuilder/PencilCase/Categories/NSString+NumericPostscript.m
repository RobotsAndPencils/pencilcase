//
//  NSString+NumericPostscript.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-05.
//
//

#import "NSString+NumericPostscript.h"

@implementation NSString (NumericPostscript)

- (NSString *)pc_numericPostscript {
    NSMutableString *result = [NSMutableString string];

    for (NSInteger characterIndex = self.length - 1; characterIndex >= 0; characterIndex--) {
        if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[self characterAtIndex:characterIndex]]) {
            [result insertString:[self substringWithRange:NSMakeRange(characterIndex, 1)] atIndex:0];
        } else {
            break;
        }
    }
    return result;
}

- (NSString *)pc_stringWithoutNumericPostscript {
    NSString *numericPostscript = [self pc_numericPostscript];
    return [self substringToIndex:self.length - numericPostscript.length];
}

@end
