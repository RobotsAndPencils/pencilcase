//
//  CGSizeUtilities.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-03-24.
//
//

#ifndef __SpriteBuilder__CGSizeUtilities__
#define __SpriteBuilder__CGSizeUtilities__

#import <CoreGraphics/CGGeometry.h>
#include <math.h>

static inline CGSize pc_CGSizeIntegral(const CGSize size) {
    return CGSizeMake(round(size.width), round(size.height));
}

#endif /* defined(__SpriteBuilder__CGSizeUtilities__) */
