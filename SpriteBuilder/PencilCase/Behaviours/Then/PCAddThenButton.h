//
//  PCAddThenButton.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-13.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface PCAddThenButton : NSView

@property (copy, nonatomic) dispatch_block_t clickHandler;

@end
