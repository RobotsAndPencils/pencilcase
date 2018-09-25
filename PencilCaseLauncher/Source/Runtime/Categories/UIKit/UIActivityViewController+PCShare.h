//
//  UIActivityViewController+PCShare.h
//  PCPlayer
//
//  Created by Michael Beauregard on 2015-02-23.
//  Copyright (c) 2015 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import <UIKit/UIKit.h>

@interface UIActivityViewController (PCShare)

+ (UIActivityViewController *)pc_shareScreenCapturePresentedFromRect:(CGRect)fromRect inView:(UIView *)inView completionHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionHandler;

@end
