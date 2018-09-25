//
//  PCLabelTTF.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-21.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCLabelTTF.h"
#import "PCAppViewController.h"
#import "PCApp.h"
#import "SKNode+CocosCompatibility.h"
#import "NSString+MaxSize.h"
#import "PCHashFixLabelNode.h"

static const NSInteger PCMaxRenderableStringWidth = 1024; //Max texture size on iPhone 4S in points

@interface PCLabelTTF()

@property (strong, nonatomic) NSArray *internalLabels;

@end

@implementation PCLabelTTF

#pragma mark Properties

- (void)setHorizontalAlignment:(CCTextAlignment)alignment {
    _horizontalAlignment = alignment;
    self.anchorPoint = [self anchorPointFromAlignment];
}

- (void)setVerticalAlignment:(CCVerticalTextAlignment)alignment {
    _verticalAlignment = alignment;
    self.anchorPoint = [self anchorPointFromAlignment];
}

- (void)setString:(NSString *)string {
    if ([_string isEqualToString:string]) return;

    _string = [string copy];
    [self reloadChildLabels];
}

- (void)setFontName:(NSString *)fontName {
    NSString *newFontName = fontName;
    NSDictionary *fontNames = [[PCAppViewController lastCreatedInstance].runningApp fontNamesDictionary];

    newFontName = fontNames[fontName];
    if (PCIsEmpty(newFontName)) newFontName = fontName;

    _fontName = fontName;
    [self reloadChildLabels];
}

- (void)setFontSize:(CGFloat)fontSize {
    if (_fontSize == fontSize) return;

    _fontSize = fontSize;
    [self reloadChildLabels];
}

- (void)setFontColor:(SKColor *)fontColor {
    if ([_fontColor isEqual:fontColor]) return;

    _fontColor = fontColor;
    [self.internalLabels makeObjectsPerformSelector:@selector(setFontColor:) withObject:fontColor];
}

#pragma mark - Private

- (void)reloadChildLabels {
    [self.internalLabels makeObjectsPerformSelector:@selector(removeFromParent)];
    UIFont *font = [UIFont fontWithName:self.fontName size:self.fontSize];
    if (!font) return;

    NSDictionary *textAttributes = @{ NSFontAttributeName : font };
    self.contentSize = [self.string sizeWithAttributes:textAttributes];

    NSArray *stringChunks = [self.string pc_splitIntoChunksWithMaxWidth:PCMaxRenderableStringWidth attributes:textAttributes];
    CGFloat left = -self.contentSize.width * self.anchorPoint.x;
    CGFloat bottom = -self.contentSize.height * self.anchorPoint.y;
    NSMutableArray *tempLabels = [NSMutableArray array];
    for (NSString *string in stringChunks) {
        SKLabelNode *labelNode = [[PCHashFixLabelNode alloc] initWithFontNamed:self.fontName];
        labelNode.fontSize = self.fontSize;
        labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;

        labelNode.text = string;
        labelNode.position = CGPointMake(left, bottom);
        labelNode.fontColor = self.fontColor;
        left += [string sizeWithAttributes:textAttributes].width;
        [self addChild:labelNode];
        [tempLabels addObject:labelNode];
    }
    self.internalLabels = [tempLabels copy];
}

- (CGPoint)anchorPointFromAlignment {
    CGPoint anchorPoint = CGPointZero;
    switch (self.horizontalAlignment) {
        case CCTextAlignmentCenter:
            anchorPoint.x = 0.5;
            break;
        case CCTextAlignmentRight:
            anchorPoint.x = 1.0;
            break;
        case CCTextAlignmentLeft:
        default:
            break;
    }
    switch (self.verticalAlignment) {
        case CCVerticalTextAlignmentCenter:
            anchorPoint.y = 0.5;
            break;
        case CCVerticalTextAlignmentTop:
            anchorPoint.y = 1.0;
            break;
        case CCVerticalTextAlignmentBottom:
        default:
            break;
    }
    return anchorPoint;
}

@end
