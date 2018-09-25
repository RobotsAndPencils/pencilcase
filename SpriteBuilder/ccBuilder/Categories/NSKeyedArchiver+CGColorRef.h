//
//  NSKeyedArchiver+CGColorRef.h
//  SpriteBuilder
//
//  Created by Brandon on 2/12/2014.
//
//

#import <Foundation/Foundation.h>

@interface NSKeyedArchiver (CGColorRef)

+ (NSData *)archivedDataWithCGColor:(CGColorRef)color;

@end
