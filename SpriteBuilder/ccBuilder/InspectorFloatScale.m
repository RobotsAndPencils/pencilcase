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

#import "InspectorFloatScale.h"
#import "PositionPropertySetter.h"
#import "AppDelegate.h"

@interface InspectorFloatScale ()

@property (weak, nonatomic) IBOutlet NSTextField *scaleTextField;

@end

@implementation InspectorFloatScale

- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[self.propertyName];
}

- (void)updateFonts {
    [self setFontForControl:self.scaleTextField property:self.propertyName];
    [self setFontColorForTextfield:self.scaleTextField property:self.propertyName];
}


- (void) setF:(float)f
{
    [PositionPropertySetter setFloatScale:f forNode:self.selection prop:self.propertyName];
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (float) f
{
    return [PositionPropertySetter floatScaleForNode:self.selection prop:self.propertyName];
}

- (void) setType:(int)type
{
    [PositionPropertySetter setFloatScale:[PositionPropertySetter floatScaleForNode:self.selection prop:self.propertyName] forNode:self.selection prop:self.propertyName];
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];    
}

- (void) refresh
{
    [self willChangeValueForKey:@"f"];
    [self didChangeValueForKey:@"f"];
}

@end
