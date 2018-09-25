//
//  PCBOOLExpressionInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-07.
//
//

#import "PCBOOLExpressionInspector.h"

@interface PCBOOLExpressionInspector ()

@property (weak, nonatomic) IBOutlet NSButton *checkBox;
@property (weak, nonatomic) IBOutlet NSTextField *label;

@end

@implementation PCBOOLExpressionInspector

@synthesize saveHandler = _saveHandler;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.label.stringValue = self.name ?: @"";
}

- (void)setValue:(BOOL)value {
    if (_value == value) return;
    _value = value;
    self.checkBox.state = value ? NSOnState : NSOffState;
}

- (void)setName:(NSString *)name {
    if ([_name isEqualToString:name]) return;
    _name = [name copy];
    self.label.stringValue = _name;
}

#pragma mark - PCExpressionInspector

- (NSView *)initialFirstResponder {
    return self.checkBox;
}

@end
