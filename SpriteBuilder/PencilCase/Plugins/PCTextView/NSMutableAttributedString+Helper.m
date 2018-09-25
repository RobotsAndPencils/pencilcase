//
//  NSMutableAttributedString+Helper.m
//  DossierPolice
//
//  Created by Dmitry Shmidt on 7/26/13.
//  Copyright (c) 2013 Shmidt Lab. All rights reserved.
//
#import "NSMutableAttributedString+Helper.h"

@implementation NSMutableAttributedString (Attributes)
- (void)addColor:(NSColor *)color range:(NSRange)range{
    if (range.location != NSNotFound) {
        [self addAttribute:NSForegroundColorAttributeName
                     value:color
                     range:range];
        [self addAttribute:NSUnderlineColorAttributeName
                     value:color
                     range:range];
    }
}
- (void)addBackgroundColor:(NSColor *)color range:(NSRange)range{
    if (range.location != NSNotFound) {
        [self addAttribute:NSBackgroundColorAttributeName
                     value:color
                     range:range];
    }
}
- (void)addUnderlineForSubstring:(bool)underline :(NSRange)range{
    if (range.location != NSNotFound) {
        if(underline){
        [self addAttribute: NSUnderlineStyleAttributeName
                     value:@(NSUnderlineStyleSingle)
                     range:range];}
        else{
            [self removeAttribute:NSUnderlineStyleAttributeName range:range];
        }
    }
}
- (void)addStrikeThrough:(int)thickness substring:(NSString * _Nonnull)substring{
    if (!substring) {
        return;
    }

    NSRange range = [self.string rangeOfString:substring];
    if (range.location != NSNotFound) {
        [self addAttribute: NSStrikethroughStyleAttributeName
                     value:@(thickness)
                     range:range];
    }
}
- (void)addShadowColor:(NSColor * _Nonnull)color width:(int)width height:(int)height radius:(int)radius substring:(NSString * _Nonnull)substring{
    if (!substring) {
        return;
    }

    NSRange range = [self.string rangeOfString:substring];
    if (range.location != NSNotFound) {
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowColor:color];
        [shadow setShadowOffset:CGSizeMake (width, height)];
        [shadow setShadowBlurRadius:radius];
        
        [self addAttribute: NSShadowAttributeName
                     value:shadow
                     range:range];
    }
}
- (void)addFontWithName:(NSString *)fontName size:(int)fontSize range:(NSRange)range{
    if (range.location != NSNotFound) {
        NSFont * font = [NSFont fontWithName:fontName size:fontSize];
        [self addAttribute: NSFontAttributeName
                     value:font
                     range:range];
    }
}
- (void)addAlignment:(NSTextAlignment)alignment range:(NSRange)range{
    if (range.location != NSNotFound) {
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        NSRange effectiveRange = range;
        NSInteger index = range.location + 1;
        if (index < self.length) {
            paraStyle = [self attribute:NSParagraphStyleAttributeName atIndex:range.location+1 effectiveRange:&effectiveRange];
            float maxLineHeight = paraStyle.maximumLineHeight;
            float minLineHeight = paraStyle.minimumLineHeight;
            paraStyle = [[NSMutableParagraphStyle alloc]init];
            paraStyle.maximumLineHeight = maxLineHeight;
            paraStyle.minimumLineHeight = minLineHeight;
        }
        paraStyle.alignment = alignment;
        [self addAttribute:NSParagraphStyleAttributeName
                     value:paraStyle
                     range:effectiveRange];
    }
}

- (void)addColorToRussianText:(NSColor *)color{
    
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"];
    
    NSRange searchRange = NSMakeRange(0,self.string.length);
    NSRange foundRange;
    while (searchRange.location < self.string.length) {
        searchRange.length = self.string.length-searchRange.location;
        foundRange = [self.string rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch range:searchRange];
        if (foundRange.location != NSNotFound) {
            [self addAttribute:NSForegroundColorAttributeName
                         value:color
                         range:foundRange];
            
            searchRange.location = foundRange.location+1;
            
        } else {
            // no more substring to find
            break;
        }
    }
}
- (void)addStrokeColor:(NSColor * _Nonnull)color thickness:(int)thickness substring:(NSString * _Nonnull)substring{
    if (!substring) {
        return;
    }

    NSRange range = [self.string rangeOfString:substring];
    if (range.location != NSNotFound) {
        [self addAttribute:NSStrokeColorAttributeName
                     value:color
                     range:range];
        [self addAttribute:NSStrokeWidthAttributeName
                     value:@(thickness)
                     range:range];
    }
}
- (void)addVerticalGlyph:(BOOL)glyph substring:(NSString * _Nonnull)substring{
    if (!substring) {
        return;
    }
    
    NSRange range = [self.string rangeOfString:substring];
    if (range.location != NSNotFound) {
        [self addAttribute:NSForegroundColorAttributeName
                     value:@(glyph)
                     range:range];
    }
}

- (void)addBoldToString:(bool)bold range:(NSRange)range{
    if(bold){[self applyFontTraits:NSBoldFontMask range:range];}
    else {[self applyFontTraits:NSUnboldFontMask range:range];}
}

-(void)addItalicsToString:(bool)italics range:(NSRange)range{
    if(italics){[self applyFontTraits:NSItalicFontMask range:range];}
    else {[self applyFontTraits:NSUnitalicFontMask range:range];}
}

- (void)addLineSpacing:(float)spacing range:(NSRange)range{
   if (range.location != NSNotFound) {
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSMutableParagraphStyle* paraStyle = [self attribute:NSParagraphStyleAttributeName atIndex:range.location+1 effectiveRange:&effectiveRange];
       NSTextAlignment alignment = paraStyle.alignment;
       
        paraStyle = [[NSMutableParagraphStyle alloc]init];
        paraStyle.maximumLineHeight = spacing * 10;
        paraStyle.minimumLineHeight = spacing * 10;
       paraStyle.alignment = alignment;
        [self addAttribute: NSParagraphStyleAttributeName
                     value:paraStyle
                     range:range];
    }
}

@end

@implementation NSString (Russian)
- (BOOL)hasRussianCharacters{
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"];
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}
- (BOOL)hasEnglishCharacters{
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}
@end