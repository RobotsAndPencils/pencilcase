//
//  PCBehaviourListViewController.h
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-09.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PCSlide;
@class PCWhen;
@class PCThen;

@interface PCBehaviourListViewController : NSViewController

- (void)loadCard:(PCSlide *)card;
- (void)validate;

- (void)pasteWhen:(PCWhen *)when;
- (void)pasteThen:(PCThen *)then;

@end
