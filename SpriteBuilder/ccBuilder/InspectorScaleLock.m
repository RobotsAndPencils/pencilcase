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

#import "InspectorScaleLock.h"
#import "AppDelegate.h"
#import "PositionPropertySetter.h"
#import "PCTextFieldStepper.h"
#import "PCTextStepperProtocol.h"
#import "SKNode+NodeInfo.h"

@interface InspectorScaleLock () <PCTextStepperProtocol>

@property (weak, nonatomic) IBOutlet PCTextFieldStepper *xTextFieldStepper;
@property (weak, nonatomic) IBOutlet PCTextFieldStepper *yTextFieldStepper;

@property (weak, nonatomic) IBOutlet NSTextField *scaleXTextfield;
@property (weak, nonatomic) IBOutlet NSTextField *scaleYTextfield;
@property (weak, nonatomic) IBOutlet NSButton *lockButton;

@end


@implementation InspectorScaleLock

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)setterName andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    self = [super initWithSelection:s andPropertyName:pn andSetterName:setterName andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mixedStateDidChange:) name:MixedStateDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)setupPropertyArrayForFontUpdating {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    return @[x, y];
}

- (void)mixedStateDidChange:(NSNotification *)notification {
    [self updateLock];
}

- (void)updateLock {
    self.lockButton.wantsLayer = YES;
    self.lockButton.layer.opacity = [self.selection determineMixedStateForProperty:@"scaleLock"] ? 0.5f : 1;
}

- (void)updateFonts {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    [self setFontForControl:self.scaleXTextfield property:x];
    [self setFontColorForTextfield:self.scaleXTextfield property:x];
    [self setFontForControl:self.scaleYTextfield property:y];
    [self setFontColorForTextfield:self.scaleYTextfield property:y];

    [self updateLock];
}

- (void) updateAnimateableX:(float)x Y:(float)y
{
    [self updateAnimateablePropertyValue:
     [NSArray arrayWithObjects:
      [NSNumber numberWithFloat:x],
      [NSNumber numberWithFloat:y],
      nil]];
}

- (void) setScaleX:(float)scaleX
{
    float scaleY = 0;
    
    if ([self locked])
    {
        scaleY = scaleX;
    }
    else
    {
        scaleY = [PositionPropertySetter scaleYForNode:self.selection prop:self.propertyName];
    }
    
    [self updateAnimateableX:scaleX Y:scaleY];
    [PositionPropertySetter setScaledX:scaleX Y:scaleY forSpriteKitNode:self.selection prop:self.propertyName];
    
    [self refresh];
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (float) scaleX
{
    return [PositionPropertySetter scaleXForNode:self.selection prop:self.propertyName];
}

- (void) setScaleY:(float)scaleY
{
    float scaleX = 0;
    
    if ([self locked])
    {
        scaleX = scaleY;
    }
    else
    {
        scaleX = [PositionPropertySetter scaleXForNode:self.selection prop:self.propertyName];
    }
    
    [self updateAnimateableX:scaleX Y:scaleY];
    [PositionPropertySetter setScaledX:scaleX Y:scaleY forSpriteKitNode:self.selection prop:self.propertyName];
    
    [self refresh];
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (float) scaleY
{
    return [PositionPropertySetter scaleYForNode:self.selection prop:self.propertyName];
}

- (BOOL) locked
{
    return [[self.selection extraPropForKey:[self.propertyName stringByAppendingString:@"Lock"]] boolValue];
}

- (void) setLocked:(BOOL)locked
{
    [self.selection setExtraProp:[NSNumber numberWithBool:locked] forKey:[self.propertyName stringByAppendingString:@"Lock"]];
    
    if (locked && [self scaleX] != [self scaleY])
    {
        [self setScaleY:[self scaleX]];
    }
    
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (void) refresh
{
    [self willChangeValueForKey:@"locked"];
    [self didChangeValueForKey:@"locked"];

    [self willChangeValueForKey:@"scaleX"];
    [self didChangeValueForKey:@"scaleX"];
    
    [self willChangeValueForKey:@"scaleY"];
    [self didChangeValueForKey:@"scaleY"];
}

#pragma mark PCTextStepperProtocol

- (void)setStepAmount:(CGFloat)stepAmount {
    self.xTextFieldStepper.stepAmount = stepAmount;
    self.yTextFieldStepper.stepAmount = stepAmount;
}

@end
