//
//  PCViewLoader.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-28.
//
//

#import "PCViewLoader.h"

@implementation PCViewLoader

#pragma mark - Public

+ (id)decodeValue:(id)value ofType:(NSString *)type {
    if ([type isEqualToString:@"string"]) {
        return value;
    }
    if ([type isEqualToString:@"dictionary"]) {
        return value;
    }
    if ([type isEqualToString:@"number"]) {
        return value;
    }
    if ([type isEqualToString:@"relativeImagePath"]) {
        return value;
    }
    if ([type isEqualToString:@"font"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            return [NSFont fontWithName:value[@"fontName"] size:[value[@"fontSize"] floatValue]];
        }
    }
    if ([type isEqualToString:@"color"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            return [self colorFromArray:value];
        }
    }
    return nil;
}

+ (id)encodeValue:(id)value asType:(NSString *)type {
    if ([type isEqualToString:@"string"]) {
        return value;
    }
    if ([type isEqualToString:@"dictionary"]) {
        return value;
    }
    if ([type isEqualToString:@"number"]) {
        return value;
    }
    if ([type isEqualToString:@"relativeImagePath"]) {
        return value;
    }
    if ([type isEqualToString:@"font"]) {
        if ([value isKindOfClass:[NSFont class]]) {
            NSFont *font = value;
            return @{
                     @"fontName": font.displayName,
                     @"fontSize": @(font.pointSize),
                     };
        }
    }
    if ([type isEqualToString:@"color"]) {
        if ([value isKindOfClass:[NSColor class]]) {
            return [self arrayValueForColor:value];
        }
    }
    return nil;
}

#pragma mark - Private

#pragma mark (De)Seriailization

+ (NSArray *)arrayValueForColor:(NSColor *)color {
    color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    return @[
             @([color redComponent]),
             @([color greenComponent]),
             @([color blueComponent]),
             @([color alphaComponent]),
             ];
}

+ (NSColor *)colorFromArray:(NSArray *)array {
    if (![array isKindOfClass:[NSArray class]]) return nil;
    if ([array count] != 4) return nil;
    return [NSColor colorWithSRGBRed:[array[0] floatValue] green:[array[1] floatValue] blue:[array[2] floatValue] alpha:[array[3] floatValue]];
}

@end
