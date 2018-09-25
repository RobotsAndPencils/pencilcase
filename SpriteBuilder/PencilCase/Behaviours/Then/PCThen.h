//
//  PCThen.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "PCJavaScriptRepresentable.h"

@class PCWhen;
@class PCStatement;
@class PCThen;

@protocol PCThenDelegate <NSObject>

- (void)thenNeedsDisplay:(PCThen *)then;

@end

@interface PCThen : MTLModel <PCJavaScriptRepresentable>

@property (weak, nonatomic) NSObject<PCThenDelegate> *delegate;
@property (strong, nonatomic) PCStatement *statement;
@property (assign, nonatomic) BOOL runWithPrevious;
@property (assign, nonatomic, readonly) BOOL canRunWithPrevious;
@property (assign, nonatomic, readonly) BOOL canRunWithNext;
@property (weak, nonatomic) PCWhen *when;
/**
 *  Used to determine if, when generating JS representations, the statement's script needs to be wrapped in a Promise in order to evaluate in the correct order when a callback is yielding to an array. Specifically, if this property returns NO (most common), then the representation will be wrapped. This property delegates to the statement to provide the correct value.
 */
@property (assign, nonatomic, readonly) BOOL evaluatesAsync;

- (BOOL)matchesSearch:(NSString *)search;
- (void)invalidateUI;
- (void)invalidate;
- (BOOL)validate;

- (void)regenerateUUIDs;
- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID;

- (void)copyToPasteboard;
+ (PCThen *)thenFromPasteboard;

@end
