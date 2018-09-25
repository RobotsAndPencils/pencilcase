//
//  NSKeyedUnarchiver+CGColorRef.h
//  SpriteBuilder
//
//  Created by Brandon on 2/12/2014.
//
//

#import <Foundation/Foundation.h>

@interface NSKeyedUnarchiver (CGColorRef)

+ (CGColorRef)createCGColorByUnarchivingData:(NSData *)data;

@end
