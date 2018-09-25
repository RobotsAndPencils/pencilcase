//
//  MASShortcutViewProtocol.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-09-08.
//
//
#import "MASShortcut.h"

@protocol MASShortcutViewProtocol <NSObject>

- (void)shortcutKeyDidChange:(MASShortcut *)shortcut;

@end