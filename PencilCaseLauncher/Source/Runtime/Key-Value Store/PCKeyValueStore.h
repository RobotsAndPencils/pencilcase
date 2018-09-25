//
//  PCKeyValueStore
//  PCPlayer
//
//  Created by brandon on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;

@protocol PCKeyValueBackingStoreProtocol;

@interface PCKeyValueStore : NSObject

- (void)setupWithBackingStore:(id <PCKeyValueBackingStoreProtocol>)backingStore uuid:(NSString *)uuid;
- (void)teardown;

- (void)setObject:(id)object forKey:(NSString *)key inCollection:(NSString *)collectionName success:(JSValue *)successCallback failure:(JSValue *)failureCallback;
- (NSDictionary *)objectForKey:(NSString *)key inCollection:(NSString *)collectionName;
- (NSArray *)allKeysInCollection:(NSString *)collectionName;

- (void)watchKeyPath:(NSString *)keyPath handler:(JSValue *)handler;
- (void)__unwatch;

- (id)valueForKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;

@end
