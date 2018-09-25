//
//  PCShapeNode.m
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2014-05-16.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCShapeNode.h"
#import "PCShapeView.h"
#import "PCOverlayView.h"
#import "SKNode+LifeCycle.h"

@interface PCShapeNode()

@end

@implementation PCShapeNode

- (id)init {
    self = [super init];
    if (self) {
        _shapeView = [[PCShapeView alloc] init];
        _shapeView.shapeType = PCShapeRectangle;
        _shapeView.userInteractionEnabled = NO;
    }
    return self;
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self setShapeValues];
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

- (void)setShapeValues {
    self.shapeView.shapeType = [self.shapeInfo[@"parameters"][@"shapeType"] integerValue];
    self.shapeView.stroke = [self.shapeInfo[@"parameters"][@"stroke"] boolValue];
    self.shapeView.strokeWidth = self.shapeView.stroke ? [self.shapeInfo[@"parameters"][@"strokeWidth"] floatValue] : 0;
    self.shapeView.fill = [self.shapeInfo[@"parameters"][@"fill"] boolValue];
    
    NSArray *strokeColorValues = self.shapeInfo[@"parameters"][@"strokeColor"];
    if (strokeColorValues) {
        float r = [strokeColorValues[0] floatValue];
        float g = [strokeColorValues[1] floatValue];
        float b = [strokeColorValues[2] floatValue];
        float a = [strokeColorValues[3] floatValue];
        self.shapeView.strokeColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    
    NSArray *fillColorValues = self.shapeInfo[@"parameters"][@"fillColor"];
    if (fillColorValues) {
        float r = [fillColorValues[0] floatValue];
        float g = [fillColorValues[1] floatValue];
        float b = [fillColorValues[2] floatValue];
        float a = [fillColorValues[3] floatValue];
        self.shapeView.fillColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.shapeView;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (frameChanged) {
        [self.shapeView setNeedsDisplay];
    }
}

@end
