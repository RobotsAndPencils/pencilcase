//
//  PCMultiDragGestureRecognizer.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-30.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Begins when any touch begins on screen. Changes when touches move or touches are added/removed. Ends when all touches are ended/cancelled.
 
 Maintains an array of active touches which are PCMultiDragTouch objects.
 */
@interface PCMultiDragGestureRecognizer : UIGestureRecognizer

@property (strong, nonatomic, readonly) NSMutableArray *activeTouches;

@end
