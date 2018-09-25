//
//  PCReader.m
//  PCPlayer
//
//  Created by Brandon on 2/20/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCReader.h"
#import "CCFileUtils.h"

@implementation PCReader

+ (void)configureCCFileUtilsWithURL:(NSURL *)url {
    if (!url) return;

    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils purgeCachedEntries];

    // Setup file utils for use with SpriteBuilder
    [sharedFileUtils setEnableiPhoneResourcesOniPad:NO];

    sharedFileUtils.directoriesDict =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     @"resources-tablet", CCFileUtilsSuffixiPad,
     @"resources-tablethd", CCFileUtilsSuffixiPadHD,
     @"resources-phone", CCFileUtilsSuffixiPhone,
     @"resources-phonehd", CCFileUtilsSuffixiPhoneHD,
     @"resources-phone", CCFileUtilsSuffixiPhone5,
     @"resources-phonehd", CCFileUtilsSuffixiPhone5HD,
     @"resources-phone3x", CCFileUtilsSuffixiPhone3x,
     @"", CCFileUtilsSuffixDefault,
     nil];

    // These need to be changed here before loading the filename and spriteframe lookups
    sharedFileUtils.searchPath = @[[url path], [[NSBundle mainBundle] resourcePath]];

	sharedFileUtils.enableiPhoneResourcesOniPad = YES;
    sharedFileUtils.searchMode = CCFileUtilsSearchModeDirectory;
    [sharedFileUtils buildSearchResolutionsOrder];

    [sharedFileUtils loadFilenameLookupDictionaryFromFile:@"fileLookup.plist"];
}

@end
