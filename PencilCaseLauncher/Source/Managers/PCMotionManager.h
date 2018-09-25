//
//  PCMotionManager.h
//  PCPlayer
//
//  Created by Cody Rayment on 3/5/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

/**
 *  Singleton motion manager which allows multiple subscribers.
 
 Apple docs state: "An app should create only a single instance of the CMMotionManager class. Multiple instances of this class can affect the rate at which data is received from the accelerometer and gyroscope."
 
 So we have a singleton to manage our one instance of CMMotionManeger.
 
 You can subscribe with a block. You need to hold a strong reference to the block somewhere because this class will not. Unsubscribing not necessary.
 
 Maybe in the future you will need finer control of unsubscribe timing. Then subscription will need to take a block and a context of some sort... ?
 */
@interface PCMotionManager : NSObject

@property (strong, nonatomic, readonly) CMMotionManager *motionManager;

+ (instancetype)sharedInstance;
- (void)registerForAccelerometerUpdatesWithHandler:(CMAccelerometerHandler)handler;

@end
