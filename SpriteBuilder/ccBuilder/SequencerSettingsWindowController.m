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

#import "SequencerSettingsWindowController.h"
#import "SequencerSequence.h"

@implementation SequencerSettingsWindowController

- (void)copySequences:(NSMutableArray *)seqs {
    self.sequences = [NSMutableArray arrayWithCapacity:[seqs count]];

    for (SequencerSequence *seq in seqs) {
        SequencerSequence *seqCopy = [seq copy];
        seqCopy.settingsWindow = self;
        [self.sequences addObject:seqCopy];
    }
}

- (BOOL)sheetIsValid {
    if ([self.sequences count] > 0) {
        return YES;
    }
    else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Missing Timeline" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"You need to have at least one timeline in your document."];
        [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];

        return NO;
    }
}

- (void)disableAutoPlayForAllItems {
    PCLog(@"Disabling autoplay for sequences: %@", self.sequences);

    for (SequencerSequence *seq in self.sequences) {
        seq.autoPlay = NO;
    }
}

@end