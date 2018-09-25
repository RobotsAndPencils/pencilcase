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

#import "InspectorPosition.h"
#import "PositionPropertySetter.h"
#import "AppDelegate.h"
#import "SKNode+NodeInfo.h"
#import "SequencerKeyframe.h"
#import "SKNode+Sequencer.h"

@interface InspectorPosition()

@property (weak, nonatomic) IBOutlet NSTextField *positionXTextfield;
@property (weak, nonatomic) IBOutlet NSTextField *positionYTextfield;

@end

@implementation InspectorPosition

- (NSArray *)setupPropertyArrayForFontUpdating {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    return @[x, y];
}

- (void)updateFonts {
    NSString *x = [self.propertyName stringByAppendingString:@"X"];
    NSString *y = [self.propertyName stringByAppendingString:@"Y"];
    [self setFontForControl:self.positionXTextfield property:x];
    [self setFontColorForTextfield:self.positionXTextfield property:x];
    [self setFontForControl:self.positionYTextfield property:y];
    [self setFontColorForTextfield:self.positionYTextfield property:y];
}


- (void)setPosX:(CGFloat)posX {
    NSPoint pt = [[self.selection valueForKey:self.propertyName] pointValue];
    pt.x = posX;
    [self.selection setValue:[NSValue valueWithPoint:pt] forKey:self.setterName];

    NSArray *animValue = @[ @(pt.x), @(pt.y) ];
    [self updateAnimateablePropertyValue:animValue];

    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (CGFloat)posX {
    CGFloat posX = [[self.selection valueForKey:self.propertyName] pointValue].x;
    return posX;
}

- (void)setPosY:(CGFloat)posY {
    NSPoint pt = [[self.selection valueForKey:self.propertyName] pointValue];
    pt.y = posY;
    [self.selection setValue:[NSValue valueWithPoint:pt] forKey:self.setterName];

    NSArray *animValue = @[ @(pt.x), @(pt.y) ];
    [self updateAnimateablePropertyValue:animValue];

    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (CGFloat)posY {
    CGFloat posY = [[self.selection valueForKey:self.propertyName] pointValue].y;
    return posY;
}

- (void)refresh {
    [self willChangeValueForKey:@"posX"];
    [self didChangeValueForKey:@"posX"];

    [self willChangeValueForKey:@"posY"];
    [self didChangeValueForKey:@"posY"];

    [self willChangeValueForKey:@"positionUnitX"];
    [self didChangeValueForKey:@"positionUnitX"];

    [self willChangeValueForKey:@"positionUnitY"];
    [self didChangeValueForKey:@"positionUnitY"];

    [self willChangeValueForKey:@"referenceCorner"];
    [self didChangeValueForKey:@"referenceCorner"];
}

@end
