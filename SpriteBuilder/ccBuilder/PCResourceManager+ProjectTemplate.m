//
//  PCResourceManager+ProjectTemplate.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-15.
//
//

#import "PCResourceManager+ProjectTemplate.h"
#import "PCProjectTemplate.h"
#import "PCZipHelper.h"

@implementation PCResourceManager (ProjectTemplate)

- (void)loadResourcesFromProjectTemplate:(PCProjectTemplate *)projectTemplate forDeviceType:(PCDeviceTargetType)device {
    NSArray *resources = [projectTemplate resourcesForDevice:device];
    NSString *exportDirectory = self.rootResourceDirectory.directoryPath;

    for (NSString *zipFileName in resources) {
        NSString *zippedResourcesFile = [[NSBundle mainBundle] pathForResource:[zipFileName stringByDeletingPathExtension] ofType:[zipFileName pathExtension]];
        [PCZipHelper unzipFileAtPath:zippedResourcesFile toPath:exportDirectory];
    }

    [self addResourcesForFilesInDirectory:exportDirectory];
}

@end
