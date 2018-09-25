//
//  NSMutableAttributedString+Helper.h
//  DossierPolice
//
//  Created by Dmitry Shmidt on 7/26/13.
//  Copyright (c) 2013 Shmidt Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (Attributes)
- (void)addColor:(NSColor *)color range:(NSRange)range;
- (void)addBackgroundColor:(NSColor *)color range:(NSRange)range;
- (void)addUnderlineForSubstring:(bool)underline :(NSRange)range;
- (void)addStrikeThrough:(int)thickness substring:(NSString *)substring;
- (void)addShadowColor:(NSColor *)color width:(int)width height:(int)height radius:(int)radius substring:(NSString *)substring;
- (void)addFontWithName:(NSString *)fontName size:(int)fontSize range:(NSRange)range;
- (void)addAlignment:(NSTextAlignment)alignment range:(NSRange)range;
- (void)addColorToRussianText:(NSColor *)color;
- (void)addStrokeColor:(NSColor *)color thickness:(int)thickness substring:(NSString *)substring;
- (void)addVerticalGlyph:(BOOL)glyph substring:(NSString *)substring;
- (void)addBoldToString:(bool)bold range:(NSRange)range;
- (void)addItalicsToString:(bool)italics range:(NSRange)range;
- (void)addLineSpacing:(float)spacing range:(NSRange)range;

@end

@interface NSString (Russian)
- (BOOL)hasRussianCharacters;
- (BOOL)hasEnglishCharacters;
@end