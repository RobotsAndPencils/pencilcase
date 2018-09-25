//
//  UIAlertView+JSExport.h
//  PCPlayer
//
//  Created by Brandon on 2014-03-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import <UIKit/UIKit.h>
#import "NSObject+JSDataBinding.h"

@protocol UIAlertViewExport <JSExport, NSObjectJSDataBindingExport>

JSExportAs(showAlert,
+ (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(JSValue *)completionFunction
);

@end

@interface UIAlertView (JSExport) <UIAlertViewExport>

+ (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(JSValue *)completionFunction ;

@end
