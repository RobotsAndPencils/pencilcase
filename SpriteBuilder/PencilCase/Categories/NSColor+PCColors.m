//
//  NSColor+PCColors.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-12.
//
//

#import "NSColor+PCColors.h"

@implementation NSColor (PCColors)

+ (NSColor *)pc_invalidExpressionColor {
    return [NSColor colorWithRed:225/255.0 green:200/255.0 blue:200/255.0 alpha:1];
}

+ (NSColor *)pc_textButtonTitleColor {
    return [self pc_colorWithHexString:@"00aad9"];
}


+ (NSColor *)pc_textButtonAlternateTitleColor {
    return [self pc_colorWithHexString:@"017ea1"];
}

+ (NSColor *)pc_errorColor {
    return [self pc_colorWithHexString:@"e9594d"];
}

+ (NSColor *)pc_highlightedRecentsTitleColor {
    return [NSColor colorWithRed:(19 / 255.f) green:(154 / 255.f) blue:(208 / 255.f) alpha:1];
}

+ (NSColor *)pc_regularRecentsTitleColor {
    return [NSColor colorWithRed:(75 / 255.f) green:(75 / 255.f) blue:(75 / 255.f) alpha:1];
}

+ (NSColor *)pc_highlightedCellBackgroundColor {
    return [NSColor colorWithRed:(250 / 255.0f) green:(250 / 255.0f) blue:(250 / 255.0f) alpha:1];
}

+ (NSColor *)pc_colorWithHexString:(NSString *)color {
    unsigned int red, green, blue, alpha = 255;

    NSCharacterSet *hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];
    NSString *hexOnlyColor = [[color componentsSeparatedByCharactersInSet:[hexCharacterSet invertedSet]] componentsJoinedByString: @""];

    [[NSScanner scannerWithString:[hexOnlyColor substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&red];
    [[NSScanner scannerWithString:[hexOnlyColor substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&green];
    [[NSScanner scannerWithString:[hexOnlyColor substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&blue];

    if ([hexOnlyColor length] == 8) {
        [[NSScanner scannerWithString:[hexOnlyColor substringWithRange:NSMakeRange(6, 2)]] scanHexInt:&alpha];
    }

    return [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

- (NSArray *)pc_convertToArray {
    CGFloat r, g, b, a;
    NSColor *colorInColorSpace = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    [colorInColorSpace getRed:&r green:&g blue:&b alpha:&a];
    return @[@(r), @(g), @(b), @(a)];
}

+ (NSColor *)pc_colorFromArray:(NSArray *)array {
    if (array.count != 4) return nil;
    return [NSColor colorWithDeviceRed:[array[0] floatValue] green:[array[1] floatValue] blue:[array[2] floatValue] alpha:[array[3] floatValue]];
}

@end
