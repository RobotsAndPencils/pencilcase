//
//  PCView.h
//  Zoom
//
//  Created by Cody Rayment on 2014-03-20.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PCOverlayTrackingView.h"

IB_DESIGNABLE
@interface PCView : NSView <PCOverlayTrackingView>

@property (strong, nonatomic) IBInspectable NSColor *pc_backgroundColor;
@property (assign, nonatomic) BOOL pc_userInteractionEnabled;

@end
