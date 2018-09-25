//
//  UIImage+RBKDepositBox.m
//  RBKDepositBoxManager
//
//  Created by Matt KiazykNew on 2013-07-23.
//  Copyright (c) 2013 Robots & Pencils. All rights reserved.
//

#import "UIImage+RBKDepositBox.h"

@implementation UIImage (RBKDepositBox)

// DWA: consider BOSImageResizeOperation

- (UIImage *)resizedImageProportionatelyScaledToSize:(CGSize)newSize
{
    CGFloat heightRatio = self.size.height / newSize.height;
    CGFloat widthRatio = self.size.width / newSize.width;
    CGFloat ratio = heightRatio > widthRatio? heightRatio : widthRatio;
    UIGraphicsBeginImageContext(newSize);
    CGFloat scaledWidth = self.size.width/ratio;
    CGFloat scaledHeight = self.size.height/ratio;
    [self drawInRect:CGRectMake(floorf((newSize.width - scaledWidth)/2.0f), floorf((newSize.height - scaledHeight)/2.0), scaledWidth, scaledHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage*)imageByScalingToHeight:(float)i_height
{
    float oldHeight = self.size.height;
    float scaleFactor = i_height / oldHeight;
    
    float newWidth = self.size.width * scaleFactor;
    float newHeight = i_height;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
