//
//  PCFingerPaintView.h
//  PCPlayer
//
//  Created by Daniel Drzimotta on 3/12/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCFingerPaintView : SKSpriteNode

@property (assign, nonatomic) BOOL pressToShowColorPalette;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) CGFloat lineWidth;

- (void)clear;

@end
