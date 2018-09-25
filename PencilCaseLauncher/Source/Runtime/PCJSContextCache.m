//
//  PCJSContextCache.m
//  Pods
//
//  Created by Cody Rayment on 2015-03-16.
//
//

#import "PCJSContextCache.h"
#import "PCJSContext.h"

@interface PCJSContextCache ()

@property (strong, nonatomic) NSMutableArray *cache;
@property (assign, nonatomic) BOOL buildingCache;
@property (strong, nonatomic) NSOperationQueue *cacheOperationQueue;

@end

@implementation PCJSContextCache

+ (instancetype)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [NSMutableArray array];
        _cacheOperationQueue = [NSOperationQueue new];
        _cacheOperationQueue.qualityOfService = NSQualityOfServiceBackground;
        _cacheOperationQueue.maxConcurrentOperationCount = 1;
        [self buildCache];
    }
    return self;
}

- (void)buildCache {
    // Ensure main queue
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self buildCache];
        });
        return;
    }

    if (self.buildingCache) return; // Don't want to have 2 builds running at once

    self.buildingCache = YES;

    __weak __typeof(self) weakSelf = self;
    NSMutableArray *cacheOperations = [NSMutableArray array];
    for (NSInteger i = self.cache.count; i < 3; i++) {
        NSBlockOperation *buildContextOperation = [[NSBlockOperation alloc] init];
        [buildContextOperation addExecutionBlock:^{
            PCJSContext *context = [[PCJSContext alloc] init];
            [weakSelf.cache addObject:context];
            if (buildContextOperation.cancelled) {
                [weakSelf.cache removeObject:context];
            }
        }];
        [self.cacheOperationQueue addOperation:buildContextOperation];
        [cacheOperations addObject:buildContextOperation];
    }

    NSOperation *resetOperation = [NSBlockOperation blockOperationWithBlock:^{
        weakSelf.buildingCache = NO;
    }];
    //Don't allow the reset operation to run until all the cache building operations have completed
    for (NSOperation *operation in cacheOperations) {
        [resetOperation addDependency:operation];
    }
    [self.cacheOperationQueue addOperation:resetOperation];
}

- (void)clearCacheAndCancelCacheBuilding {
    if (self.buildingCache) {
        [self.cacheOperationQueue cancelAllOperations];
        self.buildingCache = NO;
    }
    [self.cache removeAllObjects];
}

- (PCJSContext *)take {
    PCJSContext *context = [self.cache firstObject];
    if (context) {
        [self.cache removeObject:context];
    }
    if (!context) {
        context = [[PCJSContext alloc] init];
    }
    [self buildCache];
    return context;
}

@end
