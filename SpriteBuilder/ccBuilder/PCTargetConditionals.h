//
//  PCTargetConditionals.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-10.
//
//

#ifndef SpriteBuilder_PCTargetConditionals_h
#define SpriteBuilder_PCTargetConditionals_h

#import "TargetConditionals.h"

// Platform defines. TARGET_OS_MAC is defined on iOS so this makes it easier to detect iOS.
#if TARGET_IPHONE_SIMULATOR
    #define PC_PLATFORM_IOS
#elif TARGET_OS_IPHONE
    #define PC_PLATFORM_IOS
#elif TARGET_OS_MAC
    #define PC_PLATFORM_MAC
#endif

#endif
