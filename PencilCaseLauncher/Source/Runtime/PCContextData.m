//
//  PCContextData.m
//  Pods
//
//  Created by Stephen Gazzard on 2015-05-12.
//
//

#import "PCContextData.h"
#import "PCFirebaseDataSource.h"

@interface PCContextData()

@property (strong, nonatomic) NSMutableDictionary *firebaseCache;

@end

@implementation PCContextData

+ (void)setupInContext:(JSContext *)context {
    context[@"__data_getFirebase"] = ^(NSString *url) {
        return [self _firebaseDataSourceWithUrlString:url];
    };
}

+ (NSMutableDictionary *)firebaseCache {
    static NSMutableDictionary *firebaseCache = nil;
    static dispatch_once_t dispatchToken;
    dispatch_once(&dispatchToken, ^{
        firebaseCache = [NSMutableDictionary dictionary];
    });
    return firebaseCache;
}

+ (PCFirebaseDataSource *)_firebaseDataSourceWithUrlString:(NSString *)url {
    PCFirebaseDataSource *dataSource = self.firebaseCache[url];
    if (dataSource) return dataSource;

    dataSource = [[PCFirebaseDataSource alloc] initWithUrl:url];
    self.firebaseCache[url] = dataSource;
    return dataSource;
}

+ (void)cleanupDataMonitoring {
    for (PCFirebaseDataSource * dataSource in self.firebaseCache.allValues) {
        [dataSource stopMonitoringAllValues];
    }
}

@end
