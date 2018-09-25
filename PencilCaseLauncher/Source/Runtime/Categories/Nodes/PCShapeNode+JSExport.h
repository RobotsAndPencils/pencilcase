//
//  PCShapeNode+JSExport.h
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-08.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCShapeNode.h"
#import "NSObject+JSDataBinding.h"

typedef enum PCShapeType : NSInteger PCShapeType;

@protocol PCShapeNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (strong, nonatomic) NSMutableDictionary *shapeInfo;

@property (assign, nonatomic) PCShapeType shapeType;
@property (assign, nonatomic) BOOL fill;
@property (assign, nonatomic) BOOL stroke;
@property (strong, nonatomic) UIColor *fillColor;
@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) CGFloat strokeWidth;

@end

@interface PCShapeNode (JSExport) <PCShapeNodeExport>

@end
