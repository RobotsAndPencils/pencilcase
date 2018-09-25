//
//  PCUserProjectDocument.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-16.
//
//

#import "PCUserProjectDocument.h"

@implementation PCUserProjectDocument

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    _isFavorite = [[aDecoder decodeObjectForKey:@"favorite"] boolValue];
    NSData *documentUrlData = [aDecoder decodeObjectForKey:@"documentURL"];
    NSURL *projectUrl = [NSURL URLByResolvingBookmarkData:documentUrlData options:NSURLBookmarkResolutionWithoutUI relativeToURL:NULL bookmarkDataIsStale:NO error:NULL];
    if (projectUrl == nil) return self;
    _userProjectReferenceUrl = projectUrl;
    [self setupProjectInfo:projectUrl];
    return self;
}

- (id)initWithProjectURL:(NSURL *)projectUrl isFavorite:(BOOL)isfavorite {
    self = [super init];
    if (self) {
        _userProjectReferenceUrl = projectUrl;
        _isFavorite = isfavorite;
        [self setupProjectInfo:projectUrl];
    }
    return self;
}

- (void)setupProjectInfo:(NSURL *)projectUrl {
    NSURL *projectFileUrl = [self findProjectPath:projectUrl];
    _projectName = [[projectUrl lastPathComponent] stringByDeletingPathExtension];
    NSDictionary *recentFile = [[NSDictionary alloc] initWithContentsOfURL:projectFileUrl];
    NSDate *fileDate;
    [projectUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:nil];
    _modificationDate = fileDate;

    if (recentFile[@"deviceTarget"]) {
        _deviceTarget = [recentFile[@"deviceTarget"] intValue];
    } else {
        _deviceTarget = PCDeviceTargetTypeTablet;
    }
    if (recentFile[@"appIconRetinaImage"]) {
        NSImage *appIcon = [[NSImage alloc] initWithData:recentFile[@"appIconRetinaImage"]];
        _projectAppIcon = appIcon;
    } else if (recentFile[@"appIconImage"]) {
        NSImage *appIcon = [[NSImage alloc] initWithData:recentFile[@"appIconImage"]];
        _projectAppIcon = appIcon;
    } else {
        if (_deviceTarget == PCDeviceTargetTypePhone) {
            _projectAppIcon = [NSImage imageNamed:@"Iphone_Base"];
        } else {
            _projectAppIcon = [NSImage imageNamed:@"Ipad_Base"];
        }
    }
}

- (NSURL *)findProjectPath:(NSURL *)documentUrl {
    NSURL *projectFile = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentUrl.path error:NULL];
    for (NSString *file in files) {
        if ([file hasSuffix:@".ccbproj"]) {
            projectFile = [documentUrl URLByAppendingPathComponent:file];
            break;
        }
    }
    return projectFile;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithBool:self.isFavorite] forKey:@"favorite"];

    NSURL *projectPackageURL = [self.userProjectReferenceUrl URLByDeletingLastPathComponent];
    NSURL *projectPath = self.userProjectReferenceUrl;
    NSError *error;
    NSData *projectFileBookmarkData = [projectPath bookmarkDataWithOptions:NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess includingResourceValuesForKeys:nil relativeToURL:projectPackageURL error:&error];
    if (!projectFileBookmarkData) {
        PCLog(@"Error creating project file bookmark data: %@", error);
    }
    else {
        [aCoder encodeObject:projectFileBookmarkData forKey:@"documentURL"];
    }
}

@end
