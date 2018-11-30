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

#import "InspectorIntegerLabeled.h"

@interface InspectorIntegerLabeled()

@property (weak, nonatomic) IBOutlet NSPopUpButton *popup;
@property (weak, nonatomic) IBOutlet NSMenu *menu;

@end

@implementation InspectorIntegerLabeled

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)sn andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    self = [super initWithSelection:s andPropertyName:pn andSetterName:sn                                                                                                                                                   andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    if (!self) return NULL;
    
    return self;
}



- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[self.propertyName];
}

- (void)updateFonts {
    [self setFontForControl:self.popup property:self.propertyName];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadMenuFromSelection];
}

- (void)refresh {
    [self loadMenuFromSelection];
}

- (void)loadMenuFromSelection {
    [self.menu removeAllItems];
    
    NSArray *stringComponents = [self.extra componentsSeparatedByString:@"|"];

    for (NSUInteger componentIndex = 0; componentIndex < stringComponents.count - 1; componentIndex += 2) {
        NSString *title = stringComponents[componentIndex];
        NSInteger tag = [stringComponents[componentIndex + 1] integerValue];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
        [item setTag:tag];
        
        [self.menu addItem:item];
    }
    
    [self.popup selectItemWithTag:[[self propertyForSelection] intValue]];
}

- (void) setSelectedTag:(int)selectedTag
{
    
    [self setPropertyForSelection:[NSNumber numberWithInt:selectedTag]];
}

- (int) selectedTag
{
    int st = [[self propertyForSelection] intValue];
    return st;
}

- (IBAction)selectPopUpButton:(id)sender {
    [self setSelectedTag:[[sender selectedItem] tag]];
}

@end
