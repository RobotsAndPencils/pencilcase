//
//  PCFingerPaintView+JSExport.h
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-08.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCFingerPaintView.h"
#import "NSObject+JSDataBinding.h"

@protocol PCFingerPaintViewExport <JSExport, NSObjectJSDataBindingExport>

@property (assign, nonatomic) BOOL pressToShowColorPalette;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) CGFloat lineWidth;

- (void)clear;

@end

@interface PCFingerPaintView (JSExport) <PCFingerPaintViewExport>

@end