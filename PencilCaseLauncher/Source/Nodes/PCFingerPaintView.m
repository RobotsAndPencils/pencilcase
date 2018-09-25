//
//  PCFingerPaintView.m
//  PCPlayer
//
//  Created by Daniel Drzimotta on 3/12/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCFingerPaintView.h"

#import <CoreGraphics/CoreGraphics.h>
#import "SKNode+SFGestureRecognizers.h"
#import "PCColorSelectView.h"
#import "SKNode+JavaScript.h"
#import "SKNode+LifeCycle.h"
#import <ACEDrawingView/ACEDrawingView.h>
#import "PCOverlayView.h"
#import "PCOverlayNode.h"

@interface PCFingerPaintView () <PCOverlayNode>

@property (strong, nonatomic) PCColorSelectView *colorSelectView;
@property (strong, nonatomic) SKShapeNode *drawingShapeNode;
@property (strong, nonatomic) ACEDrawingView *drawingView;
@property (assign, nonatomic) BOOL loadedImage;

@end

@implementation PCFingerPaintView

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineColor = [UIColor blackColor];
        _drawingView = [[ACEDrawingView alloc] initWithFrame:self.frame];
        _drawingView.drawMode = ACEDrawingModeOriginalSize;
        _pressToShowColorPalette = YES;
        _lineWidth = 12;
    }
    return self;
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
    [self updateDrawingView];
}

- (void)pc_presentationCompleted {
    [super pc_presentationCompleted];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self sf_addGestureRecognizer:longPressGestureRecognizer];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [self saveImageToDisk];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
    [self.colorSelectView tearDownAndDestroy];
    self.colorSelectView = nil;
}

#pragma mark - Persisting image

- (NSString *)fileName {
    return [NSString stringWithFormat:@"%@-scratch.png", self.uuid];
}

- (NSString *)filePath {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [rootPath stringByAppendingPathComponent:[self fileName]];
}

- (void)loadImageFromDisk {
    NSString *filePath = [self filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]) {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        [self.drawingView loadImage:image];
    }
}

- (void)saveImageToDisk {
    [UIImagePNGRepresentation([self.drawingView image]) writeToFile:[self filePath] atomically:YES];
}

- (void)clear {
    [self.drawingView clear];
}

#pragma mark - Private

- (void)updateDrawingView {
    self.drawingView.drawTool = self.colorSelectView.selectedEraser ? ACEDrawingToolTypeEraser : ACEDrawingToolTypePen;
    self.drawingView.lineColor = self.lineColor;
    self.drawingView.lineWidth = self.lineWidth;
}

#pragma mark - Properties

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self updateDrawingView];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self updateDrawingView];
}

- (void)setSize:(CGSize)size {
    [self.drawingView commitAndDiscardToolStack];
    [super setSize:size];
    [self.drawingView setNeedsDisplay];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.drawingView.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - GestureRecognizers

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!self.pressToShowColorPalette) return;
    if (UIGestureRecognizerStateBegan == longPressGestureRecognizer.state) {
        [self.drawingView undoLatestStep];
        self.colorSelectView = [[PCColorSelectView alloc] init];
        self.colorSelectView.sceneSize = self.pc_scene.size;
        [[PCOverlayView overlayView] addSubview:self.colorSelectView];
        CGPoint centerInView = [longPressGestureRecognizer locationInView:self.scene.view];
        self.colorSelectView.center = [self.scene convertPointFromView:centerInView];
    } else if (UIGestureRecognizerStateChanged == longPressGestureRecognizer.state) {
        [self.colorSelectView selectColorCellUnderTouch:[self.pc_scene.view convertPoint:[longPressGestureRecognizer locationInView:longPressGestureRecognizer.view] toView:self.colorSelectView]];
    } else if (UIGestureRecognizerStateEnded == longPressGestureRecognizer.state || UIGestureRecognizerStateCancelled == longPressGestureRecognizer.state) {
        if (self.colorSelectView.selectedEraser) {
            self.lineColor = [self.color colorWithAlphaComponent:1];
        } else {
            UIColor *selectedColor = self.colorSelectView.selectedColor;
            if (selectedColor) {
                self.lineColor = selectedColor;
            }
        }
        [self.colorSelectView tearDownAndDestroy];
        self.colorSelectView = nil;
    }
}

#pragma PCOverlayView

- (UIView *)trackingView {
    return self.drawingView;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (!self.loadedImage) {
        self.loadedImage = YES;
        [self loadImageFromDisk];
    }
}

@end