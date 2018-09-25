//
//  PCScrollViewNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-26.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCOverlayNode.h"
#import "SKNode+CropNodeNesting.h"

@interface PCScrollViewNode : SKSpriteNode <PCOverlayNode, PCNestedCropNodeContainer>

@property (assign, nonatomic, readonly) CGPoint offset;
@property (assign, nonatomic) BOOL pagingEnabled;
@property (assign, nonatomic) BOOL userScrollEnabled;
@property (assign, nonatomic) CGFloat maximumZoomScale;
@property (assign, nonatomic) CGFloat minimumZoomScale;
@property (assign, nonatomic) CGFloat zoomScale;

- (void)setOffset:(CGPoint)offset animated:(BOOL)animated;
- (void)addScrollHandler:(JSValue *)handler;

@end
