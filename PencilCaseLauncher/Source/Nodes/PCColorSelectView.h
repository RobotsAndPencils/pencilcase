//
//  PCColorSelectView.h
//  PCPlayer
//
//  Created by Stephen Gazzard on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@interface PCColorSelectView : UIView

@property (assign, nonatomic) CGSize sceneSize;

/**
 Custom initialiser that allows the caller to specify the colors used in the pallette. Call init to use default colors.
 @param colors: an array of colors that will be available to the user.
 @returns An initialised PCColorSelectView
 */
- (id)initWithColors:(NSArray *)colors;

/**
 Runs a teardown animation, then removes itself from the scene
 */
- (void)tearDownAndDestroy;

/**
 Given a point in this view, selects whichever color cell is underneath it.
 @param localTouchPoint: The point to select under, in local coordinates
 */
- (void)selectColorCellUnderTouch:(CGPoint)localTouchPoint;

 /**
 Returns the colour that is presently selected based on the mouse touch.
 @returns The presently selected colour
 */
- (UIColor *)selectedColor;

/**
 @returns YES if the user has selected the eraser
 @returns NO if they have not
 */
- (BOOL)selectedEraser;

@end
