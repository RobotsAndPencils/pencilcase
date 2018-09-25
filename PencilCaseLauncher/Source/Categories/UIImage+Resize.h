//
//  UIImage+Resize.h
//  Pods
//
//  Created by Stephen Gazzard on 2015-10-19.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

/**
 Aspect confines an image to the size passed in
 @param size The size, in points (will be converted to pixels internally)
 */
- (UIImage *)pc_imageAspectConfinedToSize:(CGSize)size;

@end
