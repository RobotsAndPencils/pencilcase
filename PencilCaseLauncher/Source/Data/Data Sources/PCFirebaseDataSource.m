//
//  PCFirebaseDataSource.m
//  PencilCaseLauncherDemo
//
//  Created by Stephen Gazzard on 2015-05-01.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import "PCFirebaseDataSource.h"
#import <Firebase/Firebase.h>
#import "NSError+DataErrors.h"

@interface PCFirebaseDataSource()

@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) NSMutableDictionary *monitorReferences;

@end

@implementation PCFirebaseDataSource

- (id)initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        self.firebase = [[Firebase alloc] initWithUrl:url];
        self.monitorReferences = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)fetchValueAtPath:(NSString *)path success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    if (PCIsEmpty(path)) {
        if (failure) failure([NSError pc_invalidDataPathError]);
        return;
    }
    Firebase *firebase = [self.firebase childByAppendingPath:path];
    [firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (success) success(snapshot.value);
    }];
}

- (void)saveValue:(id)value toPath:(NSString *)path success:(void (^)())success failure:(void (^)(NSError *))failure {
    Firebase *destination = [self.firebase childByAppendingPath:path];
    [destination setValue:value withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error) {
            if (failure) failure(error);
        } else {
            if (success) success();
        }
    }];
}

- (void)appendValue:(id)value toPath:(NSString *)path success:(void (^)())success failure:(void (^)(NSError *))failure {
    Firebase *firebaseToAppendTo = PCIsEmpty(path) ? self.firebase : [self.firebase childByAppendingPath:path];
    Firebase *newRecord = [firebaseToAppendTo childByAutoId];
    [newRecord setValue:value withCompletionBlock:^(NSError *error, Firebase *firebase) {
        if (error) {
            if (failure) failure(error);
        } else {
            if (success) success();
        }
    }];
}

- (void)monitorValueAtPath:(NSString *)path newValueCallback:(void(^)(id))newValueCallback {
    if (PCIsEmpty(path) || !PCIsEmpty(self.monitorReferences[path])) return;

    void (^updateBlock)(FDataSnapshot *) = ^(FDataSnapshot *snapshot) {
        if (newValueCallback) newValueCallback(snapshot.value);
    };

    Firebase *childFirebase = [self.firebase childByAppendingPath:path];
    [childFirebase observeEventType:FEventTypeChildAdded withBlock:updateBlock];
    [childFirebase observeEventType:FEventTypeChildChanged withBlock:updateBlock];
    [childFirebase observeEventType:FEventTypeChildMoved withBlock:updateBlock];
    [childFirebase observeEventType:FEventTypeChildRemoved withBlock:updateBlock];
    [childFirebase observeEventType:FEventTypeValue withBlock:updateBlock];
    self.monitorReferences[path] = childFirebase;
}

- (void)stopMonitoringValueAtPath:(NSString *)path {
    if (PCIsEmpty(path) || PCIsEmpty(self.monitorReferences[path])) return;

    Firebase *monitoringFirebase = self.monitorReferences[path];
    [monitoringFirebase removeAllObservers];
    [self.monitorReferences removeObjectForKey:path];
}

- (void)stopMonitoringAllValues {
    [self.monitorReferences.allValues makeObjectsPerformSelector:@selector(removeAllObservers)];
    [self.monitorReferences removeAllObjects];
}


@end
