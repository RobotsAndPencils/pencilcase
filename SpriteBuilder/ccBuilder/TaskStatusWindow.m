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

#import "TaskStatusWindow.h"

@interface TaskStatusWindow()

@property (weak, nonatomic) IBOutlet NSButton *cancelButton;

@end

@implementation TaskStatusWindow

@synthesize status;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) windowDidLoad
{
    [super windowDidLoad];
    [progressIndicator startAnimation:self];
    [progressIndicator setUsesThreadedAnimation:YES];
    self.cancelButton.hidden = YES;
}

- (void)setProgress:(double)progress {
    if (progress >= 0 && progress <= 1) {
        [progressIndicator setMinValue:0];
        [progressIndicator setMaxValue:1];
        [progressIndicator setIndeterminate:NO];
        [progressIndicator setDoubleValue:progress];
    }
    else {
        [progressIndicator setIndeterminate:YES];
    }
}

- (void)setCancelButtonVisible:(BOOL)cancelButtonVisible {
    self.cancelButton.hidden = !cancelButtonVisible;
}

#pragma mark - IBactions

- (IBAction)cancelButtonPressed:(NSButton *)sender {
    if (self.cancellationCallback) {
        self.cancellationCallback();
    }
}

@end
