//
//  PCShapeView.h
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2014-05-16.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PCShapeType) {
    PCShapeRectangle,
    PCShapeEllipse,
    PCShapeTriangle,
    PCShapeRoundedRectangle
};

@interface PCShapeView : UIView

@property (assign, nonatomic) PCShapeType shapeType;
@property (assign, nonatomic) BOOL fill;
@property (assign, nonatomic) BOOL stroke;
@property (strong, nonatomic) UIColor *fillColor;
@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) CGFloat strokeWidth;


@property (assign, nonatomic) CGPoint anchorPoint;
@property (assign, nonatomic) CGFloat rotation;

@end
