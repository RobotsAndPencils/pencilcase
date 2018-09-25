//
//  PCThenBackgroundView.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-11.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface PCThenBackgroundView : NSView

@property (assign, nonatomic) IBInspectable BOOL topConnected;
@property (assign, nonatomic) IBInspectable BOOL bottomConnected;
@property (assign, nonatomic) IBInspectable BOOL hideTopConnector;
@property (assign, nonatomic) IBInspectable BOOL hideBottomConnector;
@property (assign, nonatomic) IBInspectable BOOL selected;
@property (assign, nonatomic) IBInspectable BOOL isSourceHighlighted;
@property (strong, nonatomic) IBInspectable NSColor *sourceHighlightColor;
@property (assign, nonatomic) IBInspectable BOOL nextThenSelected;

@end
