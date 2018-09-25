//
//  PCFirebaseDataSource.h
//  PencilCaseLauncherDemo
//
//  Created by Stephen Gazzard on 2015-05-01.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFirebaseDataSource : NSObject

- (id)initWithUrl:(NSString *)url;

- (void)fetchValueAtPath:(NSString *)path success:(void(^)(id))success failure:(void(^)(NSError *))failure;
- (void)saveValue:(id)value toPath:(NSString *)path success:(void(^)())success failure:(void(^)(NSError *))failure;
- (void)appendValue:(id)value toPath:(NSString *)path success:(void(^)())success failure:(void(^)(NSError *))failure;

- (void)monitorValueAtPath:(NSString *)path newValueCallback:(void(^)(id))newValueCallback;
- (void)stopMonitoringValueAtPath:(NSString *)path;
- (void)stopMonitoringAllValues;

@end
