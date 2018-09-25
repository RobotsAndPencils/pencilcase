//
//  NSString+CamelCase.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-12-16.
//
//

#import <Foundation/Foundation.h>

@interface NSString (CamelCase)

- (NSString *)pc_upperCamelCaseString;
- (NSString *)pc_lowerCamelCaseString;
- (NSString *)pc_stringWithoutWhitespace;
- (NSString *)pc_stringByReplacingCharactersInSet:(NSCharacterSet *)characterSet withString:(NSString *)newString;

@end
