//
//  PCBehaviourList.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-01.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCBehaviourList.h"
#import <Cocoa/Cocoa.h>
#import "PCWhen.h"
#import "PCStatement.h"

@interface PCBehaviourList ()

@property (strong, nonatomic) NSMutableArray *mutableWhens;

@end

@implementation PCBehaviourList

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableWhens = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public

- (NSArray *)whens {
    return [self.mutableWhens copy];
}

- (void)insertWhen:(PCWhen *)when atIndex:(NSInteger)index {
    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    [[undoManager prepareWithInvocationTarget:self] removeWhen:when];
    if (![undoManager isUndoing]) [undoManager setActionName:@"Add When"];

    [self.mutableWhens insertObject:when atIndex:index];
    [self.delegate didAddWhen:when atIndex:index];
}

- (void)removeWhen:(PCWhen *)when {
    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    NSInteger index = [self.whens indexOfObjectIdenticalTo:when];
    [[undoManager prepareWithInvocationTarget:self] insertWhen:when atIndex:index];
    if (![undoManager isUndoing]) [undoManager setActionName:@"Delete When"];

    [self.mutableWhens removeObjectIdenticalTo:when];
    [self.delegate didRemoveWhen:when];
}

- (void)moveWhen:(PCWhen *)when toIndex:(NSInteger)newIndex {
    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    NSInteger index = [self.whens indexOfObjectIdenticalTo:when];
    [[undoManager prepareWithInvocationTarget:self] moveWhen:when toIndex:index];
    if (![undoManager isUndoing]) [undoManager setActionName:@"Reorder When"];
    
    [self.mutableWhens removeObjectIdenticalTo:when];
    [self.mutableWhens insertObject:when atIndex:newIndex];
    
    [self.delegate didMoveWhen:when toIndex:newIndex];
}

- (void)invalidate {
    for (PCWhen *when in self.whens) {
        [when invalidate];
    }
}

- (void)validate {
    for (PCWhen *when in self.whens) {
        [when validate];
    }
}

- (void)regenerateUUIDs {
    for (PCWhen *when in self.whens) {
        [when regenerateUUIDs];
    }
}

- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID {
    for (PCWhen *when in self.whens) {
        [when updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
    }
}

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    NSArray *javaScriptRepresentations = Underscore.arrayMap(self.whens, ^NSString *(PCWhen *when) {
        return [when javaScriptRepresentation];
    });
    return [javaScriptRepresentations componentsJoinedByString:@"\n\n"];
}

@end
