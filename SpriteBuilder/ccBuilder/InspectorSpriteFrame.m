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

#import "InspectorSpriteFrame.h"
#import "AppDelegate.h"
#import "ResourcePropertySetter.h"
#import "CCBWriterInternal.h"
#import "ResourceManagerUtil.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SKNode+Sequencer.h"
#import "SKNode+NodeInfo.h"

@interface InspectorSpriteFrame()

@property (weak, nonatomic) IBOutlet NSPopUpButton *popup;

@end

@implementation InspectorSpriteFrame

- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[self.propertyName];
}

- (void)updateFonts {
    [self setFontForControl:self.popup property:self.propertyName];
}

- (void) willBeAdded
{
    [self refresh];
}

- (void)refresh {
    // Setup menu
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    id value = [self.selection valueForProperty:self.propertyName atTime:seq.timelinePosition sequenceId:seq.sequenceId];

    NSString *spriteFrameFile = nil;
    if (!PCIsEmpty(value)) {
        NSString *spriteFrameUUID = value;
        PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:spriteFrameUUID];
        spriteFrameFile = [ResourceManagerUtil userFacingPathFromAbsolutePath:resource.filePath];
    }

    [ResourceManagerUtil populateResourcePopup:self.popup resourceType:PCResourceTypeImage allowSpriteFrames:YES selectedFile:spriteFrameFile target:self];
}

- (void) selectedResource:(id)sender
{
    PCResource *item = [sender representedObject];
    
    // Fetch info about the sprite name
    NSString* spriteFile = @"";
    
    if (item && item.type == PCResourceTypeImage) {
        spriteFile = [ResourceManagerUtil userFacingPathFromAbsolutePath:item.filePath];
        [ResourceManagerUtil setTitle:spriteFile forPopup:self.popup];
    }

    
    // Set the properties and sprite frames
    if (spriteFile) {
        [ResourcePropertySetter setResource:item forProperty:self.propertyName onNode:self.selection];
        [self updateAnimateablePropertyValue:item.uuid];
    }
    
    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
    [self refresh];
}

@end
