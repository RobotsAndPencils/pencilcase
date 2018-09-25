//
//  PCMultiDragTouch.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-30.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Represents a single UITouch and a pan gesture to feed events to for the purpose of tracking velocity.
 */
@interface PCMultiDragTouch : NSObject

@property (strong, nonatomic) UITouch *touch;
@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;

@end
