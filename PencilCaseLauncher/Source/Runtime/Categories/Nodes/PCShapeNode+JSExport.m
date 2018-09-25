//
//  PCShapeNode+JSExport.m
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-08.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCShapeNode+JSExport.h"
#import "PCShapeView.h"

@implementation PCShapeNode (JSExport)

- (PCShapeType)shapeType {
    return self.shapeView.shapeType;
}

- (void)setShapeType:(PCShapeType)shapeType {
    self.shapeView.shapeType = shapeType;
}

- (BOOL)fill {
    return self.shapeView.fill;
}

- (void)setFill:(BOOL)fill {
    self.shapeView.fill = fill;
}

- (BOOL)stroke {
    return self.shapeView.stroke;
}

- (void)setStroke:(BOOL)stroke {
    self.shapeView.stroke = stroke;
}

- (UIColor *)fillColor {
    return self.shapeView.fillColor;
}

- (void)setFillColor:(UIColor *)fillColor {
    self.shapeView.fillColor = fillColor;
}

- (UIColor *)strokeColor {
    return self.shapeView.strokeColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    self.shapeView.strokeColor = strokeColor;
}

- (CGFloat)strokeWidth {
    return self.shapeView.strokeWidth;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    self.shapeView.strokeWidth = strokeWidth;
}

@end
