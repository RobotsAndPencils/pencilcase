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

#import "InspectorValue.h"
#import "AppDelegate.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+Sequencer.h"
#import "PCDictionaryKeyValueStore.h"

NSString *const PCPropertyCategoryDefault = @"default";
NSString *const PCPropertyCategoryPhysics = @"physics";

@interface InspectorValue ()

@property (copy, nonatomic, readwrite) NSString *displayName;
@property (copy, nonatomic, readwrite) NSString *extra;

@property (strong, nonatomic, readwrite) IBOutlet NSView *view;

- (void)updateFontsWithNotification:(NSNotification *)notification;
- (IBAction)cannotClickMixedState:(id)sender;

@end

@implementation InspectorValue

+ (id)inspectorOfType:(NSString *)t withSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)setterName andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey
{
    NSString* inspectorClassName = [NSString stringWithFormat:@"Inspector%@",t];
    
    InspectorValue* inspector = [[NSClassFromString(inspectorClassName) alloc] initWithSelection:s andPropertyName:pn andSetterName:setterName andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    inspector.propertyType = t;
    return inspector;
}

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)sn andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey
{
    self = [super init];
    if (!self) return nil;
    
    [self setSelection:s propertyName:pn setterName:sn displayName:dn extra:e placeholderKey:placeholderKey];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFontsWithNotification:) name:MixedStateDidChangeNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelection:(PCNodeManager *)aSelection propertyName:(NSString *)aPropertyName setterName:(NSString *)aSetterName displayName:(NSString *)aDisplayName extra:(NSString *)anExtra placeholderKey:(NSString *)aPlaceholderKey {
    self.propertyName = aPropertyName;
    self.setterName = aSetterName;
    self.displayName = aDisplayName;
    self.selection = aSelection;
    self.extra = anExtra;
    self.placeholderKey = aPlaceholderKey;
    self.inspectorProperties = [self setupPropertyArrayForFontUpdating];
}

- (void)refresh
{
}

- (void)willBeAdded {
}

- (void)willBeRemoved
{
}

- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[];
}

- (void)updateFonts {
    
}

- (void)setFontColorForTextfield:(NSTextField *)textfield property:(NSString *)property {
    BOOL isMixed = [self.selection determineMixedStateForProperty:property];
    [textfield setTextColor:[[PCAppearanceManager sharedAppearanceManager] inspectorColorForMixedState:isMixed]];
}

- (void)setFontForControl:(NSControl *)control property:(NSString *)property {
    BOOL isMixed = [self.selection determineMixedStateForProperty:property];
    [control setFont:[[PCAppearanceManager sharedAppearanceManager] inspectorFontForMixedState:isMixed]];
}

- (void)setFontColorForText:(NSText *)text property:(NSString *)property {
    BOOL isMixed = [self.selection determineMixedStateForProperty:property];
    [text setTextColor:[[PCAppearanceManager sharedAppearanceManager] inspectorColorForMixedState:isMixed]];
}

- (void)setFontForText:(NSText *)text property:(NSString *)property {
    BOOL isMixed = [self.selection determineMixedStateForProperty:property];
    [text setFont:[[PCAppearanceManager sharedAppearanceManager] inspectorFontForMixedState:isMixed]];
}

- (void)updateAffectedProperties {
    if (self.affectsProperties) {
        for (int i = 0; i < [self.affectsProperties count]; i++) {
            [[AppDelegate appDelegate] refreshProperty:self.affectsProperties[i]];
        }
    }

    if (self.inPopoverWindow) {
        [[AppDelegate appDelegate] updateInspectorFromSelection];
    }
}

- (id)propertyForSelection
{
    return [self selectionPropertyWithName:self.propertyName];
}

- (id)selectionPropertyWithName:(NSString *)propName
{
    NodeInfo* nodeInfo = self.selection.userObject;
    PlugInNode* plugIn = nodeInfo.plugIn;
    
    if ([plugIn dontSetInEditorProperty:propName] ||
        [[self.selection extraPropForKey:@"customClass"] isEqualTo:propName])
    {
        return [nodeInfo.extraProps objectForKey:propName];
    }
    else
    {
        return [self.selection valueForKey:propName];
    }
}

- (void)updateAnimateablePropertyValue:(id)value {
    PCNodeManager *nodeManager = [AppDelegate appDelegate].nodeManager;
    for (SKNode *node in nodeManager.managedNodes) {
        [node updateAnimateablePropertyValue:value propName:self.propertyName];
    }
}

- (void)setPropertyForSelection:(id)value {
    [self setPropertyForSelection:value saveUndoState:YES];
}

- (void)setPropertyForSelection:(id)value saveUndoState:(BOOL)saveUndoState
{
    NodeInfo* nodeInfo = self.selection.userObject;
    PlugInNode* plugIn = nodeInfo.plugIn;
    if ([plugIn dontSetInEditorProperty:self.propertyName] || [[self.selection extraPropForKey:@"customClass"] isEqualTo:self.propertyName])
    {
        // Set the property in the extra props dict
        [self.selection setExtraProp:value forKey:self.setterName];
    }
    else
    {
        if ([self.selection conformsToProtocol:@protocol(PCDictionaryKeyValueStore)]) {
            id<PCDictionaryKeyValueStore> dictionaryKeyValueStore = (id<PCDictionaryKeyValueStore>)self.selection;
            [dictionaryKeyValueStore setValue:value forKey:self.setterName dictionaryKey:self.propertyName];
        } else {
            [self.selection setValue:value forKey:self.setterName];
        }
    }
    
    // Handle animatable properties
    [self updateAnimateablePropertyValue:value];
    
    // Update affected properties
    [self updateAffectedProperties];
    
    [self.selection setParameterKey:@"value"];
    if (saveUndoState) {
        [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
    }
}

- (id)eventPropertyValue {
    NSDictionary *eventProperty = [self propertyForSelection];
    if (!eventProperty) return nil;
    
    [self.selection setParameterKey:@"value"];

    return eventProperty[@"value"];
}

- (void)setEventPropertyValue:(id)value {
    NSMutableDictionary *eventProperty = [[self propertyForSelection] mutableCopy];
    if (!eventProperty) eventProperty = [NSMutableDictionary dictionary];
    
    [self.selection setParameterKey:@"value"];

    eventProperty[@"value"] = value;
    [self setPropertyForSelection:eventProperty];

    // Update affected properties
    [self updateAffectedProperties];
}

- (NSString *)eventPropertyGeneratorClassName {
    NSDictionary *eventProperty = [self propertyForSelection];
    if (!eventProperty) return @"";
    
    [self.selection setParameterKey:@"scriptGeneratorClass"];

    return eventProperty[@"scriptGeneratorClass"];
}

- (void)setEventPropertyGeneratorClassName:(NSString *)className {
    NSMutableDictionary *eventProperty = [[self propertyForSelection] mutableCopy];
    if (!eventProperty) eventProperty = [NSMutableDictionary dictionary];
    
    [self.selection setParameterKey:@"scriptGeneratorClass"];

    eventProperty[@"scriptGeneratorClass"] = className;
    [self setPropertyForSelection:eventProperty saveUndoState:NO];

    // Update affected properties
    [self updateAffectedProperties];
}

- (id)eventPropertyParameterNamed:(NSString *)parameterName {
    NSDictionary *eventProperty = [self propertyForSelection];
    if (!eventProperty) return nil;

    NSDictionary *parameters = eventProperty[@"parameters"];
    if (!parameters) return nil;
    
    [self.selection setParameterKey:parameterName];

    return parameters[parameterName];
}

- (void)setEventPropertyParameterNamed:(NSString *)parameterName value:(id)parameterValue {
    NSMutableDictionary *eventProperty = [[self propertyForSelection] mutableCopy];
    if (!eventProperty) eventProperty = [NSMutableDictionary dictionary];

    NSMutableDictionary *parameters = [eventProperty[@"parameters"] mutableCopy];
    if (!parameters) parameters = [NSMutableDictionary dictionary];
    
    [self.selection setParameterKey:parameterName];

    parameters[parameterName] = parameterValue;
    eventProperty[@"parameters"] = parameters;
    [self setPropertyForSelection:eventProperty];

    // Update affected properties
    [self updateAffectedProperties];
}

- (id)propertyForSelectionX
{
    return [self.selection valueForKey:[self.propertyName stringByAppendingString:@"X"]];
}

- (void)setPropertyForSelectionX:(id)value
{
    [self.selection setValue:value forKey:[self.propertyName stringByAppendingString:@"X"]];
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (id)propertyForSelectionY
{
    return [self.selection valueForKey:[self.propertyName stringByAppendingString:@"Y"]];
}

- (void)setPropertyForSelectionY:(id)value
{
    [self.selection setValue:value forKey:[self.propertyName stringByAppendingString:@"Y"]];
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (id)propertyForSelectionVar
{
    return [self.selection valueForKey:[self.propertyName stringByAppendingString:@"Range"]];
}

- (void)setPropertyForSelectionVar:(id)value
{
    [self.selection setValue:value forKey:[self.propertyName stringByAppendingString:@"Range"]];
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];    
}

- (void)updateFontsWithNotification:(NSNotification *)notification {
    NSDictionary *changeInfo = [notification userInfo];
    NSString *prop = changeInfo[@"prop"];
    
    if (![self.inspectorProperties containsObject:prop]) return;
    
    [self updateFonts];
}

- (IBAction)cannotClickMixedState:(id)sender {
    if ([sender isKindOfClass:[NSButton class]]) {
        NSButton *button = sender;
        if([button state] == NSMixedState){
            [button performClick:sender];
            return;
        }
    }
}



#pragma mark -
#pragma mark Disclosure

- (BOOL)isSeparator
{
    return NO;
}

#pragma mark Error handling for validation of text fields

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    NSTextField* tf = (NSTextField*)control;
    
    self.textFieldOriginalValue = [tf stringValue];
    
    return YES;
}

- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{
    NSBeep();
    
    NSTextField* tf = (NSTextField*)control;
    [tf setStringValue:self.textFieldOriginalValue];
    
    return YES;
}

@end
