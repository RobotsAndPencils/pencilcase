//
//  PCKeyValueStoreKeyConfig.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2015-04-02.
//
//

#import "PCKeyValueStoreKeyConfig.h"

@implementation PCKeyValueStoreKeyConfig

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];

    _key = @"";
    _collectionName = @"";
    _type = PCKeyValueStoreKeyTypeNone;

    return self;
}

- (instancetype)initWithKey:(NSString *)key keyUniquenessTest:(BOOL (^)(PCKeyValueStoreKeyConfig *))uniquenessTest {
    self = [self init];
    if (!self) {
        return nil;
    }

    NSInteger suffix = 1;
    _key = [NSString stringWithFormat:@"%@%ld", key, suffix];

    if (!uniquenessTest) {
        return self;
    }

    // Increment the default key until there's a unique one to add
    // Because we're guaranteeing unique keys in the store by using a set, this has to happen here
    while (!uniquenessTest(self)) {
        suffix += 1;
        _key = [NSString stringWithFormat:@"%@%ld", key, suffix];
    }

    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[self class]]) return NO;

    PCKeyValueStoreKeyConfig *config = (PCKeyValueStoreKeyConfig *)object;
    return [self.collectionName isEqualToString:config.collectionName] && [self.key isEqualToString:config.key];
}

- (NSUInteger)hash {
    return self.collectionName.hash ^ self.key.hash;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }

    _key = [aDecoder decodeObjectForKey:@"key"];
    _collectionName = [aDecoder decodeObjectForKey:@"collectionName"];
    _type = (PCKeyValueStoreKeyType)[aDecoder decodeIntegerForKey:@"type"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.collectionName forKey:@"collectionName"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    PCKeyValueStoreKeyConfig *config = [[PCKeyValueStoreKeyConfig alloc] init];
    config.key = self.key;
    config.collectionName = self.collectionName;
    config.type = self.type;
    return config;
}

@end
