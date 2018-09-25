//
//  PCStatementCellView.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-04.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PCInspectableView.h"

@class PCInspectableView;

@interface PCStatementCellView : NSTableCellView

@property (weak, nonatomic) IBOutlet PCInspectableView *backgroundView;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;

@end
