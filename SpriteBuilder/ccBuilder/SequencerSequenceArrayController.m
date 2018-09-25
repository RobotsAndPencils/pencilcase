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

#import "SequencerSequenceArrayController.h"
#import "SequencerSequence.h"

@implementation SequencerSequenceArrayController

@synthesize settingsWindow;

- (void)addObject:(id)object {
    SequencerSequence *seq = object;
    seq.settingsWindow = settingsWindow;
    [super addObject:object];
}

- (void)remove:(id)sender {
    NSArray *sequences = self.selectedObjects;
    NSArray *sequencesWithoutDefault = Underscore.filter(sequences, ^BOOL(SequencerSequence *sequence) {
        return sequence.sequenceId != CardDefaultSequenceId;
    });
    [self removeObjects:sequencesWithoutDefault];
}

// Don't allow deleting the default timeline or all timelines. We need to check for the second condition because previously users _could_ delete the default timeline, which means if they had done that and we didn't check they could now still delete all of them.
- (BOOL)canRemove {
    BOOL defaultSequenceIsSelected = Underscore.any(self.selectedObjects, ^BOOL(SequencerSequence *sequence) {
        return sequence.isDefaultSequence;
    });
    NSArray *sequences = self.arrangedObjects;
    return !defaultSequenceIsSelected && sequences.count > 1;
}

@end
