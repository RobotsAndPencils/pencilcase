//
//  NSString+MutationHelpers.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2015-01-05.
//
//

#import "NSString+MutationHelpers.h"

@implementation NSString (MutationHelpers)

- (NSString *)pc_stringByUnquoting {
    if ([self length] >= 2
        && [[self substringToIndex:1] isEqualToString:@"\""]
        && [[self substringFromIndex:self.length - 1] isEqualToString:@"\""]) {
        return [self substringWithRange:NSMakeRange(1, self.length - 2)];
    }
    return self;
}

@end
