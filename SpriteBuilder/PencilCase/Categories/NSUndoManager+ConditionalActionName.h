//
//  NSUndoManager+ConditionalActionName.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUndoManager (ConditionalActionName)

- (void)setActionNameUndoGroupCreated:(NSString *)actionName;

@end
