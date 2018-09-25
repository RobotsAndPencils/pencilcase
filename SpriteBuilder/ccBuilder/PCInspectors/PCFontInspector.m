//
//  PCColorInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-14.
//
//

#import "PCFontInspector.h"
#import "ResourceManagerUtil.h"

@interface PCFontInspector ()

@property (weak, nonatomic) IBOutlet NSTextField *fontSizeTextField;
@property (weak, nonatomic) IBOutlet NSPopUpButton *fontNameButton;
@property (weak, nonatomic) IBOutlet NSMenu *fontMenu;

@property (strong, nonatomic) NSString *fontName;
@property (assign, nonatomic) NSInteger fontSize;

@end

@implementation PCFontInspector

- (void)awakeFromNib {
    [super awakeFromNib];
    [ResourceManagerUtil populatePopupButtonWithFonts:self.fontNameButton selectedFontName:nil target:self action:@selector(setFontNameWithMenuItem:)];
}

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index {
    NSFont *font = [NSFont fontWithName:[(NSFont *)value fontName] size:[(NSFont *)value pointSize]];
    self.fontName = font.displayName  ?: @"Helvetica";
    self.fontSize = font.pointSize ?: 17;
}

#pragma mark - Private

- (id)value {
    return [NSFont fontWithName:self.fontName size:self.fontSize];
}

#pragma mark - Properties

- (void)setFontName:(NSString *)fontName {
    if (_fontName != fontName) {
        _fontName = fontName;
        [self dispatchValueChange];
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
        [self dispatchValueChange];
    }
}

- (void)dispatchValueChange {
    [self.delegate inspector:self valueChanged:[self value] forValueInfoAtIndex:0];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification {
    self.fontSize = [notification.object integerValue];
}

@end
