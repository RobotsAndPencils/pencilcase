//
//  PCResourceDirectory+Migration.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-20.
//
//

#import "PCResourceManager.h"

@interface PCResourceManager (Migration)


/**
 In version 0.1.8 of the application, resource manager settings were stored in the project settings. As of 0.1.9,
 it is instead stored in its own file. This handles that migration when necessary.
 @param projectSettingsDictionary The dictionary loaded from the ccbproj file
 */
- (void)migrateDirectoriesFromProjectSettingsDictionary:(NSDictionary *)projectSettingsDictionary;

/**
 Helper method that takes any version of the PCResourceManager dictionary and, step by step, upgrades
 it to the latest version of the dictionary, so that when the PCResourceManager consumes it, it contains
 all the keys and fields necessary for the PCResourceManager to fully initialise itself.
 @param dictionary The dictionary to migrate. This dictionary will be left untouched.
 @returns The migrated dictionary, as a new dictionary.
 */
+ (NSDictionary *)migrateResourceDictionaryFrom:(NSDictionary *)dictionary;

#pragma mark - Private
/*
 These methods are only exposed for unit testing purposes (it felt odd to have a second category on PCResourceManager
 for private methods on another category */
+ (void)upgradeDictionaryFromV0_1_9ToV0_1_10:(NSMutableDictionary *)dictionary;

@end
