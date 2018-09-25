//
//  PCTableNode+JSExport.h
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-08.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCTableNode.h"
#import "NSObject+JSDataBinding.h"

@protocol PCTableNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (strong, nonatomic) SKColor *backgroundColor;
@property (assign, nonatomic) BOOL enableRefreshControl;
@property (strong, nonatomic, readonly) NSArray *cells;

- (void)endRefreshing;

- (void)addCellWithInfo:(PCTableCellInfo *)cellInfo;
- (void)removeCellAtIndex:(NSUInteger)cellIndex;
- (void)removeAllCells;

@end

@interface PCTableNode (JSExport) <PCTableNodeExport>

@end
