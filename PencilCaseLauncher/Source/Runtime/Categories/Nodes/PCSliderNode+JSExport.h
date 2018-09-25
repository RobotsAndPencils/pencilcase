//
//  PCSlideNode+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-12.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCSliderNode.h"
#import "NSObject+JSDataBinding.h"

@protocol PCSliderNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (assign, nonatomic) CGFloat minimumValue;
@property (assign, nonatomic) CGFloat maximumValue;
@property (assign, nonatomic) CGFloat currentValue;

@end


@interface PCSliderNode (JSExport) <PCSliderNodeExport>

@end
