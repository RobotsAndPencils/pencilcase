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

#import "InspectorPoint.h"
#import "PCTextFieldStepper.h"
#import "PCTextStepperProtocol.h"

@interface InspectorPoint () <PCTextStepperProtocol>

@property (weak, nonatomic) IBOutlet PCTextFieldStepper *xTextStepperField;
@property (weak, nonatomic) IBOutlet PCTextFieldStepper *yTextStepperField;

@property (weak, nonatomic) IBOutlet NSTextField *pointXTextfield;
@property (weak, nonatomic) IBOutlet NSTextField *pointYTextfield;


@end


@implementation InspectorPoint

- (void)setSelection:(PCNodeManager *)aSelection propertyName:(NSString *)aPropertyName setterName:(NSString *)aSetterName displayName:(NSString *)aDisplayName extra:(NSString *)anExtra placeholderKey:(NSString *)aPlaceholderKey {
    [super setSelection:aSelection propertyName:aPropertyName setterName:aSetterName displayName:aDisplayName extra:anExtra placeholderKey:aPlaceholderKey];
}

- (NSArray *)setupPropertyArrayForFontUpdating {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    return @[x, y];
}

- (void)updateFonts {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    [self setFontForControl:self.pointXTextfield property:x];
    [self setFontColorForTextfield:self.pointXTextfield property:x];
    [self setFontForControl:self.pointYTextfield property:y];
    [self setFontColorForTextfield:self.pointYTextfield property:y];
}

- (void) setPosX:(float)posX
{
    // TODO: Try/catch is quick fix for particle systems
    NSPoint pt = [[self propertyForSelection] pointValue];
    pt.x = posX;
    [self setPropertyForSelection:[NSValue valueWithPoint:pt]];
}

- (float) posX
{
    return [[self propertyForSelection] pointValue].x;
}

- (void) setPosY:(float)posY
{
	NSPoint pt = [[self propertyForSelection] pointValue];
    pt.y = posY;
    [self setPropertyForSelection:[NSValue valueWithPoint:pt]];
}

- (float) posY
{
    return [[self propertyForSelection] pointValue].y;
}

- (void) refresh
{
    [self willChangeValueForKey:@"posX"];
    [self didChangeValueForKey:@"posX"];
    
    [self willChangeValueForKey:@"posY"];
    [self didChangeValueForKey:@"posY"];
}

#pragma mark PCTextStepperProtocol

- (void)setStepAmount:(CGFloat)stepAmount {
    self.xTextStepperField.stepAmount = stepAmount;
    self.yTextStepperField.stepAmount = stepAmount;
}

@end
