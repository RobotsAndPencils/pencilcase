//
//  InspectorStringSimple.m
//  SpriteBuilder
//
//  Created by John Twigg on 2013-12-18.
//
//

#import "InspectorStringSimple.h"
#import "StringPropertySetter.h"
#import "AppDelegate.h"

@interface InspectorStringSimple ()

@property (weak, nonatomic) IBOutlet NSTextField *textField;

@end

@implementation InspectorStringSimple

- (void) willBeAdded {
    if (!self.placeholderKey || ![self.selection respondsToSelector:NSSelectorFromString(self.placeholderKey)]) return;

    id placeholderValue = [self.selection valueForKey:self.placeholderKey];
    if (placeholderValue) {
        [self.textField unbind:@"value"];
        [self.textField bind:@"value" toObject:self.selection withKeyPath:self.propertyName options:@{ NSNullPlaceholderBindingOption : placeholderValue }];
    }
    
    [self refresh];
}

- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[self.propertyName];
}

- (void)updateFonts {
    [self setFontForControl:self.textField property:self.propertyName];
    [self setFontColorForTextfield:self.textField property:self.propertyName];
}

- (void)refresh {
    self.textField.stringValue = [StringPropertySetter stringForNode:self.selection andProp:self.propertyName];
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    [self setPropertyForSelection:self.textField.stringValue];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
    return YES;
}

@end
