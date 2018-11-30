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

#import "InspectorFloatVar.h"

@interface InspectorFloatVar ()

@property (weak, nonatomic) IBOutlet NSTextField *floatTextfield;
@property (weak, nonatomic) IBOutlet NSTextField *varTextfield;

@end

@implementation InspectorFloatVar

- (NSArray *)setupPropertyArrayForFontUpdating {
    NSString *var = [self.propertyName stringByAppendingString:@"Range"];
    return @[self.propertyName, var];
}

- (void)updateFonts {
    NSString *var = [self.propertyName stringByAppendingString:@"Range"];
    [self setFontForControl:self.floatTextfield property:self.propertyName];
    [self setFontColorForTextfield:self.floatTextfield property:self.propertyName];
    [self setFontForControl:self.varTextfield property:var];
    [self setFontColorForTextfield:self.varTextfield property:var];
}

- (void) setF:(float)f
{
    [self setPropertyForSelection:[NSNumber numberWithFloat:f]];
}

- (float) f
{
    return [[self propertyForSelection] floatValue];
}

- (void) setFVar:(float)fVar
{
    [self setPropertyForSelectionVar:[NSNumber numberWithFloat:fVar]];
}

- (float) fVar
{
    return [[self propertyForSelectionVar] floatValue];
}

@end
