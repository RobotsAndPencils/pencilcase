//
//  PCCollisionTrackingInfo.h
//  
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

#import <Foundation/Foundation.h>

@class PCJSContext;

/**
 @discussion Contains all of the information necessary for tracking collision between two nodes.
 */
@interface PCCollisionTrackingInfo : NSObject

@property (strong, nonatomic) SKNode *firstNode;
@property (strong, nonatomic) SKNode *secondNode;

@property (assign, nonatomic) NSUInteger numberOfTrackers;

- (instancetype)initWithNode:(SKNode *)firstNode andNode:(SKNode *)secondNode;

/**
 If either or both of firstNode and secondNode do NOT have physics bodies, checks if they are overlapping. If so, notifies javascript.
 @param context the javascript context to fire the event in
 */
- (void)notifyJavascriptIfCollisionIsOccurring:(PCJSContext *)context;

@end
