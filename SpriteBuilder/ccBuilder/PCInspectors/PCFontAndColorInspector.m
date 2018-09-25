//
//  PCColorInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-14.
//
//

#import "PCFontAndColorInspector.h"
#import "BFPopoverColorWell.h"
#import "ResourceManagerUtil.h"

typedef NS_ENUM(NSInteger, PCFontAndColorIndex) {
    PCFontAndColorIndexFont,
    PCFontAndColorIndexColor,
};

@interface PCFontAndColorInspector ()

@property (weak, nonatomic) IBOutlet NSTextField *fontSizeTextField;
@property (weak, nonatomic) IBOutlet NSPopUpButton *fontNameButton;
@property (weak, nonatomic) IBOutlet BFPopoverColorWell *colorWell;
@property (weak, nonatomic) IBOutlet NSMenu *fontMenu;

@property (strong, nonatomic) NSString *fontName;
@property (assign, nonatomic) NSInteger fontSize;
@property (strong, nonatomic) NSColor *fontColor;

@end

@implementation PCFontAndColorInspector

- (void)awakeFromNib {
    [super awakeFromNib];
    [ResourceManagerUtil populatePopupButtonWithFonts:self.fontNameButton selectedFontName:nil target:self action:@selector(setFontNameWithMenuItem:)];
}

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index {
    if (index == PCFontAndColorIndexFont) {
        NSFont *font = [NSFont fontWithName:[(NSFont *)value fontName] size:[(NSFont *)value pointSize]];
        self.fontName = font.displayName  ?: @"Helvetica";
        self.fontSize = font.pointSize ?: 17;
    }
    else if (index == PCFontAndColorIndexColor) {
        self.fontColor = value ?: [NSColor blackColor];
    }
}

#pragma mark - Properties

- (void)setFontName:(NSString *)fontName {
    if (_fontName != fontName) {
        _fontName = fontName;
        [self dispatchFontChanged];
    }
}

- (void)setFontNameWithMenuItem:(NSMenuItem *)menuItem {
    NSString *fontName = menuItem.representedObject;
    self.fontName = fontName;
}

- (void)setFontSize:(NSInteger)fontSize {
    if (_fontSize != fontSize) {
        _fontSize = fontSize;
        self.fontSizeTextField.stringValue = [@(fontSize) stringValue];
        [self dispatchFontChanged];
    }
}

- (void)setFontColor:(NSColor *)fontColor {
    if (fontColor == _fontColor) return;
    _fontColor = fontColor;
    [self dispatchColorChanged];
}

#pragma mark Delegate Dispatch

- (id)fontValue {
    return [NSFont fontWithName:self.fontName size:self.fontSize];
}

- (void)dispatchFontChanged {
    [self.delegate inspector:self valueChanged:[self fontValue] forValueInfoAtIndex:PCFontAndColorIndexFont];
}

- (void)dispatchColorChanged {
    [self.delegate inspector:self valueChanged:self.fontColor forValueInfoAtIndex:PCFontAndColorIndexColor];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification {
    self.fontSize = [notification.object integerValue];
}

@end
