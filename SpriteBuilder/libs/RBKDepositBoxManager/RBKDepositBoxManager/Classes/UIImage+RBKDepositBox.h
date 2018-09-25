//
//  UIImage+RBKDepositBox.h
//  RBKDepositBoxManager
//
//  Created by Matt KiazykNew on 2013-07-23.
//  Copyright (c) 2013 Robots & Pencils. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RBKDepositBox)

-(UIImage *)resizedImageProportionatelyScaledToSize:(CGSize)newSize;
-(UIImage *)imageByScalingToHeight:(float)i_height;

@end
