//
//  PCKeyboardInputExpressionInspector.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-16.
//
//

#import <Cocoa/Cocoa.h>
#import "PCExpressionInspector.h"
#import "MASShortcut.h"

@interface PCKeyboardInputExpressionInspector : NSViewController <PCExpressionInspector>

@property (strong, nonatomic) NSNumber *keycode;
@property (strong, nonatomic) NSNumber *keycodeModifier;

- (NSString *)shortcutDescription;

@end
