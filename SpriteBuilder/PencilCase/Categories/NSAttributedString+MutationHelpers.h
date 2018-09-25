//
//  NSAttributedString+MutationHelpers.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-06.
//
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (MutationHelpers)

/**
 @returns The string without leading or trailing whitespace. Ex. "  Hi! It's me!  " -> "Hi! It's me!"
 */
- (NSAttributedString *)pc_stringByRemovingLeadingAndTrailingWhitespace;

@end
