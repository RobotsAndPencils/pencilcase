//
//  NSObject(JSDataBinding) 
//  PCPlayer
//
//  Created by brandon on 2014-03-18.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "NSObject+JSDataBinding.h"
#import "NSObject+BKBlockObservation.h"
#import <objc/runtime.h>

static void *WatchedKeyPathsKey = &WatchedKeyPathsKey;

@interface NSObject (JSDataBindingPrivate)

@property (strong, nonatomic) NSSet *watchedKeyPaths;

@end

@implementation NSObject (JSDataBinding)

- (void)watchKeyPath:(NSString *)keyPath handler:(JSValue *)handler {
    if (!self.watchedKeyPaths) {
        self.watchedKeyPaths = [NSSet set];
    }
    else if ([self.watchedKeyPaths containsObject:keyPath]) {
        return;
    }

    JSManagedValue *managedHandler = [JSManagedValue managedValueWithValue:handler];
    [handler.context.virtualMachine addManagedReference:managedHandler withOwner:self];

    [self bk_addObserverForKeyPath:keyPath task:^(id target) {
        // Arguments: sender, keyPath, oldValue, newValue
        [[managedHandler value] callWithArguments:@[ self, keyPath, [NSNull null], [target valueForKeyPath:keyPath] ]];
    }];

    self.watchedKeyPaths = [self.watchedKeyPaths setByAddingObject:keyPath];
}

- (void)__unwatch {
    [self bk_removeAllBlockObservers];
    self.watchedKeyPaths = [NSSet set];
}

#pragma mark - Properties

- (void)setWatchedKeyPaths:(NSSet *)watchedKeyPaths {
    objc_setAssociatedObject(self, WatchedKeyPathsKey, watchedKeyPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSSet *)watchedKeyPaths {
    return objc_getAssociatedObject(self, WatchedKeyPathsKey);
}

@end
