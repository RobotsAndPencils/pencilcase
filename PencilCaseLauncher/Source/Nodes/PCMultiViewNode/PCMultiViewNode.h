//
//  PCMultiViewNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCOverlayNode.h"

typedef NS_ENUM(NSInteger, PCMultiviewTransitionType) {
    PCMultiviewTransitionRight = 0,
    PCMultiviewTransitionLeft,
    PCMultiviewTransitionUp,
    PCMultiviewTransitionDown,
    PCMultiviewTransitionInstant
};

@interface PCMultiViewNode : SKSpriteNode <PCOverlayNode>

@property (assign, nonatomic) NSInteger focusedCellIndex;
@property (assign, nonatomic) BOOL showPageIndicator;
@property (strong, nonatomic) UIColor *currentPageIndicatorColor;
@property (strong, nonatomic) UIColor *pageIndicatorColor;
@property (assign, nonatomic, readonly) NSInteger nextIndex;
@property (assign, nonatomic, readonly) NSInteger previousIndex;

- (void)nextCell:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration;
- (void)previousCell:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration;
- (void)goToCell:(NSInteger)cellIndex transitionType:(PCMultiviewTransitionType)transitionType transitionDuration:(NSNumber *)transitionDuration;

@end
