//
//  UIActivityViewController+JSExport.h
//  PCPlayer
//
//  Created by Michael Beauregard on 2015-02-23.
//  Copyright (c) 2015 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import <UIKit/UIKit.h>

@protocol UIActivityViewControllerExport <JSExport>

JSExportAs(shareScreenCapture,
+ (UIActivityViewController *)shareScreenCaptureFrom:(SKNode *)node completion:(JSValue *)completionFunction
);

@end

@interface UIActivityViewController (JSExport) <UIActivityViewControllerExport>

@end
