//
//  NSString+NumericPostscript.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-05.
//
//

#import <Foundation/Foundation.h>

@interface NSString (NumericPostscript)

/**
 @returns The numeric postscript on the string. for example, Jenny2 would return 2. Free4All2 would also return 2. Returns an empty string if there is no postscript.
 */
- (NSString *)pc_numericPostscript;

/**
 @returns The string without the postscript. For example, Jenny2 would become Jenny, and Free4All2 would become Free4All.
 */
- (NSString *)pc_stringWithoutNumericPostscript;

@end
