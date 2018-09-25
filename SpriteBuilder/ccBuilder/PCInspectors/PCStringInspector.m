//
//  PCStringInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-14.
//
//

#import "PCStringInspector.h"

@interface PCStringInspector () <NSTextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSTextField *textField;

@end

@implementation PCStringInspector

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index {
    if (!value) return;
    [self.textField setStringValue:[NSString stringWithFormat:@"%@", value]];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification {
    [self.delegate inspector:self valueChanged:[notification.object stringValue] forValueInfoAtIndex:0];
}

@end
