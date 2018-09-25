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

#import "InspectorSize.h"
#import "PositionPropertySetter.h"
#import "AppDelegate.h"
#import "PCStageScene.h"
#import "SKNode+EditorResizing.h"

@interface InspectorSize ()

@property (weak, nonatomic) IBOutlet NSTextField *widthTextfield;
@property (weak, nonatomic) IBOutlet NSTextField *heightTextfield;

@end

@implementation InspectorSize

- (NSArray *)setupPropertyArrayForFontUpdating {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    return @[x, y];
}

- (void)updateFonts {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    [self setFontForControl:self.widthTextfield property:x];
    [self setFontColorForTextfield:self.widthTextfield property:x];
    [self setFontForControl:self.heightTextfield property:y];
    [self setFontColorForTextfield:self.heightTextfield property:y];
}

- (void) setWidth:(float)width
{
    NSSize size = [[self.selection valueForKey:self.propertyName] sizeValue];
    size.width = width;
    [self.selection beginResizing];
    [self.selection setValue:[NSValue valueWithSize:size] forKey:self.setterName];
    [self.selection finishResizing];
    [self updateStageIfNecessary];
    
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (float) width
{
    float width = [[self.selection valueForKey:self.propertyName] sizeValue].width;
    return width;
}

- (void) setHeight:(float)height
{
    NSSize size = [[self.selection valueForKey:self.propertyName] sizeValue];
    size.height = height;
    [self.selection beginResizing];
    [self.selection setValue:[NSValue valueWithSize:size] forKey:self.setterName];
    [self.selection finishResizing];
    [self updateStageIfNecessary];
    
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (void)updateStageIfNecessary {
    if (self.selection == [PCStageScene scene].rootNode) {
        [[PCStageScene scene] fitStageToRootNodeIfNecessary];
    }
}

- (float) height
{
    float height = [[self.selection valueForKey:self.propertyName] sizeValue].height;
    return height;
}

- (void) refresh
{
    [self willChangeValueForKey:@"width"];
    [self didChangeValueForKey:@"width"];
    
    [self willChangeValueForKey:@"height"];
    [self didChangeValueForKey:@"height"];
    
    [self willChangeValueForKey:@"widthUnit"];
    [self didChangeValueForKey:@"widthUnit"];
    
    [self willChangeValueForKey:@"heightUnit"];
    [self didChangeValueForKey:@"heightUnit"];
}

@end
