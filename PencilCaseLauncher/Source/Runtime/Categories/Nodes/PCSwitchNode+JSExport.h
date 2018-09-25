//
//  PCSwitchNode+JSExport.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-11.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCSwitchNode.h"
#import "NSObject+JSDataBinding.h"

@protocol PCSwitchNodeExport <JSExport, NSObjectJSDataBindingExport>

@property (assign, nonatomic) BOOL isOn;

@end

@interface PCSwitchNode (JSExport) <PCSwitchNodeExport>

@end
