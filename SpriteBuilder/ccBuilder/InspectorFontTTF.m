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

#import "InspectorFontTTF.h"
#import "ResourcePropertySetter.h"
#import "PCResourceManager.h"
#import "ResourceManagerUtil.h"
#import "AppDelegate.h"


@implementation InspectorFontTTF

- (void) willBeAdded
{
    // Setup menu
    NSString* fnt = [ResourcePropertySetter ttfForNode:self.selection andProperty:self.propertyName];
    [ResourceManagerUtil populatePopupButtonWithFonts:popup selectedFontName:fnt target:self action:NULL];
}

- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[self.propertyName];
}

- (void)updateFonts {
    [self setFontForControl:popup property:self.propertyName];
}

- (void) selectedResource:(id)sender
{
    id item = [sender representedObject];
    
    // Fetch info about the font name or file
    NSString* fntFile = NULL;
    
    if ([item isKindOfClass:[PCResource class]])
    {
        // This is a file resource
        PCResource * res = item;
        
        if (res.type == PCResourceTypeTTF)
        {
            fntFile = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
        }
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        // This is a system font
        fntFile = item;
    }
    
    // Set the property
    if (fntFile)
    {
        [ResourcePropertySetter setTtfForNode:self.selection andProperty:self.propertyName withFont:fntFile];
    }
    
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];    
}

@end
