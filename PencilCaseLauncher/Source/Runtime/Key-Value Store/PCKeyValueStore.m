//
//  PCKeyValueStore
//  PCPlayer
//
//  Created by brandon on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCKeyValueStore.h"
#import "PCKeyValueBackingStoreProtocol.h"

@interface PCKeyValueStore ()

@property (nonatomic, strong) id <PCKeyValueBackingStoreProtocol> backingStore;
@property (nonatomic, copy) NSString *uuid;

@end

@implementation PCKeyValueStore

- (void)setupWithBackingStore:(id <PCKeyValueBackingStoreProtocol>)backingStore uuid:(NSString *)uuid {
    if ([self.backingStore isEqual:backingStore] && [self.uuid isEqualToString:uuid]) return;

    [self teardown];

    self.backingStore = backingStore;
    self.uuid = uuid;

    [self.backingStore setupWithUUID:uuid];
    __weak __typeof(self) weakSelf = self;
    self.backingStore.keyPathChangeHandler = ^(JSManagedValue *jsManagedHandler, NSString *keyPath, id value) {
        // Arguments: sender, keyPath, oldValue, newValue
        [jsManagedHandler.value callWithArguments:@[ weakSelf, keyPath, [NSNull null], value ]];
    };
}

- (void)teardown {
    if ([self.backingStore respondsToSelector:@selector(teardown)]) {
        [self.backingStore teardown];
    }
    self.backingStore = nil;
}

- (void)setObject:(id)object forKey:(NSString *)key inCollection:(NSString *)collectionName success:(JSValue *)successCallback failure:(JSValue *)failureCallback {
    if (!key || [key length] == 0) {
        NSString *errorString = [NSString stringWithFormat:@"Store Error - Empty key passed - object: %@, key: %@, collectionName: %@", object, key, collectionName];
        if (failureCallback) [failureCallback callWithArguments:@[ errorString ]];
    }

    [self.backingStore setObject:object forKey:key inCollection:collectionName success:^(id createdObject) {
        if (successCallback && ![successCallback isUndefined] && ![successCallback isNull]) {
            NSArray *arguments = createdObject ? @[ createdObject ] : @[];
            [successCallback callWithArguments:arguments];
        }
    } failure:^(NSString *error) {
        if (failureCallback && ![failureCallback isUndefined] && ![failureCallback isNull]) {
            NSArray *arguments = error ? @[ error ] : @[];
            [failureCallback callWithArguments:arguments];
        }
    }];
}

- (id)objectForKey:(NSString *)key inCollection:(NSString *)collectionName {
    return [self.backingStore objectForKey:key inCollection:collectionName];
}

- (NSArray *)allKeysInCollection:(NSString *)collectionName {
    return [self.backingStore allKeysInCollection:collectionName];
}

- (void)watchKeyPath:(NSString *)keyPath handler:(JSValue *)handler {
    [self.backingStore watchKeyPath:keyPath handler:handler];
}

- (void)__unwatch {
    [self.backingStore __unwatch];
}

- (id)valueForKeyPath:(NSString *)keyPath {
    return [self.backingStore valueForKeyPath:keyPath];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    [self.backingStore setValue:value forKeyPath:keyPath];
}

@end
