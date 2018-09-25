//
//  PCWhen.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

#import "PCJavaScriptRepresentable.h"

@class PCThen;
@class PCStatement;
@class PCWhen;

@protocol PCWhenDelegate <NSObject>

- (void)whenNeedsDisplay:(PCWhen *)when;
- (void)didAddThen:(PCThen *)then atIndex:(NSInteger)index;
- (void)didRemoveThen:(PCThen *)then;

@end

@interface PCWhen : MTLModel <PCJavaScriptRepresentable>

@property (weak, nonatomic) id<PCWhenDelegate> delegate;
@property (strong, nonatomic, readonly) NSArray *thens;
@property (strong, nonatomic) PCStatement *statement;

- (void)insertThen:(PCThen *)then atIndex:(NSInteger)index;
- (void)removeThen:(PCThen *)then;
- (PCThen *)nextThenForThen:(PCThen *)then;
- (PCThen *)previousThenForThen:(PCThen *)then;
- (BOOL)containsThenMatching:(PCThen *)then;

- (NSArray *)availableTokensForThen:(PCThen *)then;

- (BOOL)matchesSearch:(NSString *)search;

- (BOOL)validate;
- (void)invalidate;

- (void)regenerateUUIDs;
- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID;

- (void)copyToPasteboard;
+ (PCWhen *)whenFromPasteboard;

@end
