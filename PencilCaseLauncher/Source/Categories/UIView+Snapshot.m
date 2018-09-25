//
//  UIView+Snapshot.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2015-02-23.
//
//

#import "UIView+Snapshot.h"

@implementation UIView (Snapshot)

- (UIImage *)pc_snapshotAfterScreenUpdates:(BOOL)afterScreenUpdates {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);

    // if the transform of the current view is flipped, make sure to flip the render context as well
    if (self.transform.d == -1) {
        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), flipVertical);
    }

    BOOL wasHidden = self.hidden;
    self.hidden = NO;
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.hidden = wasHidden;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
