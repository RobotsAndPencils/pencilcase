//
//  PCResourceDirectory+Migration.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-20.
//
//

#import "PCResourceManager+Migration.h"
#import "PCResourceManagerDictionaryKeys.h"

@implementation PCResourceManager (Migration)

- (void)migrateDirectoriesFromProjectSettingsDictionary:(NSDictionary *)projectSettingsDictionary {
    NSData *rawResourcesData = projectSettingsDictionary[@"resourcesRaw"];
    NSData *activeResourcesData = projectSettingsDictionary[@"resourcesActive"];
    if (!rawResourcesData || !activeResourcesData) return;

    NSDictionary *directories = [NSKeyedUnarchiver unarchiveObjectWithData:rawResourcesData];
    NSArray *activeDirectories = [NSKeyedUnarchiver unarchiveObjectWithData:activeResourcesData];
    NSString *rootDirectory = [activeDirectories firstObject];
    NSString *rootResourceDirectory = [rootDirectory stringByAppendingPathComponent:PCResourceFolderName];
    [self loadFromLocalDirectories:directories localRootDirectory:rootDirectory localRootResourceDirectory:rootResourceDirectory];
}

#pragma mark - Dictionary migration

+ (NSDictionary *)migrateResourceDictionaryFrom:(NSDictionary *)dictionary {
    NSMutableDictionary *result = [dictionary mutableCopy];
    [self upgradeDictionaryFromV0_1_9ToV0_1_10:result];
    return [result copy];
}

+ (void)upgradeDictionaryFromV0_1_9ToV0_1_10:(NSMutableDictionary *)dictionary {
    NSArray *activeDirectories = dictionary[PCActiveDirectoriesKey];
    if (!activeDirectories) return;

    [dictionary removeObjectForKey:PCActiveDirectoriesKey];
    NSString *rootDirectory = [activeDirectories firstObject];
    NSString *rootResourceDirectory = [rootDirectory stringByAppendingPathComponent:PCResourceFolderName];
    dictionary[PCRootDirectoryKey] = rootDirectory;
    dictionary[PCRootResourceDirectoryKey] = rootResourceDirectory;
}

@end
