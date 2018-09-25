//
//  PCTableNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-05-08.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCOverlayNode.h"

@class PCTableCellInfo;

@interface PCTableNode : SKSpriteNode <PCOverlayNode, UITableViewDelegate>

@property (strong, nonatomic) UIColor *backgroundColor;
@property (assign, nonatomic) BOOL enableRefreshControl;
@property (strong, nonatomic, readonly) NSArray *cells;

- (void)endRefreshing;

- (void)addCellWithInfo:(PCTableCellInfo *)cellInfo;
- (void)removeCellAtIndex:(NSUInteger)cellIndex;
- (void)removeAllCells;

@end
