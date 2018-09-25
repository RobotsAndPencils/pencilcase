//
//  PCBehaviourList.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-01.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "MTLModel.h"
#import "PCJavaScriptRepresentable.h"

@class PCWhen;

@protocol PCBehaviourListDelegate <NSObject>

- (void)didAddWhen:(PCWhen *)when atIndex:(NSInteger)index;
- (void)didRemoveWhen:(PCWhen *)when;
- (void)didMoveWhen:(PCWhen *)when toIndex:(NSInteger)index;

@end

@interface PCBehaviourList : MTLModel <PCJavaScriptRepresentable>

@property (weak, nonatomic) id<PCBehaviourListDelegate> delegate;
@property (strong, nonatomic, readonly) NSArray *whens;

- (void)insertWhen:(PCWhen *)when atIndex:(NSInteger)index;
- (void)removeWhen:(PCWhen *)when;
- (void)moveWhen:(PCWhen *)when toIndex:(NSInteger)newIndex;
- (void)invalidate;
- (void)validate;

- (void)regenerateUUIDs;
- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID;

@end
