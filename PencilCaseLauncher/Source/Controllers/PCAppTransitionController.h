//
// Created by Brandon Evans on 15-06-02.
//
// This class listens for transition notifications and coordinates the presentation of cards during transitions.
//

#import <Foundation/Foundation.h>

@protocol PCSpriteKitPresenter;
@class PCApp;
@class PCCard;

@interface PCAppTransitionController : NSObject

@property (nonatomic, weak) id<PCSpriteKitPresenter> presenter;

- (instancetype)initWithApp:(PCApp *)app cardIndex:(NSInteger)cardIndex;
- (PCCard *)cardAtCurrentIndex;
- (void)goToCurrentSlide;

@end
