//
//  PCFirebaseDataSourceExport+JSExport.m
//  PencilCaseLauncherDemo
//
//  Created by Stephen Gazzard on 2015-05-01.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import "PCFirebaseDataSource+JSExport.h"

@implementation PCFirebaseDataSource (JSExport)

- (void)jsFetchValueAtPath:(NSString *)path success:(JSValue *)success failure:(JSValue *)failure {
    [self fetchValueAtPath:path success:^(id newValue) {
        [success callWithArguments:@[newValue]];
    } failure:^(NSError *error) {
        [failure callWithArguments:@[[error localizedDescription]]];
    }];
}

- (void)jsSaveValue:(id)value toPath:(NSString *)path success:(JSValue *)success failure:(JSValue *)failure {
    [self saveValue:value toPath:path success:^{
        [success callWithArguments:@[]];
    } failure:^(NSError *error) {
        [failure callWithArguments:@[[error localizedDescription]]];
    }];
}

- (void)jsMonitorValueAtPath:(NSString *)path newValueCallback:(JSValue *)newValueCallback {
    [self monitorValueAtPath:path newValueCallback:^(id newValue) {
        [newValueCallback callWithArguments:@[newValue]];
    }];
}

- (void)jsAppendValue:(id)value toPath:(NSString *)path success:(JSValue *)success failure:(JSValue *)failure {
    [self appendValue:value toPath:path success:^{
        [success callWithArguments:@[]];
    } failure:^(NSError *error) {
        [failure callWithArguments:@[[error localizedDescription]]];
    }];
}

@end
