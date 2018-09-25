//
//  PCWhenView.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PCInspectableView.h"

@interface PCWhenView : NSView

@property (copy, nonatomic) dispatch_block_t deleteHandler;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL allowDrag;
@property (assign, nonatomic) BOOL sourceHighlighted;

@end
