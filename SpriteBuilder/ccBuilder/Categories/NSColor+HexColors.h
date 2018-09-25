//
//  NSColor+HexColors.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-15.
//
//

#import <Cocoa/Cocoa.h>

@interface NSColor (HexColors)

+ (NSColor *)pc_colorFromHexRGB:(NSString *)inColorString;
+ (NSColor *)pc_darkLabelColor;

@end
