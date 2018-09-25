//
//  NSColor+PCColors.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-12.
//
//

#import <Cocoa/Cocoa.h>

@interface NSColor (PCColors)

+ (NSColor *)pc_invalidExpressionColor;
+ (NSColor *)pc_textButtonTitleColor;
+ (NSColor *)pc_textButtonAlternateTitleColor;
+ (NSColor *)pc_highlightedRecentsTitleColor;
+ (NSColor *)pc_regularRecentsTitleColor;
+ (NSColor *)pc_highlightedCellBackgroundColor;

/**
 Given a 4 component array, returns an NSColor
 @param array An array of 4 components to create the color from, with the components being in the order r, g, b, a
 @returns nil if the array does not have 4 colors, or else a color if it does
 */
+ (NSColor *)pc_colorFromArray:(NSArray *)array;

/**
 @returns A 4 component array constructed from the color, with the values in indices 0-3 mapping to the r, g, b, and a values of the color respectively
 */
- (NSArray *)pc_convertToArray;

@end
