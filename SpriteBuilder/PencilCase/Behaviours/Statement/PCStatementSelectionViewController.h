//
//  PCWhenSelectionViewController.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-15.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PCStatementSelectStyle) {
    PCStatementSelectStyleThen,
    PCStatementSelectStyleWhen,
};

@class PCStatement;

@interface PCStatementSelectionViewController : NSViewController

@property (strong, nonatomic) NSArray *statements;
@property (copy, nonatomic) void(^selectionHandler)(PCStatement *satement);
@property (assign, nonatomic) PCStatementSelectStyle style;

@end
