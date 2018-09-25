//
//  UIImage+Resize.m
//  Pods
//
//  Created by Stephen Gazzard on 2015-10-19.
//
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)pc_imageAspectConfinedToSize:(CGSize)size {
    if (self.size.width <= size.width && self.size.height <= size.height) return self;

    CGSize targetSize;
    if (self.size.width > self.size.height) {
        targetSize.width = size.width;
        targetSize.height = (size.width / self.size.width) * self.size.height;
    } else {
        targetSize.height = size.height;
        targetSize.width = (size.height / self.size.height) * self.size.width;
    }

    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
