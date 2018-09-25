//
//  PCColorInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-14.
//
//

#import "PCColorInspector.h"
#import "BFPopoverColorWell.h"

@interface PCColorInspector ()

@property (weak, nonatomic) IBOutlet BFPopoverColorWell *colorWell;
@property (weak, nonatomic) IBOutlet NSTextField *propertyLabel;

@property (strong, nonatomic) NSColor *color;

@end

@implementation PCColorInspector

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index {
    self.color = value ?: [NSColor whiteColor];
}

#pragma mark - Private

#pragma mark - Properties

- (void)awakeFromNib {
    [super awakeFromNib];
    _color = [NSColor whiteColor];
}

- (void)setColor:(NSColor *)color {
    if (color == _color) return;
    _color = color;
    [self.delegate inspector:self valueChanged:self.color forValueInfoAtIndex:0];
}

@end
