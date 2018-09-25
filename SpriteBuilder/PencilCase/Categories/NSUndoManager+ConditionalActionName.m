//
//  NSUndoManager+ConditionalActionName.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "NSUndoManager+ConditionalActionName.h"

@implementation NSUndoManager (ConditionalTaskName)

- (void)setActionNameUndoGroupCreated:(NSString *)actionName {
    if (self.groupingLevel > 0) {
        [self setActionName:actionName];
    }
}

@end
