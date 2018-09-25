//
//  UIImage+Orientation.h
//
//
//  Created by Michael Beauregard on 2015-04-07.
//
//

#import <UIKit/UIKit.h>

/**
 * Fixes the orientation of an image captured by the camera. See http://stackoverflow.com/a/5427890/516581
 */
@interface UIImage (Orientation)

- (UIImage *)rotatedToOrientationUp;

@end
