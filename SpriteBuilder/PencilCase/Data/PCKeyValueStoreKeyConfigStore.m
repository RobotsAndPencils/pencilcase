//
//  PCKeyValueStoreKeyConfigStore.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2015-04-02.
//
//

#import "PCKeyValueStoreKeyConfigStore.h"

@interface PCKeyValueStoreKeyConfigStore ()

@property (nonatomic, strong) NSMutableOrderedSet *mutableConfigs;

@end

@implementation PCKeyValueStoreKeyConfigStore

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _mutableConfigs = [[NSMutableOrderedSet alloc] init];

    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }

    _mutableConfigs = [aDecoder decodeObjectForKey:@"mutableConfigs"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.mutableConfigs forKey:@"mutableConfigs"];
}

#pragma mark - Public

- (void)addConfig:(PCKeyValueStoreKeyConfig *)config {
    [self.mutableConfigs addObject:config];
}

- (void)addConfigs:(NSArray *)configs {
    [self.mutableConfigs addObjectsFromArray:configs];
}

- (void)removeConfig:(PCKeyValueStoreKeyConfig *)config {
    [self.mutableConfigs removeObject:config];
}

- (void)removeConfigs:(NSArray *)configs {
    [self.mutableConfigs removeObjectsInArray:configs];
}

- (BOOL)configExistsWithKey:(NSString *)key collectionName:(NSString *)collectionName {
    BOOL pairExists = Underscore.any(self.mutableConfigs.array, ^BOOL(PCKeyValueStoreKeyConfig *config) {
        return [config.key isEqualToString:key] && [config.collectionName isEqualToString:collectionName];
    });
    return pairExists;
}

#pragma mark - Properties

- (NSArray *)configs {
    return [self.mutableConfigs array];
}

@end
