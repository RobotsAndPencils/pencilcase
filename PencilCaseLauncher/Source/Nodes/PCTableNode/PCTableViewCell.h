//
//  PCTableViewCell.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-05-20.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCTableCellInfo;

@interface PCTableViewCell : UITableViewCell

+ (instancetype)cellForCellInfo:(PCTableCellInfo *)info; // Create a cell with the correct views and layout.
- (void)setupWithCellInfo:(PCTableCellInfo *)info; // Populate cell with values.

@end
