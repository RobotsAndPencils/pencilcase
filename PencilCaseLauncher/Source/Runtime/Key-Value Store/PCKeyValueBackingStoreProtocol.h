//
//  PCKeyValueBackingStoreProtocol
//  PCPlayer
//
//  Created by brandon on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;

typedef void (^PCKeyValueSuccessBlock)(NSDictionary *object);
typedef void (^PCKeyValueFailureBlock)(NSString *error);

@protocol PCKeyValueBackingStoreProtocol <NSObject>

@required

@property (nonatomic, copy) void (^keyPathChangeHandler)(JSManagedValue *jsHandler, NSString *keyPath, id value);

- (void)setupWithUUID:(NSString *)uuid;

- (void)setObject:(id)object forKey:(NSString *)key inCollection:(NSString *)collectionName success:(PCKeyValueSuccessBlock)success failure:(PCKeyValueFailureBlock)failure;
- (id)objectForKey:(NSString *)key inCollection:(NSString *)collectionName;
- (NSArray *)allKeysInCollection:(NSString *)collectionName;

- (void)watchKeyPath:(NSString *)targetKeyPath handler:(JSValue *)handler;
- (void)__unwatch;

- (id)valueForKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;

@optional

- (void)teardown;

@end
