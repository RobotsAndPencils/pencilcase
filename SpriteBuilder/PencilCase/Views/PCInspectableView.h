//
//  PCInspectableView.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-13.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface PCInspectableView : NSView

@property (strong, nonatomic) IBInspectable NSColor *backgroundColor;
@property (strong, nonatomic) IBInspectable NSColor *borderColor;
@property (assign, nonatomic) IBInspectable NSInteger borderWidth;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;

@end
