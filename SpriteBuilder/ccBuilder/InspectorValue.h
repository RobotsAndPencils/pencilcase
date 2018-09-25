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

#import <Foundation/Foundation.h>
#import "PCNodeManager.h"
#import "PCAppearanceManager.h"

extern NSString *const PCPropertyCategoryDefault;
extern NSString *const PCPropertyCategoryPhysics;

@interface InspectorValue : NSObject <NSControlTextEditingDelegate>

@property (copy, nonatomic) NSString *propertyName;
@property (copy, nonatomic) NSString *propertyCategory;
@property (copy, nonatomic) NSString *setterName;
@property (copy, nonatomic) NSString *propertyType;
@property (copy, nonatomic) NSString *placeholderKey;
@property (strong, nonatomic) NSString *textFieldOriginalValue;
@property (copy, nonatomic, readonly) NSString *extra;
@property (copy, nonatomic, readonly) NSString *displayName;

@property (strong, nonatomic) PCNodeManager *selection;
@property (strong, nonatomic) NSArray *inspectorProperties;
@property (strong, nonatomic) NSArray *affectsProperties;
@property (strong, nonatomic) InspectorValue *inspectorValueBelow;
@property (strong, nonatomic, readonly) NSView *view;

@property (assign, nonatomic) BOOL inPopoverWindow;
@property (assign, nonatomic) BOOL readOnly;



+ (id)inspectorOfType:(NSString *)t withSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)setterName andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey;

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)setterName andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey;

- (void)setSelection:(PCNodeManager *)aSelection propertyName:(NSString *)aPropertyName setterName:(NSString *)aSetterName displayName:(NSString *)aDisplayName extra:(NSString *)anExtra placeholderKey:(NSString *)aPlaceholderKey;

- (void)refresh;

- (void)willBeAdded;
- (void)willBeRemoved;

- (NSArray *)setupPropertyArrayForFontUpdating;
- (void)updateFonts;
- (void)setFontColorForTextfield:(NSTextField *)textfield property:(NSString *)property;
- (void)setFontForControl:(NSControl *)control property:(NSString *)property;
- (void)setFontColorForText:(NSText *)text property:(NSString *)property;
- (void)setFontForText:(NSText *)text property:(NSString *)property;

- (void)updateAffectedProperties;

- (id)propertyForSelection;
- (id)selectionPropertyWithName:(NSString *)propName;
- (void)updateAnimateablePropertyValue:(id)value;
- (void)setPropertyForSelection:(id)value;

- (id)eventPropertyValue;
- (void)setEventPropertyValue:(id)value;

- (NSString *)eventPropertyGeneratorClassName;
- (void)setEventPropertyGeneratorClassName:(NSString *)className;

- (id)eventPropertyParameterNamed:(NSString *)parameterName;
- (void)setEventPropertyParameterNamed:(NSString *)parameterName value:(id)parameterValue;

- (id)propertyForSelectionX;
- (void)setPropertyForSelectionX:(id)value;

- (id)propertyForSelectionY;
- (void)setPropertyForSelectionY:(id)value;

- (id)propertyForSelectionVar;
- (void)setPropertyForSelectionVar:(id)value;

- (BOOL)isSeparator;

@end
