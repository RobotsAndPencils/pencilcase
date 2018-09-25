//
//  PCScrollViewNode+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-30.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCScrollViewNode.h"
#import "NSObject+JSDataBinding.h"

@protocol PCScrollViewNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (assign, nonatomic) BOOL pagingEnabled;
@property (assign, nonatomic) BOOL userScrollEnabled;
@property (assign, nonatomic) CGFloat maximumZoomScale;
@property (assign, nonatomic) CGFloat minimumZoomScale;
@property (assign, nonatomic) CGFloat zoomScale;

- (void)addScrollHandler:(JSValue *)handler;

@end

@interface PCScrollViewNode (JSExport) <PCScrollViewNodeExport>

@end
