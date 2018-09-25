//
//  PCTokenSelectViewController.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-12-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PCToken;

@interface PCTokenSelectViewController : NSViewController

@property (strong, nonatomic) NSArray *tokens;
@property (copy, nonatomic) void(^selectionHandler)(PCToken *token);

@end
