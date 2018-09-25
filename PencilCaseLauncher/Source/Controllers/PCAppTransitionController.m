//
// Created by Brandon Evans on 15-06-02.
//

#import <CoreGraphics/CoreGraphics.h>
#import "PCDeviceResolutionSettings.h"
#import "PCScene.h"
#import "PCAppViewController.h"
#import "PCAppTransitionController.h"
#import "PCSpriteKitPresenter.h"
#import "PCApp.h"
#import "PCContextCreation.h"
#import "SKTransition+FromString.h"
#import "PCCard.h"
#import "PCSlideNode.h"

@interface PCAppTransitionController ()

@property (nonatomic, strong) PCApp *app;
@property (nonatomic, assign) NSInteger currentSlideIndex;
@end

@implementation PCAppTransitionController

- (instancetype)initWithApp:(PCApp *)app cardIndex:(NSInteger)cardIndex {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _app = app;
    _currentSlideIndex = cardIndex;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoToSlide:) name:PCGoToCardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoToSlideAtIndex:) name:PCGoToCardAtIndexNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoToNextSlide:) name:PCGoToNextCardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoToPreviousSlide:) name:PCGoToPreviousCardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoToFirstSlide:) name:PCGoToFirstCardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoToLastSlide:) name:PCGoToLastCardNotification object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.cardAtCurrentIndex cardDidDisappear];
}

#pragma mark - Public

- (PCCard *)cardAtCurrentIndex {
    return self.app.cards[self.currentSlideIndex];
}

#pragma mark - Card Transitioning

- (void)goToSlideAtIndex:(NSInteger)index withTransitionName:(NSString *)name duration:(CGFloat)duration completion:(void (^)())completion {
    SKTransition *transition = [SKTransition transitionFromString:name withDuration:duration];
    [self goToSlideAtIndex:index withTransition:transition duration:duration completion:completion];
}

- (void)goToSlideAtIndex:(NSInteger)slideIndex withTransition:(SKTransition *)transition duration:(CGFloat)duration completion:(void (^)())completion {
    BOOL indexIsOutOfRange = slideIndex < 0 || slideIndex >= self.app.cards.count;
    BOOL currentCardCanTransition = !self.presenter.isPresentingAScene || self.cardAtCurrentIndex.canTransition;
    if (indexIsOutOfRange || !currentCardCanTransition) return;

    NSInteger previousSlideIndex = self.currentSlideIndex;
    PCCard *previousCard = [self cardAtCurrentIndex];
    BOOL transitioningToSameCard = (slideIndex == previousSlideIndex);

    // Do this before calling willAppear on it when cards are the same so that the context is refreshed
    if (transitioningToSameCard) {
        [previousCard cardDidDisappear];
    }

    self.currentSlideIndex = slideIndex;
    PCCard *nextCard = self.cardAtCurrentIndex;
    [nextCard cardWillAppear];
    [self.presenter setupWithJSContext:nextCard.context];

    __weak typeof(self) weakSelf = self;
    [self.presenter presentScene:[weakSelf sceneAtCurrentCardIndex] withTransition:transition duration:duration completion:^{
        [nextCard cardDidAppear];
        if (completion) completion();
    }];

    if (!transitioningToSameCard) {
        [previousCard cardDidDisappear];
    }
}

#pragma mark - NSNotification Handlers

- (void)handleGoToSlide:(NSNotification *)notification {
    NSString *cardUUIDString = notification.userInfo[PCCardUUIDStringKey];
    NSInteger targetCardIndex;
    if ([cardUUIDString isEqualToString:@"next"]) {
        targetCardIndex = self.currentSlideIndex + 1;
    }
    else if ([cardUUIDString isEqualToString:@"previous"]) {
        targetCardIndex = self.currentSlideIndex - 1;
    }
    else if ([cardUUIDString isEqualToString:@"first"]) {
        targetCardIndex = 0;
    }
    else if ([cardUUIDString isEqualToString:@"last"]) {
        targetCardIndex = self.app.cards.count - 1;
    }
    else {
        NSUUID *cardUUID = [[NSUUID alloc] initWithUUIDString:cardUUIDString];
        targetCardIndex = [self cardIndexForUUID:cardUUID];
    }

    NSString *transitionType = notification.userInfo[PCCardTransitionType];
    CGFloat transitionDuration = [notification.userInfo[PCCardTransitionDuration] floatValue];
    void (^completion)() = notification.userInfo[PCGoToCardCompletionBlockKey];

    [self goToSlideAtIndex:targetCardIndex withTransitionName:transitionType duration:transitionDuration completion:completion];
}

- (void)handleGoToSlideAtIndex:(NSNotification *)notification {
    NSString *transitionType = notification.userInfo[PCCardTransitionType];
    CGFloat transitionDuration = [notification.userInfo[PCCardTransitionDuration] floatValue];
    NSInteger slideIndex = [notification.userInfo[PCCardIndex] integerValue];
    void (^completion)() = notification.userInfo[PCGoToCardCompletionBlockKey];
    [self goToSlideAtIndex:slideIndex withTransitionName:transitionType duration:transitionDuration completion:completion];
}

- (void)handleGoToNextSlide:(NSNotification *)notification {
    NSString *transitionType = notification.userInfo[PCCardTransitionType];
    CGFloat transitionDuration = [notification.userInfo[PCCardTransitionDuration] floatValue];
    void (^completion)() = notification.userInfo[PCGoToCardCompletionBlockKey];
    [self goToSlideAtIndex:self.currentSlideIndex + 1 withTransitionName:transitionType duration:transitionDuration completion:completion];
}

- (void)handleGoToPreviousSlide:(NSNotification *)notification {
    NSString *transitionType = notification.userInfo[PCCardTransitionType];
    CGFloat transitionDuration = [notification.userInfo[PCCardTransitionDuration] floatValue];
    void (^completion)() = notification.userInfo[PCGoToCardCompletionBlockKey];
    [self goToSlideAtIndex:self.currentSlideIndex - 1 withTransitionName:transitionType duration:transitionDuration completion:completion];
}

- (void)handleGoToFirstSlide:(NSNotification *)notification {
    NSString *transitionType = notification.userInfo[PCCardTransitionType];
    CGFloat transitionDuration = [notification.userInfo[PCCardTransitionDuration] floatValue];
    void (^completion)() = notification.userInfo[PCGoToCardCompletionBlockKey];
    [self goToSlideAtIndex:0 withTransitionName:transitionType duration:transitionDuration completion:completion];
}

- (void)handleGoToLastSlide:(NSNotification *)notification {
    NSString *transitionType = notification.userInfo[PCCardTransitionType];
    CGFloat transitionDuration = [notification.userInfo[PCCardTransitionDuration] floatValue];
    void (^completion)() = notification.userInfo[PCGoToCardCompletionBlockKey];
    [self goToSlideAtIndex:self.app.cards.count - 1 withTransitionName:transitionType duration:transitionDuration completion:completion];
}

/**
 * @discussion Finds the index of a card with the given UUID string, or the current card's index if none are found.
 */
- (NSInteger)cardIndexForUUID:(NSUUID *)uuid {
    NSInteger index = [self.app cardIndexForUUID:uuid];
    if (index == NSNotFound) {
        index = self.currentSlideIndex;
    }

    return index;
}

- (void)goToCurrentSlide {
    [self goToSlideAtIndex:self.currentSlideIndex withTransition:nil duration:0 completion:^{}];
}

#pragma mark - Scene Loading

- (SKScene *)sceneAtCurrentCardIndex {
    SKScene *result = [self loadSceneFromCard:self.cardAtCurrentIndex];
    return result;
}

- (PCScene *)loadSceneFromCard:(PCCard *)card {
    PCSlideNode *cardNode = (PCSlideNode *)[CCBReader nodeGraphFromFilePath:card.cardFilePath owner:nil parentSize:[PCAppViewController lastCreatedInstance].view.bounds.size animationManager:card.animationManager];
    cardNode.card = card;

    if (!cardNode) {
        PSPDFAlertView *alertView = [[PSPDFAlertView alloc] initWithTitle:@"Incompatible Version"];
        alertView.message = @"An issue has occurred, we could not load the card. Likely this means that the creator of this content needs to re-export the app with the latest version of PencilCase Mac.";
        [alertView addButtonWithTitle:@"OK" block:^(NSInteger buttonIndex) { }];
        [alertView show];
        return nil;
    }

    PCScene *scene = [PCScene sceneWithSize:cardNode.size];
    scene.backgroundColor = [UIColor whiteColor];
    [scene setUserInteractionEnabled:YES];
    [scene addChild:cardNode];

    return scene;
}

@end
