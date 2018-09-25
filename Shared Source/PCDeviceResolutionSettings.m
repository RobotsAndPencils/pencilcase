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

#import "PCDeviceResolutionSettings.h"

@implementation PCDeviceResolutionSettings

- (id)init {
    self = [super init];
    if (!self) return NULL;

    _enabled = NO;
    self.name = @"Custom";
    self.width = 1000;
    self.height = 1000;
    self.ext = @" ";
    self.scale = 1;

    return self;
}

- (id)initWithSerialization:(id)serialization {
    self = [self init];
    if (!self) return NULL;

    self.enabled = YES;
    self.name = serialization[@"name"];
    self.width = [serialization[@"width"] intValue];
    self.height = [serialization[@"height"] intValue];
    self.ext = serialization[@"ext"];
    self.scale = [serialization[@"scale"] floatValue];
    self.centeredOrigin = [serialization[@"centeredOrigin"] boolValue];
    return self;
}

- (void)setScale:(float)scale {
    NSAssert(scale > 0.0, @"scale must be positive.");
    _scale = scale;
}

- (id)serialize {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    dict[@"name"] = self.name;
    dict[@"width"] = @(self.width);
    dict[@"height"] = @(self.height);
    dict[@"ext"] = self.ext;
    dict[@"scale"] = @(self.scale);
    dict[@"centeredOrigin"] = @(self.centeredOrigin);
    return dict;
}

- (void)setExt:(NSString *)extension {

    _ext = [extension copy];

    if (!extension || [extension isEqualToString:@" "] || [extension isEqualToString:@""]) {
        self.exts = [[NSArray alloc] init];
    }
    else {
        _exts = [extension componentsSeparatedByString:@" "];
    }
}

- (void)dealloc {
    self.ext = NULL;
}

- (CGSize)resolutionForDeviceTarget {
    return [PCDeviceResolutionSettings resolutionForDeviceTarget:self.deviceTarget withOrientation:self.deviceOrientation];
}

+ (CGSize)resolutionForDeviceTarget:(PCDeviceTargetType)target withOrientation:(PCDeviceTargetOrientation)orientation {
    switch (target) {
        case PCDeviceTargetTypePhone:
            if (orientation == PCDeviceTargetOrientationPortrait) {
                return [PCDeviceResolutionSettings phonePortraitResolution];
            } else {
                return [PCDeviceResolutionSettings phoneLandscapeResolution];
            }
        case PCDeviceTargetTypeTablet:
        default:
            if (orientation == PCDeviceTargetOrientationPortrait) {
                return [PCDeviceResolutionSettings tabletPortraitResolution];
            } else {
                return [PCDeviceResolutionSettings tabletLandscapeResolution];
            }
    }
}

+ (CGSize)phonePortraitResolution {
    PCDeviceResolutionSettings *iPhone6PlusPortrait = [PCDeviceResolutionSettings settingIPhone6PlusPortrait];
    return CGSizeMake(iPhone6PlusPortrait.width, iPhone6PlusPortrait.height);
}

+ (CGSize)phoneLandscapeResolution {
    PCDeviceResolutionSettings *iPhone6PlusLandscape = [PCDeviceResolutionSettings settingIPhone6PlusLandscape];
    return CGSizeMake(iPhone6PlusLandscape.width, iPhone6PlusLandscape.height);
}

+ (CGSize)tabletPortraitResolution {
    PCDeviceResolutionSettings *iPadPortrait = [PCDeviceResolutionSettings settingIPadPortrait];
    return CGSizeMake(iPadPortrait.width, iPadPortrait.height);
}

+ (CGSize)tabletLandscapeResolution {
    PCDeviceResolutionSettings *iPadLandscape = [PCDeviceResolutionSettings settingIPadLandscape];
    return CGSizeMake(iPadLandscape.width, iPadLandscape.height);
}

+ (NSString *)stringForPCDeviceTargetType:(PCDeviceTargetType)deviceType {
    switch (deviceType) {
        case PCDeviceTargetTypePhone:
            return @"iPhone";
        case PCDeviceTargetTypeTablet:
        default:
            return @"iPad";
    }
}

+ (PCDeviceTargetType)deviceTargetTypeForString:(NSString *)string {
    if ([string isEqual:@"iPad"]) {
        return PCDeviceTargetTypeTablet;
    }
    return PCDeviceTargetTypePhone;
}

+ (NSString *)stringForPCDeviceTargetOrientation:(PCDeviceTargetOrientation)targetOrientation {
    switch (targetOrientation) {
        case PCDeviceTargetOrientationPortrait:
            return @"Portrait";
        case PCDeviceTargetOrientationLandscape:
        default:
            return @"Landscape";
    }
}

+ (PCDeviceResolutionSettings *)settingFixed {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"Fixed";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"tablet phonehd";
    setting.scale = 2;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingFixedLandscape {
    PCDeviceResolutionSettings *setting = [self settingFixed];

    setting.name = @"Fixed Landscape";
    setting.width = 568;
    setting.height = 384;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingFixedPortrait {
    PCDeviceResolutionSettings *setting = [self settingFixed];

    setting.name = @"Fixed Portrait";
    setting.width = 384;
    setting.height = 568;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhone {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"Phone";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.scale = 1;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhoneLandscape {
    PCDeviceResolutionSettings *setting = [self settingIPhone];

    setting.name = @"Phone Landscape (short)";
    setting.width = 480;
    setting.height = 320;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhonePortrait {
    PCDeviceResolutionSettings *setting = [self settingIPhone];

    setting.name = @"iPhone Portrait (short)";
    setting.width = 320;
    setting.height = 480;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhone5Landscape {
    PCDeviceResolutionSettings *setting = [self settingIPhone];

    setting.name = @"Phone Landscape";
    setting.width = 568;
    setting.height = 320;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhone5Portrait {
    PCDeviceResolutionSettings *setting = [self settingIPhone];

    setting.name = @"Phone Portrait";
    setting.width = 320;
    setting.height = 568;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhone6Portrait {
    PCDeviceResolutionSettings *setting = [self settingIPhone];
    setting.name = @"Phone 6 Portrait";
    setting.width = 375;
    setting.height = 667;
    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhone6Landscape {
    PCDeviceResolutionSettings *setting = [self settingIPhone];
    setting.name = @"Phone 6 Landscape";
    setting.width = 667;
    setting.height = 375;
    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhone6PlusPortrait {
    PCDeviceResolutionSettings *setting = [self settingIPhone];
    setting.name = @"Phone 6 Plus Portrait";
    setting.width = 414;
    setting.height = 736;
    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPhone6PlusLandscape {
    PCDeviceResolutionSettings *setting = [self settingIPhone];
    setting.name = @"Phone 6 Plus Landscape";
    setting.width = 736;
    setting.height = 414;
    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPad {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"Tablet";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"tablet phonehd";
    setting.scale = 2;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPadLandscape {
    PCDeviceResolutionSettings *setting = [self settingIPad];

    setting.name = @"Tablet Landscape";
    setting.width = 1024;
    setting.height = 768;
    setting.scale = 1;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingIPadPortrait {
    PCDeviceResolutionSettings *setting = [self settingIPad];

    setting.name = @"Tablet Portrait";
    setting.width = 768;
    setting.height = 1024;
    setting.scale = 1;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidXSmall {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"Android X-Small";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.scale = 0.5;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidXSmallLandscape {
    PCDeviceResolutionSettings *setting = [self settingAndroidXSmall];

    setting.name = @"Android X-Small Landscape";
    setting.width = 320;
    setting.height = 240;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidXSmallPortrait {
    PCDeviceResolutionSettings *setting = [self settingAndroidXSmall];

    setting.name = @"Android X-Small Portrait";
    setting.width = 240;
    setting.height = 320;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidSmall {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"Android Small";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.scale = 1;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidSmallLandscape {
    PCDeviceResolutionSettings *setting = [self settingAndroidSmall];

    setting.name = @"Android Small Landscape";
    setting.width = 480;
    setting.height = 340;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidSmallPortrait {
    PCDeviceResolutionSettings *setting = [self settingAndroidSmall];

    setting.name = @"Android Small Portrait";
    setting.width = 340;
    setting.height = 480;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidMedium {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"Android Medium";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.scale = 1.5;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidMediumLandscape {
    PCDeviceResolutionSettings *setting = [self settingAndroidMedium];

    setting.name = @"Android Medium Landscape";
    setting.width = 800;
    setting.height = 480;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidMediumPortrait {
    PCDeviceResolutionSettings *setting = [self settingAndroidMedium];

    setting.name = @"Android Medium Portrait";
    setting.width = 480;
    setting.height = 800;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidLarge {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"Android Large";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phonehd";
    setting.scale = 2;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidLargeLandscape {
    PCDeviceResolutionSettings *setting = [self settingAndroidLarge];

    setting.name = @"Android Large Landscape";
    setting.width = 1280;
    setting.height = 800;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidLargePortrait {
    PCDeviceResolutionSettings *setting = [self settingAndroidLarge];

    setting.name = @"Android Large Portrait";
    setting.width = 800;
    setting.height = 1280;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidXLarge {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"Android X-Large";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"tablethd";
    setting.scale = 4;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidXLargeLandscape {
    PCDeviceResolutionSettings *setting = [self settingAndroidXLarge];

    setting.name = @"Android X-Large Landscape";
    setting.width = 2048;
    setting.height = 1536;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingAndroidXLargePortrait {
    PCDeviceResolutionSettings *setting = [self settingAndroidXLarge];

    setting.name = @"Android X-Large Portrait";
    setting.width = 1536;
    setting.height = 2048;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingHTML5 {
    PCDeviceResolutionSettings *setting = [[PCDeviceResolutionSettings alloc] init];

    setting.name = @"HTML 5";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"html5";
    setting.scale = 2;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingHTML5Landscape {
    PCDeviceResolutionSettings *setting = [self settingHTML5];

    setting.name = @"HTML 5 Landscape";
    setting.width = 1024;
    setting.height = 768;

    return setting;
}

+ (PCDeviceResolutionSettings *)settingHTML5Portrait {
    PCDeviceResolutionSettings *setting = [self settingHTML5];

    setting.name = @"HTML 5 Portrait";
    setting.width = 768;
    setting.height = 1024;

    return setting;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ <0x%x> (%d x %d)", NSStringFromClass([self class]), (unsigned int)self, self.width, self.height];
}

- (id)copyWithZone:(NSZone *)zone {
    PCDeviceResolutionSettings *copy = [[PCDeviceResolutionSettings alloc] init];

    copy.enabled = self.enabled;
    copy.name = self.name;
    copy.width = self.width;
    copy.height = self.height;
    copy.ext = self.ext;
    copy.scale = self.scale;
    copy.centeredOrigin = self.centeredOrigin;

    return copy;
}

@end
