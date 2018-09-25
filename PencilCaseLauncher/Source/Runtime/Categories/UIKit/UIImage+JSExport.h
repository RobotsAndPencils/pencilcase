//
//  UIColor+JSExport.h
//  PencilCaseJSDemo
//
//  Created by Brandon on 1/6/2014.
//  Copyright (c) 2014 RobotsAndPencils. All rights reserved.
//

@import UIKit;
@import JavaScriptCore;
#import "NSObject+JSDataBinding.h"

@protocol UIImageExport <JSExport, NSObjectJSDataBindingExport>

+ (instancetype)imageWithUUID:(NSString *)uuid;
+ (instancetype)imageWithRelativeImagePath:(NSString *)relativePath;

@end

@interface UIImage (JSExport) <UIImageExport>

@end
