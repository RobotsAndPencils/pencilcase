//
//  PCYapDatabaseBackingStore
//  PCPlayer
//
//  Created by brandon on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCYapDatabaseBackingStore.h"
#import "YapDatabase.h"

static NSString *const PCKeyValueStoreDirectoryName = @"KeyValueStores";

@interface PCYapDatabaseBackingStore ()

@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *connection;
@property (nonatomic, strong) YapDatabaseConnection *bindingConnection;
@property (nonatomic, strong) NSMutableArray *targetKeyPaths;
@property (nonatomic, strong) NSMutableDictionary *handlers;

@end

@implementation PCYapDatabaseBackingStore

- (id)init {
    self = [super init];
    
    if (self) {
        self.targetKeyPaths = [NSMutableArray array];
        self.handlers = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWithUUID:(NSString *)uuid {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = searchPaths.firstObject;
    NSString *keyValueStoresPath = [documentsPath stringByAppendingPathComponent:PCKeyValueStoreDirectoryName];
    NSString *databasePath = [keyValueStoresPath stringByAppendingPathComponent:uuid];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    void (^createDirectory)() = ^{
        NSError *error;
        [fileManager createDirectoryAtPath:keyValueStoresPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"Error creating containing directory for PCYapDatabaseBackingStore database at path: %@\n%@", keyValueStoresPath, error);
        }
    };

    BOOL isDirectory;
    BOOL fileExists = [fileManager fileExistsAtPath:keyValueStoresPath isDirectory:&isDirectory];
    if (!fileExists) {
        createDirectory();
    }
    else if (!isDirectory) {
        [fileManager removeItemAtPath:keyValueStoresPath error:nil];
        createDirectory();
    }

    self.database = [[YapDatabase alloc] initWithPath:databasePath];
    self.connection = [self.database newConnection];
    self.bindingConnection = [self.database newConnection];
    [self.bindingConnection beginLongLivedReadTransaction];
    [self.targetKeyPaths removeAllObjects];
    [self.handlers removeAllObjects];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yapDatabaseModified:) name:YapDatabaseModifiedNotification object:self.database];
}

- (void)setObject:(id)object forKey:(NSString *)key inCollection:(NSString *)collectionName success:(PCKeyValueSuccessBlock)success failure:(PCKeyValueFailureBlock)failure {
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:object forKey:key inCollection:collectionName];
    }];
    if (success) success(object);
}

- (id)objectForKey:(NSString *)key inCollection:(NSString *)collectionName {
    __block NSDictionary *object;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        object = [transaction objectForKey:key inCollection:collectionName];
    }];
    return object;
}

- (NSArray *)allKeysInCollection:(NSString *)collectionName {
    __block NSArray *keys;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        keys = [transaction allKeysInCollection:collectionName];
    }];
    return keys;
}

- (void)watchKeyPath:(NSString *)targetKeyPath handler:(JSValue *)handler {
    [self.targetKeyPaths addObject:targetKeyPath];
    JSManagedValue *managedHandler = [JSManagedValue managedValueWithValue:handler];
    self.handlers[targetKeyPath] = managedHandler;
}

- (void)__unwatch {
    [self.targetKeyPaths removeAllObjects];
    [self.handlers removeAllObjects];
}

- (id)valueForKeyPath:(NSString *)keyPath {
    NSArray *components = [keyPath componentsSeparatedByString:@"."];
    NSString *collectionName = components[0];
    NSString *keyName = components[1];
    NSArray *propertyKeyPathComponents = [keyPath componentsSeparatedByString:[keyName stringByAppendingString:@"."]];
    NSString *propertyKeyPath = ([propertyKeyPathComponents count] > 1) ? propertyKeyPathComponents[1] : @"";

    __block id object;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        object = [transaction objectForKey:keyName inCollection:collectionName];
    }];

    if (PCIsEmpty(propertyKeyPath)) {
        return object;
    }
    return [object valueForKeyPath:propertyKeyPath];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    NSArray *components = [keyPath componentsSeparatedByString:@"."];
    NSString *collectionName = components[0];
    NSString *keyName = components[1];
    NSArray *propertyKeyPathComponents = [keyPath componentsSeparatedByString:[keyName stringByAppendingString:@"."]];
    NSString *propertyKeyPath = ([propertyKeyPathComponents count] > 1) ? propertyKeyPathComponents[1] : @"";

    if (PCIsEmpty(propertyKeyPath)) {
        [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction setObject:value forKey:keyName inCollection:collectionName];
        }];
        return;
    }

    __block id object;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        object = [transaction objectForKey:keyName inCollection:collectionName];
    }];

    [object setValue:value forKeyPath:propertyKeyPath];

    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:object forKey:keyName inCollection:collectionName];
    }];
}

#pragma mark - YAPDatabaseModifiedNotification

- (void)yapDatabaseModified:(NSNotification *)notification {
    NSArray *notifications = [self.bindingConnection beginLongLivedReadTransaction];

    for (NSString *keyPath in self.targetKeyPaths) {
        NSArray *components = [keyPath componentsSeparatedByString:@"."];
        NSString *collectionName = components[0];
        NSString *keyName = components[1];
        if ([self.bindingConnection hasChangeForKey:keyName inCollection:collectionName inNotifications:notifications]) {
            if (self.keyPathChangeHandler) {
                self.keyPathChangeHandler(self.handlers[keyPath], keyPath, [self valueForKeyPath:keyPath]);
            }
        }
    }
}

@end
