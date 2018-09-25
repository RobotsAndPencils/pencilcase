//
//  PCWhenViewController.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-09.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PCBehaviourController.h"

@class PCWhen;

@interface PCWhenViewController : NSViewController <PCBehaviourController>

@property (strong, nonatomic) PCWhen *when;
@property (copy, nonatomic) dispatch_block_t deleteHandler;
@property (copy, nonatomic) void(^didFocusRectHandler)(CGRect rect);

- (BOOL)hasThenSelected;
- (NSInteger)selectedThenIndex;

@end
