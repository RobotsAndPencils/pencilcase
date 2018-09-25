//
//  PCMotionManager.m
//  PCPlayer
//
//  Created by Cody Rayment on 3/5/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCMotionManager.h"

@interface PCMotionManager ()

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSPointerArray *handlers;
@property (strong, nonatomic) NSTimer *cleanupTimer;

@end

@implementation PCMotionManager

+ (instancetype)sharedInstance {
    static PCMotionManager *_sharedManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManger = [[self alloc] init];
    });
    return _sharedManger;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.handlers = [NSPointerArray weakObjectsPointerArray];
        self.cleanupTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(cleanup) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)registerForAccelerometerUpdatesWithHandler:(CMAccelerometerHandler)handler {
    if ([[self.handlers allObjects] count] == 0) [self startTrackingAccelerometer];
    [self.handlers insertPointer:(__bridge void *)(handler) atIndex:[self.handlers count]];
}

#pragma mark - Private

- (void)startTrackingAccelerometer {
    self.motionManager.accelerometerUpdateInterval = 1.0/30.0;
    __weak __typeof (self) weakself = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        for (CMAccelerometerHandler handler in weakself.handlers) {
            if (handler) handler(accelerometerData, error);
        }
    }];
}

- (void)stopTrackingAccelerometer {
    [self.motionManager stopAccelerometerUpdates];
}

- (void)cleanup {
    [self.handlers compact];
    if ([[self.handlers allObjects] count] == 0) [self stopTrackingAccelerometer];
}

@end
