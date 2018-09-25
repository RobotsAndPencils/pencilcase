//
//  PCForceNode+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-03-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCForceNode.h"
#import "NSObject+JSDataBinding.h"

@protocol PCForceNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL drawArrow;

@end

@interface PCForceNode (JSExport) <PCForceNodeExport>

@end
