//
//  UIActivityViewController+PCShare.m
//  PCPlayer
//
//  Created by Michael Beauregard on 2015-02-23.
//  Copyright (c) 2015 Robots and Pencils Inc. All rights reserved.
//

#import "UIActivityViewController+PCShare.h"
#import "PCAppViewController.h"

@implementation UIActivityViewController (PCShare)

+ (UIActivityViewController *)pc_shareScreenCapturePresentedFromRect:(CGRect)fromRect inView:(UIView *)inView completionHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionHandler {
    UIImage *shareImage = [self pc_screenshot];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareImage] applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    activityViewController.completionWithItemsHandler = completionHandler;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        PCAppViewController *controller = [PCAppViewController lastCreatedInstance];
        [controller presentViewController:activityViewController animated:YES completion:nil];
    } else {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popoverController presentPopoverFromRect:fromRect
                                           inView:inView
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }

    return activityViewController;
}

// Capture a screenshot:
// http://stackoverflow.com/questions/7964153/ios-whats-the-fastest-most-performant-way-to-make-a-screenshot-programaticall
+ (UIImage *)pc_screenshot {
    UIView *view = [PCAppViewController lastCreatedInstance].spriteKitView;
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
