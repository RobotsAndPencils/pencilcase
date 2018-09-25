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

#import "InspectorFloatXY.h"

@interface InspectorFloatXY ()

@property (weak, nonatomic) IBOutlet NSTextField *floatXTextfield;
@property (weak, nonatomic) IBOutlet NSTextField *floatYTextfield;

@end

@implementation InspectorFloatXY

- (NSArray *)setupPropertyArrayForFontUpdating {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    return @[x, y];
}

- (void)updateFonts {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    [self setFontForControl:self.floatXTextfield property:x];
    [self setFontColorForTextfield:self.floatXTextfield property:x];
    [self setFontForControl:self.floatYTextfield property:y];
    [self setFontColorForTextfield:self.floatYTextfield property:y];
}
- (void) updateAnimateableX:(float)x Y:(float)y
{
    [self updateAnimateablePropertyValue:
     [NSArray arrayWithObjects:
      [NSNumber numberWithFloat:x],
      [NSNumber numberWithFloat:y],
      nil]];
}

- (void) setScaleX:(float)x
{
    [self setPropertyForSelectionX:[NSNumber numberWithFloat:x]];
    [self updateAnimateableX:x Y:self.scaleY];
}

- (float) scaleX
{
    return [[self propertyForSelectionX] floatValue];
}

- (void) setScaleY:(float)y
{
    [self setPropertyForSelectionY:[NSNumber numberWithFloat:y]];
    [self updateAnimateableX:self.scaleX Y:y];
}

- (float) scaleY
{
    return [[self propertyForSelectionY] floatValue];
}

- (void) refresh
{
    [self willChangeValueForKey:@"scaleX"];
    [self didChangeValueForKey:@"scaleX"];
    
    [self willChangeValueForKey:@"scaleY"];
    [self didChangeValueForKey:@"scaleY"];
}

@end
