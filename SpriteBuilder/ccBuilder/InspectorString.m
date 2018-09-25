/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "InspectorString.h"
#import "StringPropertySetter.h"
#import "AppDelegate.h"
#import "LocalizationEditorHandler.h"

@interface InspectorString ()

@property (weak, nonatomic) IBOutlet NSTextField *textField;

@end

@implementation InspectorString

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)sn andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    self = [super initWithSelection:s andPropertyName:pn andSetterName:sn andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    
    if ([[[AppDelegate appDelegate] selectedSpriteKitNodes] count] > 1) self.localizeIsEnabled = NO;
    else self.localizeIsEnabled = YES;
    
    return self;
}

- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[self.propertyName];
}

- (void)updateFonts {
    [self setFontForControl:self.textField property:self.propertyName];
    [self setFontColorForTextfield:self.textField property:self.propertyName];
}

- (void) setText:(NSString *)text {

    NSString* str = text;
    if (!str) str = @"";
    
    [StringPropertySetter setString:str forNode:self.selection andProp:self.propertyName];
    
    [self updateAffectedProperties];
    
    [self willChangeValueForKey:@"hasTranslation"];
    [self didChangeValueForKey:@"hasTranslation"];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
    
}

- (NSString*) text {
    return [StringPropertySetter stringForNode:self.selection andProp:self.propertyName];
}

- (void)controlTextDidChange:(NSNotification *)note {
    NSTextField * changedField = [note object];
    NSString* text = [changedField stringValue];
    [self setText:text];
}

- (void)setLocalize:(NSInteger)localize {
    [StringPropertySetter setLocalized:localize forNode:self.selection andProp:self.propertyName];
    
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (NSInteger)localize {
    return [StringPropertySetter isLocalizedNode:self.selection andProp:self.propertyName];
}

- (BOOL)hasTranslation {
    return [StringPropertySetter hasTranslationForNode:self.selection andProp:self.propertyName];
}

- (void)refresh {
    [self willChangeValueForKey:@"text"];
    [self willChangeValueForKey:@"localize"];
    [self willChangeValueForKey:@"hasTranslation"];
    
    [self didChangeValueForKey:@"text"];
    [self didChangeValueForKey:@"localize"];
    [self didChangeValueForKey:@"hasTranslation"];

    [self.selection willChangeValueForKey:self.propertyName];
    [self.selection didChangeValueForKey:self.propertyName];
}

- (IBAction)pressedEditTranslation:(id)sender {
    LocalizationEditorHandler* handler = [AppDelegate appDelegate].localizationEditorHandler;
    [handler openEditor:sender];
    [handler createOrEditTranslationForKey:[self text]];
}

@end
