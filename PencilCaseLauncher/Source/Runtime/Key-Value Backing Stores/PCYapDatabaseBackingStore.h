//
//  PCYapDatabaseBackingStore
//  PCPlayer
//
//  Created by brandon on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCKeyValueBackingStoreProtocol.h"

@class YapDatabase;
@class YapDatabaseConnection;

@interface PCYapDatabaseBackingStore : NSObject <PCKeyValueBackingStoreProtocol>

@property (nonatomic, copy) void (^keyPathChangeHandler)(JSManagedValue *jsHandler, NSString *keyPath, id value);


- (void)setupWithUUID:(NSString *)uuid;

- (void)setObject:(id)object forKey:(NSString *)key inCollection:(NSString *)collectionName success:(PCKeyValueSuccessBlock)success failure:(PCKeyValueFailureBlock)failure;
- (id)objectForKey:(NSString *)key inCollection:(NSString *)collectionName;
- (NSArray *)allKeysInCollection:(NSString *)collectionName;

- (id)valueForKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;

@end
