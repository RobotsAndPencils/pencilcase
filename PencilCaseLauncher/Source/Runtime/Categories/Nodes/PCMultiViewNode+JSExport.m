//
//  PCMultiViewNode+JSExport.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCMultiViewNode+JSExport.h"

@implementation PCMultiViewNode (JSExport)

- (void)setFocusedViewIndex:(NSInteger)focusedViewIndex {
    [self setFocusedCellIndex:focusedViewIndex];
}

- (NSInteger)focusedViewIndex {
    return [self focusedCellIndex];
}

@end
