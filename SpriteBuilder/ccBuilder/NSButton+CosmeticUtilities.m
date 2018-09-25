//
//  NSButton+CosmeticUtilities.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-18.
//
//

#import "NSButton+CosmeticUtilities.h"

@implementation NSButton (CosmeticUtilities)

- (void)pc_setTitleTextColor:(NSColor *)color {
    if (color == nil) return;
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [self setAttributedTitle:colorTitle];
}

- (void)pc_underlineTitleText {
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [titleAttributedString length]);
    [titleAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:titleRange];
    [self setAttributedTitle:titleAttributedString];
}

@end
