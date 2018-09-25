//
//  PCContextCreation.h
//  PCPlayer
//
//  Created by Brandon on 2014-02-26.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

// Card Transitions
#import "RPJSCoreModule.h"

@class PCSlideNode;

FOUNDATION_EXPORT NSString * const PCGoToCardNotification;
FOUNDATION_EXPORT NSString * const PCGoToCardAtIndexNotification;
FOUNDATION_EXPORT NSString * const PCGoToNextCardNotification;
FOUNDATION_EXPORT NSString * const PCGoToPreviousCardNotification;
FOUNDATION_EXPORT NSString * const PCGoToFirstCardNotification;
FOUNDATION_EXPORT NSString * const PCGoToLastCardNotification;
FOUNDATION_EXPORT NSString * const PCCardUUIDStringKey;
FOUNDATION_EXPORT NSString * const PCCardIndex;
FOUNDATION_EXPORT NSString * const PCGoToCardCompletionBlockKey;
FOUNDATION_EXPORT NSString * const PCCardTransitionType;
FOUNDATION_EXPORT NSString * const PCCardTransitionDuration;

// iBeacon
FOUNDATION_EXPORT NSString * const PCIBeaconIdentifier;
FOUNDATION_EXPORT NSString * const PCListenForIBeaconNotification;
FOUNDATION_EXPORT NSString * const PCIBeaconUUIDStringKey;

@interface PCContextCreation : NSObject <RPJSCoreModule>

#pragma mark - Cards

+ (void)goToNextCard:(NSString *)transitionType transitionDuration:(NSNumber*)transitionDuration completion:(JSValue *)completion;
+ (void)goToPreviousCard:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion;
+ (void)goToFirstCard:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion;
+ (void)goToLastCard:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion;
+ (void)goToCard:(NSString *)cardUUIDString transitionType:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion;
+ (void)goToCardAtIndex:(NSNumber *)cardIndex transitionType:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion;

#pragma mark - Timelines

/**
 * Deprecated in favour of the timeline methods on PCSlideNode
 */
+ (void)playTimelineWithName:(NSString *)timelineName completionCallback:(JSValue *)completionCallback;

/**
 * Deprecated in favour of the timeline methods on PCSlideNode
 */
+ (void)stopTimelineWithName:(NSString *)timelineName;

#pragma mark - Nodes

+ (PCSlideNode *)currentCard;
+ (SKNode *)nodeWithUUID:(NSString *)uuid;
+ (SKNode *)nodeWithName:(NSString *)name;
+ (void)addObjectToCard:(SKNode *)object;

#pragma mark - Other

+ (void)openExternalLink:(NSString *)link;
+ (void)postNativeNotification:(NSString *)notificationName userInfo:(NSDictionary *)userInfo;

@end
