//
//  PCWhenInfo.h
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-20.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCWhenViewController;
@class PCWhen;

@interface PCWhenInfo : NSObject

@property (strong, nonatomic) PCWhen *when;
@property (strong, nonatomic) PCWhenViewController *viewController;
@property (strong, nonatomic) NSArray *constraints;
@property (assign, nonatomic) BOOL needsUpdateConstraints;

@end
