//
//  PCSlideTableCellView.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 1/23/2014.
//
//

#import "PCSlideTableCellView.h"


const CGFloat PCSlideTableCellMaximumFontSize = 13.0;
const CGFloat PCSlideTableCellMinimumFontSize = 6.0;


@interface PCSlideTableCellView ()

@property (nonatomic, weak) IBOutlet NSTextField *field;

@end


@implementation PCSlideTableCellView

- (void)setSlideIndex:(NSInteger)slideIndex {
    _slideIndex = slideIndex;
    [self resizeTextFieldFontSizeForText:[NSString stringWithFormat:@"%ld", (long)slideIndex]];
}

- (void)resizeTextFieldFontSizeForText:(NSString *)text {
    CGFloat fontSize = PCSlideTableCellMaximumFontSize;
    NSSize textSize = [text sizeWithAttributes:@{ NSFontAttributeName : [NSFont fontWithName:self.field.font.fontName size:fontSize] }];
    
    while ((textSize.width > CGRectGetWidth(self.field.frame)) && (fontSize > PCSlideTableCellMinimumFontSize)) {
        fontSize -= 1.0;
        textSize = [text sizeWithAttributes:@{ NSFontAttributeName : [NSFont fontWithName:self.field.font.fontName size:fontSize] }];
    }
    
    [self.field setFont:[NSFont fontWithName:self.field.font.fontName size:fontSize]];
}

@end
