//
//  PCMathUtilities.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-09-02.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#ifndef __PCPlayer__PCMathUtilities__
#define __PCPlayer__PCMathUtilities__

#include <stdio.h>
#import <CoreGraphics/CGGeometry.h>

#define PC_SWAP(a, b) ({ __typeof__(a) t = (a); a = b; b = t; })

CGFloat pc_clampf(CGFloat value, CGFloat min, CGFloat max);

CGFloat pc_sign(CGFloat f);

#endif /* defined(__PCPlayer__PCMathUtilities__) */
