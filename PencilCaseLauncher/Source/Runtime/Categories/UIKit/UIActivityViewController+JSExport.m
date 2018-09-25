//
//  UIActivityViewController+JSExport.m
//  PCPlayer
//
//  Created by Michael Beauregard on 2015-02-23.
//  Copyright (c) 2015 Robots and Pencils Inc. All rights reserved.
//

#import "UIActivityViewController+JSExport.h"
#import "UIActivityViewController+PCShare.h"
#import "PCOverlayView.h"

@implementation UIActivityViewController (JSExport)

+ (UIActivityViewController *)shareScreenCaptureFrom:(SKNode *)node completion:(JSValue *)completionFunction {
    PCOverlayView *overlayView = [PCOverlayView overlayView];
    CGRect rect = [overlayView rectForPopoverOriginatingFromNode:node];
    return [UIActivityViewController pc_shareScreenCapturePresentedFromRect:rect inView:overlayView completionHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if (completionFunction) {
            [completionFunction callWithArguments:@[activityType ?: @"", @(completed), returnedItems ?: @[], activityError ?: @""]];
        }
    }];
}

@end
