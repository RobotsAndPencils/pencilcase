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

#import "InspectorColor4FVar.h"

@implementation InspectorColor4FVar

- (void) setColor:(NSColor *)color
{
    CGFloat r, g, b, a;
    
    color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    [self setPropertyForSelection:color];
    
    if ([self.selection determineMixedStateForProperty:self.propertyName]) [self.mixedStateImage setHidden:NO];
    else [self.mixedStateImage setHidden:YES];
    
}

- (NSColor*) color
{
	NSColor* colorValue = [self propertyForSelection];
    NSColor * calibratedColor = [colorValue colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    
    if ([self.selection determineMixedStateForProperty:self.propertyName]) [self.mixedStateImage setHidden:NO];
    else [self.mixedStateImage setHidden:YES];
    
    return calibratedColor;
}

- (void) setColorVar:(NSColor *)color
{
    CGFloat r, g, b, a;
    
    color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    [self setPropertyForSelectionVar:color];
    
    if ([self.selection determineMixedStateForProperty:[self.propertyName stringByAppendingString:@"Range"]]) [self.mixedStateImageVar setHidden:NO];
    else [self.mixedStateImageVar setHidden:YES];
    
}

- (NSColor*) colorVar
{
	NSColor* colorValue = [self propertyForSelectionVar];
    NSColor * calibratedColor = [colorValue colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    
    if ([self.selection determineMixedStateForProperty:[self.propertyName stringByAppendingString:@"Range"]]) [self.mixedStateImageVar setHidden:NO];
    else [self.mixedStateImageVar setHidden:YES];
    
    return calibratedColor;
}

@end
