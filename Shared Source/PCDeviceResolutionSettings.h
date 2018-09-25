/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCDeviceTargetType) {
    PCDeviceTargetTypePhone = 0,
    PCDeviceTargetTypeTablet
};

typedef NS_ENUM(NSInteger, PCDeviceTargetOrientation) {
    PCDeviceTargetOrientationLandscape = 0,
    PCDeviceTargetOrientationPortrait
};

typedef NS_ENUM(NSInteger, PCDesignTarget) {
    PCDesignTargetFlexible = 0,
    PCDesignTargetFixed
};

@interface PCDeviceResolutionSettings : NSObject <NSCopying>

@property (assign, nonatomic) BOOL enabled;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) int width;
@property (assign, nonatomic) int height;
@property (copy, nonatomic) NSString *ext;
@property (assign, nonatomic) float scale;
@property (assign, nonatomic) BOOL centeredOrigin;
@property (strong, nonatomic) NSArray *exts;

@property (assign, nonatomic) PCDeviceTargetType deviceTarget;
@property (assign, nonatomic) PCDeviceTargetOrientation deviceOrientation;
@property (assign, nonatomic) PCDesignTarget designTarget;
@property (assign, nonatomic) NSInteger deviceScaling;

- (CGSize)resolutionForDeviceTarget;
+ (CGSize)resolutionForDeviceTarget:(PCDeviceTargetType)target withOrientation:(PCDeviceTargetOrientation)orientation;
+ (NSString *)stringForPCDeviceTargetType:(PCDeviceTargetType)deviceType;
+ (PCDeviceTargetType)deviceTargetTypeForString:(NSString *)string;
+ (NSString *)stringForPCDeviceTargetOrientation:(PCDeviceTargetOrientation)targetOrientation;

// Fixed resolutions
+ (PCDeviceResolutionSettings *)settingFixed;
+ (PCDeviceResolutionSettings *)settingFixedLandscape;
+ (PCDeviceResolutionSettings *)settingFixedPortrait;

// iOS resolutions
+ (PCDeviceResolutionSettings *)settingIPhone;
+ (PCDeviceResolutionSettings *)settingIPhoneLandscape;
+ (PCDeviceResolutionSettings *)settingIPhonePortrait;
+ (PCDeviceResolutionSettings *)settingIPhone5Landscape;
+ (PCDeviceResolutionSettings *)settingIPhone5Portrait;
+ (PCDeviceResolutionSettings *)settingIPhone6Landscape;
+ (PCDeviceResolutionSettings *)settingIPhone6Portrait;
+ (PCDeviceResolutionSettings *)settingIPhone6PlusLandscape;
+ (PCDeviceResolutionSettings *)settingIPhone6PlusPortrait;
+ (PCDeviceResolutionSettings *)settingIPad;
+ (PCDeviceResolutionSettings *)settingIPadLandscape;
+ (PCDeviceResolutionSettings *)settingIPadPortrait;

// Android resolutions
+ (PCDeviceResolutionSettings *)settingAndroidXSmall;
+ (PCDeviceResolutionSettings *)settingAndroidXSmallLandscape;
+ (PCDeviceResolutionSettings *)settingAndroidXSmallPortrait;
+ (PCDeviceResolutionSettings *)settingAndroidSmall;
+ (PCDeviceResolutionSettings *)settingAndroidSmallLandscape;
+ (PCDeviceResolutionSettings *)settingAndroidSmallPortrait;
+ (PCDeviceResolutionSettings *)settingAndroidMedium;
+ (PCDeviceResolutionSettings *)settingAndroidMediumLandscape;
+ (PCDeviceResolutionSettings *)settingAndroidMediumPortrait;
+ (PCDeviceResolutionSettings *)settingAndroidLarge;
+ (PCDeviceResolutionSettings *)settingAndroidLargeLandscape;
+ (PCDeviceResolutionSettings *)settingAndroidLargePortrait;
+ (PCDeviceResolutionSettings *)settingAndroidXLarge;
+ (PCDeviceResolutionSettings *)settingAndroidXLargeLandscape;
+ (PCDeviceResolutionSettings *)settingAndroidXLargePortrait;

// HTML 5
+ (PCDeviceResolutionSettings *)settingHTML5;
+ (PCDeviceResolutionSettings *)settingHTML5Landscape;
+ (PCDeviceResolutionSettings *)settingHTML5Portrait;

- (id)initWithSerialization:(id)serialization;

- (id)serialize;

@end
