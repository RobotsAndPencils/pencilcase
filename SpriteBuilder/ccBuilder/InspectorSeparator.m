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

#import "InspectorSeparator.h"
#import "AppDelegate.h"

@implementation InspectorSeparator

- (BOOL)isExpanded
{
    if (![self propertyForSelection]) {
        return YES;
    }
    
    return [[self propertyForSelection] intValue] == NSOnState;
}

- (void)setIsExpanded:(BOOL)isExpanded
{
    // Finish editing
    if (![[self.view window] makeFirstResponder:[self.view window]])
    {
        return;
    }
    
    /*
    if (isExpanded) {
        [self.inspectorValueBelow showAllToNextSeparatorWithAbove:self];
    }
    else {
        [self.inspectorValueBelow hideAllToNextSeparatorWithAboveSeparator:self];
    }
    
    [self setSuperviewFrameHeight];*/
    
    [self setPropertyForSelection:[NSNumber numberWithInt:_disclosureButton.state]];
    
    [[AppDelegate appDelegate] updateInspectorFromSelection];
}

/*
- (void)showAllToNextSeparatorWithAbove:(InspectorValue*)above
{
    [self moveToMeetAbove:above];
}

- (void)hideAllToNextSeparatorWithAboveSeparator:(InspectorValue*)aboveSeparator
{
    [self moveToMeetAbove:aboveSeparator];
}
*/
- (BOOL)isSeparator
{
    return YES;
}

@end
