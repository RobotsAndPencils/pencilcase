//
//  NSColor+HexColors.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-15.
//
//

#import "NSColor+HexColors.h"

@implementation NSColor (HexColors)

+ (NSColor *)pc_colorFromHexRGB:(NSString *)inColorString {
    NSColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;

    if (nil != inColorString) {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void)[scanner scanHexInt:&colorCode];    // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode);    // masks off high bits
    result = [NSColor
            colorWithCalibratedRed:(float)redByte / 0xff
                             green:(float)greenByte / 0xff
                              blue:(float)blueByte / 0xff
                             alpha:1.0];
    return result;
}

+ (NSColor *)pc_darkLabelColor {
    return [NSColor pc_colorFromHexRGB:@"5a5a5a"];
}

@end
