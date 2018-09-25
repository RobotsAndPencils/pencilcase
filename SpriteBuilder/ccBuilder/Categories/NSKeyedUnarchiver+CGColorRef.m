//
//  NSKeyedUnarchiver+CGColorRef.m
//  SpriteBuilder
//
//  Created by Brandon on 2/12/2014.
//
//

#import "NSKeyedUnarchiver+CGColorRef.h"

@implementation NSKeyedUnarchiver (CGColorRef)

+ (CGColorRef)createCGColorByUnarchivingData:(NSData *)data {
    NSDictionary *componentsDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    CGFloat red = [componentsDictionary[@"red"] floatValue];
    CGFloat green = [componentsDictionary[@"green"] floatValue];
    CGFloat blue = [componentsDictionary[@"blue"] floatValue];
    CGFloat alpha = [componentsDictionary[@"alpha"] floatValue];
    CGFloat components[4] = {red, green, blue, alpha};

    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorRef color = CGColorCreate(space, components);
    CGColorSpaceRelease(space);
    return color;
}

@end
