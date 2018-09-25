//
//  PCColorSelectView.m
//  PCPlayer
//
//  Created by Stephen Gazzard on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCColorSelectView.h"

static const CGFloat PCColorSelectSelectAnimationTime = 0.15f;
static const CGFloat PCColorSelectDeselectedAlpha = 0.9f;
static const NSUInteger PCColorSelectCellsPerRow = 3;
static const CGFloat PCColorSelectPaletteCellDimensions = 60;

@interface PCColorSelectView ()

@property (strong, nonatomic) NSArray *colorPaletteCells;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) UIView *selectedColorPaletteCell;

@end

@implementation PCColorSelectView

- (id)initWithColors:(NSArray *)colors {
    NSInteger columns = MIN(colors.count, PCColorSelectCellsPerRow);
    NSInteger rows = ceilf(colors.count / (CGFloat)PCColorSelectCellsPerRow);
    if ((self = [super initWithFrame:CGRectMake(0, 0, columns * PCColorSelectPaletteCellDimensions, rows * PCColorSelectPaletteCellDimensions)])) {
        [self generateColorPaletteWithColors:colors];
    }
    return self;
}

- (id)init {
    return [self initWithColors:@[[UIColor redColor],
                                  [UIColor purpleColor],
                                  [UIColor blueColor],
                                  [UIColor greenColor],
                                  [UIColor yellowColor],
                                  [UIColor orangeColor],
                                  [UIColor blackColor],
                                  [UIColor whiteColor],
                                  [UIColor clearColor]]];
}

#pragma mark - Public methods

- (UIColor *)selectedColor {
    return self.selectedColorPaletteCell ? self.colors[[self.colorPaletteCells indexOfObject:self.selectedColorPaletteCell]] : nil;
}

- (BOOL)selectedEraser {
    UIColor *selectedColor = [self selectedColor];
    return selectedColor && 0 == CGColorGetAlpha(selectedColor.CGColor);
}

#pragma mark - Animation / layout helpers

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
    if (self.superview) {
        [self verifyColorPaletteIsOnScreen];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        [self verifyColorPaletteIsOnScreen];
    }
}

- (CGRect)frameForCellAtIndex:(NSInteger)index {
    return CGRectMake((index % PCColorSelectCellsPerRow) * PCColorSelectPaletteCellDimensions,
                      index / PCColorSelectCellsPerRow * PCColorSelectPaletteCellDimensions,
                      PCColorSelectPaletteCellDimensions, PCColorSelectPaletteCellDimensions);
}

- (void)resetPalettePositions {
    for (NSUInteger colorIndex = 0; colorIndex < [self.colorPaletteCells count]; colorIndex++) {
        UIView *colorCell = self.colorPaletteCells[colorIndex];
        colorCell.frame = [self frameForCellAtIndex:colorIndex];
    }
}

- (void)verifyColorPaletteIsOnScreen {
    [self resetPalettePositions];
    
    CGPoint offset = CGPointZero;
    for (UIView *paletteCell in self.colorPaletteCells) {
        CGRect boundingBox = paletteCell.frame;
        boundingBox.origin = [self convertPoint:boundingBox.origin toView:self.superview];
        if (CGRectGetMinX(boundingBox) < 0) {
            offset.x = MAX(offset.x, -CGRectGetMinX(boundingBox));
        } else if (CGRectGetMaxX(boundingBox) > self.sceneSize.width) {
            offset.x = MIN(offset.x, self.sceneSize.width - CGRectGetMaxX(boundingBox));
        }
        
        if (CGRectGetMinY(boundingBox) < 0) {
            offset.y = MAX(offset.x, -CGRectGetMinY(boundingBox));
        } else if (CGRectGetMaxY(boundingBox) > self.sceneSize.height) {
            offset.y = MIN(offset.y, self.sceneSize.height - CGRectGetMaxY(boundingBox));
        }
    }
    
    if (offset.x || offset.y) {
        for (UIView *paletteCell in self.colorPaletteCells) {
            CGRect frame = paletteCell.frame;
            frame.origin = pc_CGPointAdd(frame.origin, offset);
            paletteCell.frame = frame;
        }
    }
}

- (void)generateColorPaletteWithColors:(NSArray *)colors {
    static const CGFloat buildInAnimationTime = 0.1f;

    NSMutableArray *tempColorPaletteCells = [NSMutableArray array];

    CGFloat cellLeft = 0;

    for (NSUInteger colorIndex = 0; colorIndex < [colors count]; colorIndex++) {
        UIColor *color = colors[colorIndex];
        UIView *colorView = [[UIView alloc] initWithFrame:[self frameForCellAtIndex:colorIndex]];
        colorView.alpha = 0;
        colorView.backgroundColor = color;

        if (0 == CGColorGetAlpha(color.CGColor)) {
            UIImageView *eraserImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eraseIcon.png"]];
            eraserImage.contentMode = UIViewContentModeScaleAspectFill;
            eraserImage.frame = CGRectMake(0, 0, colorView.frame.size.width, colorView.frame.size.height);
            [colorView addSubview:eraserImage];
        }

        [self addSubview:colorView];
        [tempColorPaletteCells addObject:colorView];
    }
    self.colorPaletteCells = tempColorPaletteCells;
    self.colors = colors;

    [UIView animateWithDuration:buildInAnimationTime animations:^{
        for (UIView *view in self.colorPaletteCells) {
            view.alpha = PCColorSelectDeselectedAlpha;
        }
    }];
}

- (void)tearDownAndDestroy {
    static const CGFloat teardownAnimationTime = 0.1f;
    [UIView animateWithDuration:teardownAnimationTime animations:^{
        for (UIView *colorPaletteCell in self.colorPaletteCells) {
            colorPaletteCell.frame = CGRectMake(0, 0, 0, 0);
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)deselectSelectedColorPaletteCell {
    [UIView animateWithDuration:PCColorSelectSelectAnimationTime animations:^{
        self.selectedColorPaletteCell.alpha = PCColorSelectDeselectedAlpha;
        self.selectedColorPaletteCell.transform = CGAffineTransformIdentity;
    }];
    self.selectedColorPaletteCell = nil;
}

- (void)selectColorPaletteCell:(UIView *)colorPaletteCell {
    [self deselectSelectedColorPaletteCell];
    self.selectedColorPaletteCell = colorPaletteCell;
    [UIView animateWithDuration:PCColorSelectSelectAnimationTime animations:^{
        self.selectedColorPaletteCell.alpha = 1;
        self.selectedColorPaletteCell.transform = CGAffineTransformMakeScale(1.1, 1.1);
    }];
    [self bringSubviewToFront:self.selectedColorPaletteCell];
}

#pragma mark - Touches

- (void)selectColorCellUnderTouch:(CGPoint)localTouchPoint {
    if (CGRectContainsPoint(self.selectedColorPaletteCell.frame, localTouchPoint)) return;

    for (UIView *colorPaletteCell in self.colorPaletteCells) {
        if (colorPaletteCell == self.selectedColorPaletteCell) continue;
        
        if (CGRectContainsPoint(colorPaletteCell.frame, localTouchPoint)) {
            [self selectColorPaletteCell:colorPaletteCell];
            return;
        }
    }
    
    //The point is not within any node - deselect
    [self deselectSelectedColorPaletteCell];
}


@end
