//
//  PCShapeView.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-05-16.
//
//

#import "PCShapeView.h"

@implementation PCShapeView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.fill = YES;
        self.stroke = YES;
        self.fillColor = [NSColor whiteColor];
        self.strokeColor = [NSColor grayColor];
        self.shapeType = PCShapeEllipse;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSBezierPath *path = [self createPath];
    if (self.fill) {
        [self.fillColor set];
        [path fill];
    }
    if (self.stroke) {
        [path setLineWidth:self.strokeWidth];
        [self.strokeColor set];
        [path stroke];
    }
}

- (NSBezierPath *)createPath {
    NSBezierPath *path;
    switch (self.shapeType) {
        case PCShapeRectangle:
            path = [NSBezierPath bezierPathWithRect:CGRectMake(0+self.strokeWidth/2,0+self.strokeWidth/2,self.frame.size.width - self.strokeWidth, self.frame.size.height - self.strokeWidth)];
            break;
        case PCShapeEllipse:
            path = [NSBezierPath bezierPathWithOvalInRect: CGRectMake(0+self.strokeWidth/2,0+self.strokeWidth/2,self.frame.size.width - self.strokeWidth, self.frame.size.height - self.strokeWidth)];
            break;
        case PCShapeTriangle:
             path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(self.strokeWidth, self.strokeWidth)];
            [path lineToPoint:NSMakePoint(self.frame.size.width/2, self.frame.size.height - self.strokeWidth)];
            [path lineToPoint:NSMakePoint(self.frame.size.width - self.strokeWidth, self.strokeWidth)];
            [path closePath];
            break;
        case PCShapeRoundedRectangle:
        default:
            path = [NSBezierPath bezierPathWithRect:self.frame];
            break;

    }
    return path;
}


@end
