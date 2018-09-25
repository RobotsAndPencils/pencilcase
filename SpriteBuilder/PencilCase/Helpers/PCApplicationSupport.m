//
//  PCApplicationSupport.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-20.
//
//

#import "PCApplicationSupport.h"

@implementation PCApplicationSupport

+ (NSString *)deviceIdentifierApplicationSupportFilePath {
    return [[PCApplicationSupport pencilCaseApplicationSupportDirectoryPath] stringByAppendingPathComponent:@"device"];
}

+ (NSString *)defaultProjectPath {
    NSString *defaultProjectPath = [[PCApplicationSupport pencilCaseApplicationSupportDirectoryPath] stringByAppendingPathComponent:@"DefaultProjects"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:defaultProjectPath isDirectory:&isDirectory]) {
        if (![fileManager createDirectoryAtPath:defaultProjectPath withIntermediateDirectories:YES attributes:nil error:NULL]) {
            PCLog(@"Error: Create folder failed %@", defaultProjectPath);
        }
    }
    return defaultProjectPath;
}

+ (NSString *)pencilCaseApplicationSupportDirectoryPath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *pencilCaseApplicationSupportPath = [path firstObject];

    // A User-Defined Setting with the key APPLICATION_SUPPORT_SUBFOLDER, exposed in info.plist as "Application Support Subfolder"
    NSString *applicationSupportSubfolder = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Application Support Subfolder"];
    if (PCIsEmpty(applicationSupportSubfolder)) {
        applicationSupportSubfolder = @"PencilCase";
    }
    pencilCaseApplicationSupportPath = [pencilCaseApplicationSupportPath stringByAppendingPathComponent:applicationSupportSubfolder];

    BOOL isDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:pencilCaseApplicationSupportPath isDirectory:&isDirectory]) {
        if (![fileManager createDirectoryAtPath:pencilCaseApplicationSupportPath withIntermediateDirectories:YES attributes:nil error:NULL]) {
            PCLog(@"Error: Create folder failed %@", pencilCaseApplicationSupportPath);
        }
    }
    return pencilCaseApplicationSupportPath;
}

@end
