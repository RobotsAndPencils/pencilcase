//
//  PCKeyboardInputExpressionInspector.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-16.
//
//

#import "PCKeyboardInputExpressionInspector.h"
#import "MASShortcutView.h"

@interface PCKeyboardInputExpressionInspector() <MASShortcutViewProtocol>

@property (weak, nonatomic) IBOutlet MASShortcutView *keyPressedShortcutField;

@end

@implementation PCKeyboardInputExpressionInspector

@synthesize saveHandler = _saveHandler;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyPressedShortcutField.delegate = self;
    [self setupMenu];
}

- (void)setupMenu {
    if (!self.keycode) return;

    self.keyPressedShortcutField.shortcutValue = [[MASShortcut alloc] initWithKeyCode:self.keycode.integerValue modifierFlags:self.keycodeModifier.integerValue];
}

#pragma mark - MASShorcutViewProtocol implementation

- (void)shortcutKeyDidChange:(MASShortcut *)shortcut {
    self.keycode = @(self.keyPressedShortcutField.shortcutValue.keyCode);
    self.keycodeModifier = @(self.keyPressedShortcutField.shortcutValue.modifierFlags);
}

#pragma mark - Public

- (NSString *)shortcutDescription {
    return self.keyPressedShortcutField.shortcutValue.description;
}

#pragma mark - PCExpressionInspector implementation

- (NSView *)initialFirstResponder {
    return self.keyPressedShortcutField;
}

@end
