//
//  PCControl+JSExport.h
//  PCPlayer
//
//  Created by Brandon on 2/5/2014.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@import JavaScriptCore;
#import "PCControl.h"
#import "NSObject+JSDataBinding.h"

@protocol PCControlExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic,assign) PCControlState state;
@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,assign) BOOL selected;
@property (nonatomic,assign) BOOL highlighted;
@property (nonatomic,assign) BOOL continuous;
@property (nonatomic,readonly) BOOL tracking;
@property (nonatomic,readonly) BOOL touchInside;

@end

@interface PCControl (JSExport) <PCControlExport>

@end
