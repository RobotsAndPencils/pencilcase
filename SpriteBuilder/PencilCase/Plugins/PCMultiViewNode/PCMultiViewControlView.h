//
//  PCMultiViewControlView.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-06-18.
//
//

#import <Cocoa/Cocoa.h>

@interface PCMultiViewControlView : NSView

@property (copy, nonatomic) dispatch_block_t nextCellHandler;
@property (copy, nonatomic) dispatch_block_t previousCellHandler;
@property (copy, nonatomic) dispatch_block_t addCellHandler;
@property (copy, nonatomic) dispatch_block_t removeCellHandler;

@property (assign, nonatomic) NSInteger numberOfCells;
@property (assign, nonatomic) NSInteger currentCellIndex;

+ (instancetype)create;

@end
