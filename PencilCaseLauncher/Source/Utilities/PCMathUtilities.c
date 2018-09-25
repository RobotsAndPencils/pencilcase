//
//  PCMathUtilities.c
//  PCPlayer
//
//  Created by Cody Rayment on 2014-09-02.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#include "PCMathUtilities.h"

CGFloat pc_clampf(CGFloat value, CGFloat min, CGFloat max) {
    if (min > max) {
        PC_SWAP(min, max);
    }
    return value < min ? min : value < max ? value : max;
}

CGFloat pc_sign(CGFloat f) {
    return (f >= 0 ? 1 : -1);
}
