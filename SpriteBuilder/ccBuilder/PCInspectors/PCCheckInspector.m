//
//  PCCheckInspector.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-07-08.
//
//

#import "PCCheckInspector.h"

@interface PCCheckInspector ()

@property (weak, nonatomic) IBOutlet NSButton *checkboxButton;
@property (assign, nonatomic) BOOL check;

@end

@implementation PCCheckInspector

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index {
    self.check = [value boolValue];
}

- (void)setCheck:(BOOL)check {
    if (_check != check) {
        _check = check;
        [self dispatchCheckboxButtonValueChanged];
    }
}

- (void)dispatchCheckboxButtonValueChanged {
    [self.delegate inspector:self valueChanged:@(self.check) forValueInfoAtIndex:0];
}

@end
