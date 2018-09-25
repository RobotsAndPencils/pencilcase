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

#import "SequencerPopoverSound.h"
#import "SequencerKeyframe.h"
#import "PCResourceManager.h"
#import "ResourceManagerUtil.h"
#import "AppDelegate.h"

@implementation SequencerPopoverSound

@synthesize view;

- (NSArray*) replaceObjectAtIndex:(int)idx inArray:(NSArray*)arr withObject:(id)obj
{
    NSMutableArray* newArr = [NSMutableArray arrayWithArray:arr];
    [newArr replaceObjectAtIndex:idx withObject:obj];
    return newArr;
}

- (void) willBeAdded
{
    // Setup menu
    PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:_keyframe.value[0]];
    NSString *filePath = [ResourceManagerUtil userFacingPathFromAbsolutePath:resource.filePath];
    [ResourceManagerUtil populateResourcePopup:popup resourceType:PCResourceTypeAudio allowSpriteFrames:NO selectedFile:filePath target:self];
}

- (void) selectedResource:(id)sender
{
    id item = [sender representedObject];
    
    // Fetch info about the sprite name
    NSString *sound = nil;
    
    if ([item isKindOfClass:[PCResource class]])
    {
        PCResource *resource = item;
        
        if (resource.type == PCResourceTypeAudio) {
            sound = [ResourceManagerUtil userFacingPathFromAbsolutePath:resource.filePath] ?: @"";
            [ResourceManagerUtil setTitle:sound forPopup:popup];

            NSArray *val = _keyframe.value;
            _keyframe.value = [self replaceObjectAtIndex:0 inArray:val withObject:resource.uuid];
        }
    }
    
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*popoversound"];
}

- (float) pitch
{
    return [[_keyframe.value objectAtIndex:1] floatValue];
}

- (void) setPitch:(float)pitch
{
    if (pitch <= 0) return;
    
    _keyframe.value = [self replaceObjectAtIndex:1 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:pitch]];
    
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*popoversound"];
}

- (float) pan
{
    return [[_keyframe.value objectAtIndex:2] floatValue];
}

- (void) setPan:(float)pan
{
    _keyframe.value = [self replaceObjectAtIndex:2 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:pan]];
    
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*popoversound"];
}

- (float) gain
{
    return [[_keyframe.value objectAtIndex:3] floatValue];
}

- (void) setGain:(float)gain
{
    _keyframe.value = [self replaceObjectAtIndex:3 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:gain]];
    
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*popoversound"];
}


#pragma mark Error handling for validation of text fields

- (BOOL) control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    NSTextField* tf = (NSTextField*)control;
    
    self.textFieldOriginalValue = [tf stringValue];
    
    return YES;
}

- (BOOL) control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{
    NSBeep();
    
    NSTextField* tf = (NSTextField*)control;
    [tf setStringValue:self.textFieldOriginalValue];
    
    return YES;
}

@end
