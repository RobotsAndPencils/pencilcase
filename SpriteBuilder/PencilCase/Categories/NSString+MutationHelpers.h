//
//  NSString+MutationHelpers.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2015-01-05.
//
//

#import <Foundation/Foundation.h>

@interface NSString (MutationHelpers)

/**
 * @discussion Removes leading and trailing quotes from a string if it has both, otherwise returns the string unchanged.
 * "hello" -> hello
 */
- (NSString *)pc_stringByUnquoting;

@end
