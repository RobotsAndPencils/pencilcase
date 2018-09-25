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

#import "InspectorBlock.h"
#import "SKNode+NodeInfo.h"
#import "AppDelegate.h"

@interface InspectorBlock ()

@property (weak, nonatomic) IBOutlet NSPopUpButton *popUpButton;
@property (weak, nonatomic) IBOutlet NSTextField *textField;

@end

@implementation InspectorBlock

@dynamic selector;

- (NSArray *)setupPropertyArrayForFontUpdating {
    NSString *targetName = [self.propertyName stringByAppendingString:@"Target"];
    return @[self.propertyName, targetName];
}

- (void)updateFonts {
    NSString *targetName = [self.propertyName stringByAppendingString:@"Target"];
    [self setFontForControl:self.popUpButton property:targetName];
    [self setFontForControl:self.textField property:self.propertyName];
    [self setFontColorForTextfield:self.textField property:self.propertyName];
}

- (void)setSelector:(NSString *)selector {
    if (!selector) selector = @"";
    [self.selection setExtraProp:selector forKey:self.propertyName];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"selector"];    
}

- (NSString*)selector {
    NSString* sel = [self.selection extraPropForKey:self.propertyName];
    if (!sel) sel = @"";
    return sel;
}

- (void)setTarget:(int)target {
    NSString *targetPropertyName = [NSString stringWithFormat:@"%@Target", self.propertyName];
    [self.selection setExtraProp:[NSNumber numberWithInt:target] forKey:targetPropertyName];
}

- (int)target {
    NSString *targetPropertyName = [NSString stringWithFormat:@"%@Target", self.propertyName];
    int target = [[self.selection extraPropForKey:targetPropertyName] intValue];
    
    return target;
}

- (IBAction)selectPopUpButton:(id)sender {
    [self setTarget:[[sender selectedItem] tag]];
}

@end
