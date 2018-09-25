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

#import "ResolutionSettingsWindow.h"
#import "PCDeviceResolutionSettings.h"

@implementation ResolutionSettingsWindow

@synthesize resolutions;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    predefinedResolutions = [[NSMutableArray alloc] init];
    
    // iOS
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingIPhone]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingIPhoneLandscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingIPhonePortrait]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingIPhone5Landscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingIPhone5Portrait]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingIPad]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingIPadLandscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingIPadPortrait]];
    
    // Android
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidXSmall]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidXSmallLandscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidXSmallPortrait]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidSmall]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidSmallLandscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidSmallPortrait]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidMedium]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidMediumLandscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidMediumPortrait]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidLarge]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidLargeLandscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidLargePortrait]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidXLarge]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidXLargeLandscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingAndroidXLargePortrait]];
    
    // HTML 5
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingHTML5]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingHTML5Landscape]];
    [predefinedResolutions addObject:[PCDeviceResolutionSettings settingHTML5Portrait]];
    
    int i = 0;
    for (PCDeviceResolutionSettings* setting in predefinedResolutions)
    {
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:setting.name action:@selector(addPredefined:) keyEquivalent:@""];
        item.target = self;
        item.tag = i;
        [addPredefinedPopup.menu addItem:item];
        
        i++;
    }
}

- (void) copyResolutions:(NSMutableArray *)res
{
    resolutions = [NSMutableArray arrayWithCapacity:[res count]];
    
    for (PCDeviceResolutionSettings* resolution in res)
    {
        [resolutions addObject:[resolution copy]];
    }
}

- (BOOL) sheetIsValid
{
    if ([resolutions count] > 0)
    {
        return YES;
    }
    else
    {
        // Display warning!
        NSAlert* alert = [NSAlert alertWithMessageText:@"Missing Resolution" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"You need to have at least one valid resolution setting."];
        [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
        
        return NO;
    }
}

- (void) addPredefined:(id)sender
{
    PCDeviceResolutionSettings* setting = [predefinedResolutions objectAtIndex:[sender tag]];
    [arrayController addObject:setting];
}


@end
