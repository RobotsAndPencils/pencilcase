//
//  PCShareButton.m
//  PCPlayer
//
//  Created by Brendan Duddridge on 2014-03-15.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCShareButton.h"
#import "PCOverlayView.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "PCAppViewController.h"

@interface PCShareButton()
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation PCShareButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setTarget:self selector:@selector(displaySharePanel:)];
    }
    return self;
}

- (void)displaySharePanel:(id)sender {
	UIImage *shareImage = [self screenshot];
	
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareImage] applicationActivities:nil];
	activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    CGRect rect = (CGRect){ self.frame.origin, self.contentSize };
    rect = [[PCOverlayView overlayView] convertRect:rect toOverlayViewFromNode:self willAdjustAnchorPointOfView:NO];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[PCAppViewController lastCreatedInstance] presentViewController:activityViewController animated:YES completion:nil];
    } else {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [self.popoverController presentPopoverFromRect:rect
                                                inView:[PCOverlayView overlayView]
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:YES];
    }
}

// Capture a screenshot:
// http://stackoverflow.com/questions/7964153/ios-whats-the-fastest-most-performant-way-to-make-a-screenshot-programaticall
- (UIImage *)screenshot {
    UIView *view = self.pc_scene.view;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
