//
//  PCKeyValueStoreKeyConfigStore.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2015-04-02.
//
//

#import "PCKeyValueStoreKeyConfig.h"

@interface PCKeyValueStoreKeyConfigStore : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSArray *configs;

/**
 *  Adds a config if the key/collection name pair doesn't already exist in the store
 *
 *  @param config
 */
- (void)addConfig:(PCKeyValueStoreKeyConfig *)config;

- (void)addConfigs:(NSArray *)configs;

/**
 *  Removes the config
 *
 *  @param config
 */
- (void)removeConfig:(PCKeyValueStoreKeyConfig *)config;

- (void)removeConfigs:(NSArray *)configs;

/**
 *  @param key
 *  @param collectionName
 *
 *  @return Whether the key/collection name pair already exists in the store
 */
- (BOOL)configExistsWithKey:(NSString *)key collectionName:(NSString *)collectionName;

@end
