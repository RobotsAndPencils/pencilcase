/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifdef PC_PLATFORM_IOS
#import <UIKit/UIKit.h>		// Needed for UIDevice
#endif

#import "CCConfiguration.h"

@interface CCConfiguration ()

@end

@implementation CCConfiguration

@synthesize maxTextureSize = _maxTextureSize, maxTextureUnits=_maxTextureUnits;
@synthesize supportsPVRTC = _supportsPVRTC;
@synthesize supportsNPOT = _supportsNPOT;
@synthesize supportsBGRA8888 = _supportsBGRA8888;
@synthesize supportsDiscardFramebuffer = _supportsDiscardFramebuffer;
@synthesize supportsShareableVAO = _supportsShareableVAO;
@synthesize OSVersion = _OSVersion;

//
// singleton stuff
//
static CCConfiguration *_sharedConfiguration = nil;

static char * glExtensions;

+ (CCConfiguration *)sharedConfiguration
{
	if (!_sharedConfiguration)
		_sharedConfiguration = [[self alloc] init];

	return _sharedConfiguration;
}

+(id)alloc
{
	NSAssert(_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}


#ifdef PC_PLATFORM_IOS
#elif defined(PC_PLATFORM_MAC)
- (NSString*)getMacVersion
{
    return([[NSProcessInfo processInfo] operatingSystemVersionString]);
}
#endif // PC_PLATFORM_MAC

-(id) init
{
	if( (self=[super init])) {

		// Obtain iOS version
		_OSVersion = 0;
#ifdef PC_PLATFORM_IOS
		NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif defined(PC_PLATFORM_MAC)
		NSString *OSVer = [self getMacVersion];
#endif
		NSArray *arr = [OSVer componentsSeparatedByString:@"."];
		int idx = 0x01000000;
		for( NSString *str in arr ) {
			int value = [str intValue];
			_OSVersion += value * idx;
			idx = idx >> 8;
		}
	}

#if CC_ENABLE_GL_STATE_CACHE == 0
	printf("\n");
	NSLog(@"cocos2d: **** WARNING **** CC_ENABLE_GL_STATE_CACHE is disabled. To improve performance, enable it by editing ccConfig.h");
	printf("\n");
#endif

    return self;
}

- (BOOL) checkForGLExtension:(NSString *)searchName
{
	// For best results, extensionsNames should be stored in your renderer so that it does not
	// need to be recreated on each invocation.
    NSString *extensionsString = [NSString stringWithCString:glExtensions encoding: NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: searchName];
}

// XXX: Optimization: This should be called only once
-(NSInteger) runningDevice
{
	NSInteger ret=-1;
	
#if defined(APPORTABLE)
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		ret = ([UIScreen mainScreen].scale > 1) ? CCDeviceiPadRetinaDisplay : CCDeviceiPad;
	}
	else if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
	{
		if( [UIScreen mainScreen].scale > 1 ) {
			ret = CCDeviceiPhoneRetinaDisplay;
		} else
			ret = CCDeviceiPhone;
	}
#elif defined(PC_PLATFORM_IOS)
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		ret = ([UIScreen mainScreen].scale == 2) ? CCDeviceiPadRetinaDisplay : CCDeviceiPad;
	}
	else if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
	{
		// From http://stackoverflow.com/a/12535566
		BOOL isiPhone5 = CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));
		
		if( [UIScreen mainScreen].scale == 2 ) {
			ret = isiPhone5 ? CCDeviceiPhone5RetinaDisplay : CCDeviceiPhoneRetinaDisplay;
		} else
			ret = isiPhone5 ? CCDeviceiPhone5 : CCDeviceiPhone;
	}
	
#elif defined(PC_PLATFORM_MAC)
	
	// XXX: Add here support for Mac Retina Display
	ret = CCDeviceMac;
	
#endif // PC_PLATFORM_MAC
	
	return ret;
}

@end
