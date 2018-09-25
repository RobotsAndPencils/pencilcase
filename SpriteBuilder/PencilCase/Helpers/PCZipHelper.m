//
//  PCZipHelper.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-15.
//
//

#import "PCZipHelper.h"

@implementation PCZipHelper

+ (void)unzipFileAtPath:(NSString *)absoluteSourceZipPath toPath:(NSString *)absoluteDestinationPath {
    NSTask *zipTask = [[NSTask alloc] init];
    [zipTask setCurrentDirectoryPath:absoluteDestinationPath];
    [zipTask setLaunchPath:@"/usr/bin/unzip"];

    zipTask.arguments = @[@"-o", absoluteSourceZipPath];
    [zipTask launch];
    [zipTask waitUntilExit];
}

@end
