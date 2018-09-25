//
//  PCShapeView.m
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2014-05-16.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCShapeView.h"

@implementation PCShapeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.fill = YES;
        self.stroke = YES;
        self.fillColor = [UIColor whiteColor];
        self.strokeColor = [UIColor grayColor];
        self.shapeType = PCShapeEllipse;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [self createPathWithRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (self.fill) {
        [self.fillColor set];
        [path fill];
    }
    if (self.stroke) {
        [path setLineWidth:self.strokeWidth];
        [self.strokeColor set];
        [path stroke];
    }
    
    CGContextTranslateCTM(context, 0, 0);
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}

- (UIBezierPath *)createPathWithRect:(CGRect) rect {
    UIBezierPath *path;
    switch (self.shapeType) {
        case PCShapeRectangle:
            path = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + self.strokeWidth / 2,
                                                               -rect.origin.y + self.strokeWidth / 2,
                                                               rect.size.width - self.strokeWidth,
                                                               rect.size.height - self.strokeWidth)];
            break;
        case PCShapeEllipse:
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(rect.origin.x + self.strokeWidth / 2,
                                                                     -rect.origin.y + self.strokeWidth / 2,
                                                                     rect.size.width - self.strokeWidth,
                                                                     rect.size.height - self.strokeWidth)];
            break;
        case PCShapeTriangle:
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(rect.origin.x + self.strokeWidth, -rect.origin.y + self.strokeWidth)];
            [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width/2, -rect.origin.y + rect.size.height - self.strokeWidth)];
            [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width - self.strokeWidth, -rect.origin.y + self.strokeWidth)];
            [path closePath];
            break;
        case PCShapeRoundedRectangle:
        default:
            path = [UIBezierPath bezierPathWithRect:rect];
            break;
    }
    return path;
}

#pragma mark - Properties

- (void)setFill:(BOOL)fill {
    _fill = fill;
    [self setNeedsDisplay];
}

- (void)setStroke:(BOOL)stroke {
    _stroke = stroke;
    [self setNeedsDisplay];
}

- (void)setShapeType:(PCShapeType)shapeType {
    _shapeType = shapeType;
    [self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self setNeedsDisplay];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    _strokeWidth = strokeWidth;
    [self setNeedsDisplay];
}

@end
