//
//  PCThenInfo.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-20.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCThenViewController;
@class PCAddThenButton;
@class PCThen;

/**
 * Data object for storing information about a Then
 */
@interface PCThenInfo : NSObject

@property (strong, nonatomic) PCThen *then;
@property (strong, nonatomic) PCThenViewController *viewController;
@property (strong, nonatomic) NSArray *constraints;
@property (assign, nonatomic) BOOL needsUpdateConstraints;
@property (strong, nonatomic) PCAddThenButton *addThenAboveButton;
@property (strong, nonatomic) PCAddThenButton *addThenBelowButton;

@end