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

#import "InspectorText.h"
#import "StringPropertySetter.h"
#import "AppDelegate.h"
#import "LocalizationEditorHandler.h"

@interface InspectorText ()

@property (strong, nonatomic) IBOutlet NSTextView *textView;

@end

@implementation InspectorText

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)sn andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    self = [super initWithSelection:s andPropertyName:pn andSetterName:sn andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    
    if ([[[AppDelegate appDelegate] selectedSpriteKitNodes] count] > 1) self.localizeIsEnabled = NO;
    else self.localizeIsEnabled = YES;
    
    return self;
}

- (void)willBeAdded {
    [super willBeAdded];
    NSDictionary *options = @{
                              NSContinuouslyUpdatesValueBindingOption: @YES,
                              };
    [self.textView bind:@"attributedString" toObject:self withKeyPath:@"text" options:options];
}

- (void)willBeRemoved {
    [super willBeRemoved];
    [self.textView unbind:@"attributedString"];
}

- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[self.propertyName];
}

- (void)updateFonts {
    [self setFontForText:self.textView property:self.propertyName];
    [self setFontColorForText:self.textView property:self.propertyName];
}

- (void)setText:(NSAttributedString *)text {

    NSString* str = [text string];
    if (!str) str = @"";
    
    [StringPropertySetter setString:str forNode:self.selection andProp:self.propertyName];
    
    [self updateAffectedProperties];
    
    [self willChangeValueForKey:@"hasTranslation"];
    [self didChangeValueForKey:@"hasTranslation"];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (NSAttributedString*) text {
    NSString* str = [StringPropertySetter stringForNode:self.selection andProp:self.propertyName];
    
    BOOL mixedState = [self.selection determineMixedStateForProperty:self.propertyName];
    NSFont *attributedStringFont = [[PCAppearanceManager sharedAppearanceManager] inspectorFontForMixedState:mixedState];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObject:attributedStringFont forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:str attributes:attributesDictionary];
    
    return attributedText;
}

- (void)controlTextDidChange:(NSNotification *)note {
    NSTextField * changedField = [note object];
    [self setText:[changedField attributedStringValue]];
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
    [handler createOrEditTranslationForKey:[[self text] string]];
}

@end
