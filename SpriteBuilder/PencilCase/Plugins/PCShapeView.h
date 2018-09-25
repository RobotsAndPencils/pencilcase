//
//  PCShapeView.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-05-16.
//
//

#import <Cocoa/Cocoa.h>

@interface PCShapeView : NSView

typedef NS_ENUM(NSInteger, PCShapeType) {
    PCShapeRectangle,
    PCShapeEllipse,
    PCShapeTriangle,
    PCShapeRoundedRectangle
};

@property (assign, nonatomic) PCShapeType shapeType;

@property (assign, nonatomic) NSCellStateValue fill;
@property (assign, nonatomic) NSCellStateValue stroke;
@property (strong, nonatomic) NSColor *fillColor;
@property (strong, nonatomic) NSColor *strokeColor;
@property (assign, nonatomic) CGFloat strokeWidth;


@end
