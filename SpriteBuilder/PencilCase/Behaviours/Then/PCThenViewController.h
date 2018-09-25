//
//  PCThenViewController.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PCBehaviourController.h"

@class PCThen;

@interface PCThenViewController : NSViewController <PCBehaviourController>

@property (strong, nonatomic) PCThen *then;
@property (copy, nonatomic) dispatch_block_t connectWithNextThenHandler;
@property (copy, nonatomic) dispatch_block_t deleteHandler;
@property (copy, nonatomic) dispatch_block_t selectionChangeHandler;
@property (assign, nonatomic) BOOL nextThenSelected;

- (void)updateUI;
- (void)closePopover;

@end
