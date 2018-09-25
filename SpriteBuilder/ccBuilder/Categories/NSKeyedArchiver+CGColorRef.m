//
//  NSKeyedArchiver+CGColorRef.m
//  SpriteBuilder
//
//  Created by Brandon on 2/12/2014.
//
//

#import "NSKeyedArchiver+CGColorRef.h"

@implementation NSKeyedArchiver (CGColorRef)

+ (NSData *)archivedDataWithCGColor:(CGColorRef)color {
    if (!color) return nil;

    const CGFloat* components = CGColorGetComponents(color);
    NSDictionary *componentsDictionary = @{ @"red" : @(components[0]), @"green" : @(components[1]), @"blue" : @(components[2]), @"alpha" : @(components[3]) };
    return [NSKeyedArchiver archivedDataWithRootObject:componentsDictionary];
}

@end
