//
//  NSAttributedString+FontSize.m
//  
//
//  Created by Orest Nazarewycz on 2014-12-09.
//
//

#import "NSAttributedString+FontSize.h"

@implementation NSAttributedString (FontSize)

- (NSAttributedString *)pc_scaleFontSizeBy:(CGFloat)scale {
    NSMutableAttributedString *attributedString = [self mutableCopy];
    
    {
        [attributedString beginEditing];
        
        [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            
            UIFont *font = value;
            font = [font fontWithSize:font.pointSize * scale];
            
            [attributedString removeAttribute:NSFontAttributeName range:range];
            [attributedString addAttribute:NSFontAttributeName value:font range:range];
        }];
        
        [attributedString endEditing];
    }
    
    return [attributedString copy];
}

@end
