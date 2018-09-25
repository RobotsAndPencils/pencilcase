//
//  InspectorRichText.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2/22/2014.
//
//

#import "InspectorRichText.h"
#import "PCSKTextView.h"
#import "NSMutableAttributedString+Helper.h"
#import "ResourceManagerUtil.h"

NSString * const PCSKTextViewSelectionDidChange = @"PCSKTextViewSelectionDidChange";
NSString * const PCSKTextViewSetEnabled = @"PCSKTextViewSetEnabled";

@implementation InspectorRichText

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)sn andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    self = [super initWithSelection:s andPropertyName:pn andSetterName:sn andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshSelectedTextAttributes:)
                                                     name:PCSKTextViewSelectionDidChange
                                                   object:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setViewIsEnabled:)
                                                     name:PCSKTextViewSetEnabled
                                                   object:NULL];
        [self refreshSelectedTextAttributes:nil];
    }
    return self;
}

- (void)awakeFromNib {
    NSMutableAttributedString *underlineString = [self.underlinedButton.attributedTitle mutableCopy];
    [underlineString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, underlineString.length)];
    self.underlinedButton.attributedTitle = underlineString;
    
    [self refreshSelectedTextAttributes:nil];
}

- (void)setViewIsEnabled:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    BOOL setEnabled = [[userInfo objectForKey:@"enabled"] boolValue];
    self.enabled = setEnabled;
}

- (void)refreshSelectedTextAttributes:(NSNotification *)notification {
    [ResourceManagerUtil populatePopupButtonWithFonts:self.fontlistPopupButton selectedFontName:nil target:self action:@selector(setFont:)];
    
    // 1. Get the text that is currently selected in the TextView.
    // 2. set the selected range length to 1 if it is 0. We do this so that the
    //    Rich Text inspector values are not empty.
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange currentSelectedRange = selectionText.textView.selectedRange;
    NSTextStorage *textStorage = selectionText.textView.textStorage;
    if (currentSelectedRange.location == NSNotFound) return;
    if (currentSelectedRange.length == 0) {
        currentSelectedRange.length = 1;
    }
    if (currentSelectedRange.location == textStorage.string.length) {
        currentSelectedRange.location = textStorage.string.length - 1;
    }

    NSInteger selectionLength = currentSelectedRange.length;
    NSInteger selectionLocation = currentSelectedRange.location;
    
    // ensure that the selection range is within the TextView bounds to avoid crashing
    if (selectionLength + selectionLocation > textStorage.string.length || selectionLength + selectionLocation <= 0) return;
    
    NSMutableAttributedString *selectionStorage = [[textStorage attributedSubstringFromRange:currentSelectedRange] mutableCopy];
    NSFont* font  = [self getFontNameForSelection:selectionStorage len:selectionLength];
    NSNumber* underline = [self hasDualAttributeInSelectedRange:NSUnderlineStyleAttributeName attrString:selectionStorage len:selectionLength];
    BOOL dualBold = false;
    BOOL dualItalics = false;
    float fSize;
    [self hasDualBoldAndItalicTraitsInSelectedRange:&dualBold dualItalics:&dualItalics fontSize:&fSize attrString:selectionStorage len:selectionLength];
    BOOL boldValue = dualBold;
    BOOL italicsValue = dualItalics;
    NSParagraphStyle* paragraphStyle = [self hasDualAttributeInSelectedRange:NSParagraphStyleAttributeName attrString:selectionStorage len:selectionLength];
    NSColor *fontColor = [self hasDualAttributeInSelectedRange:NSForegroundColorAttributeName attrString:selectionStorage len:selectionLength];
    
    if (font) {
        [self.fontlistPopupButton selectItemWithTitle:font.familyName];
    }
    if (boldValue) {
        [self.boldButton setState:NSOnState];
    }else{
        [self.boldButton setState:NSOffState];
    }
    if (italicsValue) {
        [self.italicsButton setState:NSOnState];
    } else {
        [self.italicsButton setState:NSOffState];
    }
    if (underline) {
        [self.underlinedButton setState:NSOnState];
    }else{
        [self.underlinedButton setState:NSOffState];
    }
    
    if (fSize != -1) {
        [self.fontSizeField setStringValue:[NSString stringWithFormat:@"%f", fSize]];
    } else {
        [self.fontSizeField setStringValue:@""];
    }

    
    [self deselectAllAlignmentButtons];
    if (paragraphStyle) {
        switch (paragraphStyle.alignment) {
            case NSLeftTextAlignment:
                [self.leftAlignedButton setState:NSOnState];
                break;
            case NSRightTextAlignment:
                [self.rightAlignedButton setState:NSOnState];
                break;
            case NSCenterTextAlignment:
                [self.centerAlignedButton setState:NSOnState];
                break;
            case NSJustifiedTextAlignment:
                [self.justifiedAlignedButton setState:NSOnState];
                break;
            case NSNaturalTextAlignment:
                break;
        }
    }
    
    if (fontColor) {
        [self.textColorWell setColor:fontColor];
    } else {
        [self.textColorWell setColor:[NSColor blackColor]];
    }
}
-  (void)hasDualBoldAndItalicTraitsInSelectedRange:(BOOL*)dualBold dualItalics:(BOOL*)dualItalics fontSize:(GLfloat *)fontSize attrString:(NSAttributedString*)attrString len:(NSUInteger)len {
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSInteger splitCount = 0;
    NSInteger boldCount = 0;
    NSInteger ItalicsCount = 0;
    *fontSize = -1;
    
    *dualBold = false;
    *dualItalics = false;
    BOOL first = true;
    while (NSMaxRange(effectiveRange) < len) {
        NSFont* font = [attrString attribute:NSFontAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        NSFontDescriptor *fontDescriptor = font.fontDescriptor;
        NSFontSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;
        if (first) {
            *fontSize = [[fontDescriptor objectForKey:NSFontSizeAttribute] floatValue];
            first = false;
        } else {
            if(*fontSize != [[fontDescriptor objectForKey:NSFontSizeAttribute] floatValue]){
                *fontSize = -1;
            }
        }
        
        splitCount++;
        if(fontDescriptorSymbolicTraits & NSBoldFontMask){boldCount++;}
        if(fontDescriptorSymbolicTraits & NSItalicFontMask){ItalicsCount++;}
    }
    if(splitCount == boldCount && boldCount > 0){*dualBold = true;}
    if(splitCount == ItalicsCount && ItalicsCount > 0){*dualItalics = true;}
}

- (id) hasDualAttributeInSelectedRange:(NSString*)attribute attrString:(NSAttributedString*)attrString len:(NSUInteger)len{
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSInteger count = 0;
    id attributeValue;
    while (NSMaxRange(effectiveRange) < len) {
        attributeValue = [attrString attribute:attribute atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        count++;
    }
    if (count <= 1) {return attributeValue;}
    else{return NULL;}
}

- (NSFont*)getFontNameForSelection: (NSAttributedString*)attrString len:(NSUInteger)len{
    NSRange effectiveRange = NSMakeRange(0, 0);
    BOOL first= true;
    NSString* fontName = @"";
    NSFont* font;
    while (NSMaxRange(effectiveRange) < len) {
        font = [attrString attribute:NSFontAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if (first) {
            fontName = font.fontName;
            first = false;
        } else {
            if (fontName != font.fontName) {
                return NULL;
            }
        }
    }
    return font;
}

- (IBAction)boldButtonClicked:(id)sender {
    NSButton *button = (NSButton *)sender;
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange range = selectionText.textView.selectedRange;
    NSTextStorage* textStorage = selectionText.textView.textStorage;
    [textStorage addBoldToString:[button state] range:range];
}

- (IBAction)underlineButtonClicked:(id)sender {
    NSButton *button = (NSButton *)sender;
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange range = selectionText.textView.selectedRange;
    NSTextStorage* textStorage = selectionText.textView.textStorage;
    [textStorage addUnderlineForSubstring:[button state] :range];
}

- (IBAction)italicsButtonClicked:(id)sender {
    NSButton *button = (NSButton *)sender;
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange range = selectionText.textView.selectedRange;
    NSTextStorage* textStorage = selectionText.textView.textStorage;
    [textStorage addItalicsToString:[button state] range:range];
}

- (IBAction)alignmentButtonClicked:(id)sender {
    NSInteger buttonTag = [sender tag];
    [self deselectAllAlignmentButtons];
    switch (buttonTag) {
        case 0:
            [self.leftAlignedButton setState:1];
            break;
        case 1:
            [self.rightAlignedButton setState:1];
            break;
        case 2:
            [self.centerAlignedButton setState:1];
            break;
        case 3:
            [self.justifiedAlignedButton setState:1];
            break;
    }
    
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange range = selectionText.textView.selectedRange;
    if (range.length == 0) {
        NSString *viewContent = [selectionText.textView string];
        range = [viewContent lineRangeForRange:NSMakeRange(range.location,0)];
    }
    NSTextStorage* textStorage = selectionText.textView.textStorage;
    [textStorage addAlignment:buttonTag range:range];

}

- (void)deselectAllAlignmentButtons {
    [self.rightAlignedButton setState:0];
    [self.centerAlignedButton setState:0];
    [self.leftAlignedButton setState:0];
    [self.justifiedAlignedButton setState:0];
}

- (IBAction)fontSizeChanged:(id)sender {
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange currentSelectedRange = selectionText.textView.selectedRange;
    NSAttributedString* resultString = [self setFontSize:selectionText.textView.textStorage fontSize:[self.fontSizeField floatValue]];
    [selectionText.textView.textStorage replaceCharactersInRange:selectionText.textView.selectedRange withAttributedString:resultString];
    [selectionText.textView setSelectedRange:currentSelectedRange];
}

- (NSAttributedString*)setFontSize:(NSTextStorage*)textStorage fontSize:(GLfloat)fontSize{
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange currentSelectedRange = selectionText.textView.selectedRange;
    NSMutableAttributedString* selectionStorage = [[textStorage attributedSubstringFromRange:currentSelectedRange] mutableCopy];
    NSUInteger length = (NSUInteger)currentSelectedRange.length;
    
    NSRange effectiveRange = NSMakeRange(0, 0);
    
    while (NSMaxRange(effectiveRange) < length) {
        NSFont* font = [selectionStorage attribute:NSFontAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if(font){
            NSFontTraitMask mask = [[NSFontManager sharedFontManager] traitsOfFont:font];
            font = [[NSFontManager sharedFontManager] convertFont:font toSize:fontSize];
            
            [selectionStorage removeAttribute:NSFontAttributeName range:effectiveRange];
            [selectionStorage addAttribute:NSFontAttributeName value:font range:effectiveRange];
            [selectionStorage applyFontTraits:mask range:effectiveRange];
        }
    }
    return selectionStorage;
}

- (IBAction)setTextColor:(id)sender {
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange currentSelectedRange = selectionText.textView.selectedRange;

    [selectionText.textView.textStorage addColor:[self.textColorWell color] range:currentSelectedRange];
}

- (IBAction)setFont:(id)sender {
    NSPopUpButton *btn = (NSPopUpButton*)sender;
    NSString *fontName = btn.title;
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange currentSelectedRange = selectionText.textView.selectedRange;

    NSAttributedString* resultString = [self setFontName:selectionText.textView.textStorage fontSize:[self.fontSizeField floatValue] fontName:fontName];

    [selectionText.textView.textStorage replaceCharactersInRange:selectionText.textView.selectedRange withAttributedString:resultString];
    [selectionText.textView setSelectedRange:currentSelectedRange];
    
    //Adjust typing attributes so the textView can have font set without selected text
    NSMutableDictionary *dict = [selectionText.textView.typingAttributes mutableCopy];
    NSFont *font = [NSFont fontWithName:fontName size:[self.fontSizeField floatValue]];
    if (font) {
        dict[NSFontAttributeName] = font;
        [selectionText.textView setTypingAttributes:dict];
        [self.fontlistPopupButton selectItemWithTitle:fontName];
    }
}

- (NSAttributedString*)setFontName:(NSTextStorage*)textStorage fontSize:(GLfloat)fontSize fontName:(NSString *)fontName {
    PCSKTextView *selectionText = (PCSKTextView *)[self.selection.managedNodes firstObject];
    NSRange currentSelectedRange = selectionText.textView.selectedRange;
    NSMutableAttributedString* selectionStorage = [[textStorage attributedSubstringFromRange:currentSelectedRange] mutableCopy];
    NSUInteger length = (NSUInteger)currentSelectedRange.length;
    
    NSRange effectiveRange = NSMakeRange(0, 0);
    
    while (NSMaxRange(effectiveRange) < length) {
        NSFont* font = [selectionStorage attribute:NSFontAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        CGFloat fontSize = font.pointSize;
        NSFont *newFont = [NSFont fontWithName:fontName size:fontSize];
        if (font) {
            NSFontTraitMask mask = [[NSFontManager sharedFontManager] traitsOfFont:font];
            
            [selectionStorage removeAttribute:NSFontAttributeName range:effectiveRange];
            [selectionStorage addAttribute:NSFontAttributeName value:newFont range:effectiveRange];
            [selectionStorage applyFontTraits:mask range:effectiveRange];
        }
    }
    return selectionStorage;
}

- (PCSKTextView *)selectionTextView {
    return [self.selection.managedNodes firstObject];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
