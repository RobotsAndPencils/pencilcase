//
//  CCBTypes.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-09-02.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#ifndef PCPlayer_CCBTypes_h
#define PCPlayer_CCBTypes_h

// XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
//! Vertical text alignment type
typedef NS_ENUM(NSUInteger, CCVerticalTextAlignment)
{
    CCVerticalTextAlignmentTop,
    CCVerticalTextAlignmentCenter,
    CCVerticalTextAlignmentBottom,
};

// XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
//! Horizontal text alignment type
typedef NS_ENUM(unsigned char, CCTextAlignment)
{
    CCTextAlignmentLeft,
    CCTextAlignmentCenter,
    CCTextAlignmentRight,
};

#endif
