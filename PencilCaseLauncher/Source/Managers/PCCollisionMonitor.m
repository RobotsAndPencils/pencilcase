//
//  PCCollisionMonitor.m
//  
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

#import "PCCollisionMonitor.h"
#import "PCCollisionTrackingInfo.h"
#import "SKNode+JavaScript.h"

@interface PCCollisionMonitor()

@property (strong, nonatomic) NSMutableDictionary *monitorDictionary;

@end

@implementation PCCollisionMonitor

- (instancetype)init {
    self = [super init];
    if (self) {
        _monitorDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public

- (void)monitorCollisionsBetween:(SKNode *)firstNode and:(SKNode *)secondNode {
    if (!firstNode || !secondNode) return;

    NSString *dictionaryKey = [self dictionaryKeyForNode:firstNode and:secondNode];
    PCCollisionTrackingInfo *trackingInfo = self.monitorDictionary[dictionaryKey];
    if (trackingInfo) {
        trackingInfo.numberOfTrackers++;
        return;
    }

    trackingInfo = [[PCCollisionTrackingInfo alloc] initWithNode:firstNode andNode:secondNode];
    self.monitorDictionary[dictionaryKey] = trackingInfo;
}

- (void)notifyJavascriptIfAnyCollisionsAreOccurring:(PCJSContext *)context {
    for (PCCollisionTrackingInfo *info in self.monitorDictionary.allValues) {
        [info notifyJavascriptIfCollisionIsOccurring:context];
    }
}

#pragma mark - Private

- (NSString *)dictionaryKeyForNode:(SKNode *)firstNode and:(SKNode *)secondNode {
    NSString *firstString = firstNode.uuid ?: firstNode.name ?: @"";
    NSString *secondString = secondNode.uuid ?: secondNode.name ?: @"";

    NSComparisonResult comparisonResult = [firstString compare:secondString];
    switch (comparisonResult) {
        case NSOrderedAscending:
            return [firstString stringByAppendingString:secondString];
        case NSOrderedDescending:
            return [secondString stringByAppendingString:firstString];
        case NSOrderedSame:
            return firstString;
    }
}

@end
