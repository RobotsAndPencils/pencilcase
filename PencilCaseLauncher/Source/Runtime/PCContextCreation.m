//
//  PCContextCreation.m
//  PCPlayer
//
//  Created by Brandon on 2014-02-26.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;

#import "PCContextCreation.h"
#import "PCReaderManager.h"
#import "SKNode+GeneralHelpers.h"
#import "PCAppViewController.h"
#import "PCSlideNode.h"
#import "PCApp.h"
#import "PCConstants.h"
#import "PCSKView.h"
#import "PCScene.h"

NSString * const PCGoToCardNotification = @"PCGoToCardNotification";
NSString * const PCGoToCardAtIndexNotification = @"PCGoToCardAtIndexNotification";
NSString * const PCGoToNextCardNotification = @"PCGoToNextCardNotification";
NSString * const PCGoToPreviousCardNotification = @"PCGoToPreviousCardNotification";
NSString * const PCGoToFirstCardNotification = @"PCGoToFirstCardNotification";
NSString * const PCGoToLastCardNotification = @"PCGoToLastCardNotification";
NSString * const PCCardUUIDStringKey = @"PCCardUUIDStringKey";
NSString * const PCCardIndex = @"PCCardIndex";
NSString * const PCGoToCardCompletionBlockKey = @"PCGoToCardCompletionBlockKey";
NSString * const PCCardTransitionType = @"PCCardTransitionType";
NSString * const PCCardTransitionDuration = @"PCCardTransitionDuration";

@implementation PCContextCreation

#pragma mark - Cards

+ (void)goToNextCard:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion {
    void (^completionBlock)() = [^{
        [completion callWithArguments:@[ ]];
    } copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCGoToNextCardNotification object:nil userInfo:@{ PCCardTransitionType : transitionType, PCCardTransitionDuration : transitionDuration, PCGoToCardCompletionBlockKey: completionBlock }];
}

+ (void)goToPreviousCard:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion {
    void (^completionBlock)() = [^{
        [completion callWithArguments:@[ ]];
    } copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCGoToPreviousCardNotification object:nil userInfo:@{ PCCardTransitionType : transitionType, PCCardTransitionDuration : transitionDuration, PCGoToCardCompletionBlockKey: completionBlock }];
}

+ (void)goToFirstCard:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion {
    void (^completionBlock)() = [^{
        [completion callWithArguments:@[ ]];
    } copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCGoToFirstCardNotification object:nil userInfo:@{ PCCardTransitionType : transitionType, PCCardTransitionDuration : transitionDuration, PCGoToCardCompletionBlockKey: completionBlock }];
}

+ (void)goToLastCard:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion {
    void (^completionBlock)() = [^{
        [completion callWithArguments:@[ ]];
    } copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCGoToLastCardNotification object:nil userInfo:@{ PCCardTransitionType : transitionType, PCCardTransitionDuration : transitionDuration, PCGoToCardCompletionBlockKey: completionBlock }];
}

+ (void)goToCard:(NSString *)cardUUIDString transitionType:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion {
    void (^completionBlock)() = [^{
        [completion callWithArguments:@[ ]];
    } copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCGoToCardNotification object:nil userInfo:@{ PCCardUUIDStringKey : cardUUIDString, PCCardTransitionType : transitionType, PCCardTransitionDuration : transitionDuration, PCGoToCardCompletionBlockKey : completionBlock }];
}

+ (void)goToCardAtIndex:(NSNumber *)cardIndex transitionType:(NSString *)transitionType transitionDuration:(NSNumber *)transitionDuration completion:(JSValue *)completion {
    void (^completionBlock)() = [^{
        [completion callWithArguments:@[ ]];
    } copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCGoToCardAtIndexNotification object:nil userInfo:@{ PCCardIndex : cardIndex, PCCardTransitionType : transitionType, PCCardTransitionDuration : transitionDuration, PCGoToCardCompletionBlockKey: completionBlock }];
}

#pragma mark - Timelines

+ (void)playTimelineWithName:(NSString *)timelineName completionCallback:(JSValue *)completionCallback {
    PCReaderManager *reader = [PCReaderManager sharedManager];
    CCBAnimationManager *animationManager = reader.currentReader.animationManager;
    [animationManager runAnimationsForSequenceNamed:timelineName completion:^{
        if (completionCallback) [completionCallback callWithArguments:@[]];
    }];
}

+ (void)stopTimelineWithName:(NSString *)timelineName {
    PCReaderManager *reader = [PCReaderManager sharedManager];
    CCBAnimationManager *animationManager = reader.currentReader.animationManager;
    [animationManager stopAnimationForSequenceNamed:timelineName];
}

#pragma mark - Nodes

+ (PCScene *)currentScene {
    PCSKView *view = [PCAppViewController lastCreatedInstance].spriteKitView;
    return view.pc_scene;
}

+ (PCSlideNode *)currentCard {
    // This will always be of type PCSlideNode *
    return (PCSlideNode *)[[self currentScene] nodeWithClass:[PCSlideNode class]];
}

+ (SKNode *)nodeWithUUID:(NSString *)uuid {
    return [[self currentScene] nodeWithUUID:uuid];
}

+ (SKNode *)nodeWithName:(NSString *)name {
    return [[self currentScene] nodeNamed:name];
}

+ (void)addObjectToCard:(SKNode *)object {
    if (!object || ![object isKindOfClass:[SKNode class]]) return;
    [[self currentScene] addChild:object];
}

#pragma mark - Other

+ (void)openExternalLink:(NSString *)link {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

+ (void)postNativeNotification:(NSString *)notificationName userInfo:(NSDictionary *)userInfo{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
}

#pragma mark - RPJSCoreModule

+ (void)setupInContext:(JSContext *)context {
    context[@"__app_goToNextCard"] = ^(NSString *transitionType, NSNumber *transitionDuration, JSValue *successCallback) {
        [self goToNextCard:transitionType transitionDuration:transitionDuration completion:successCallback];
    };

    context[@"__app_goToPreviousCard"] = ^(NSString *transitionType, NSNumber *transitionDuration, JSValue *successCallback) {
        [self goToPreviousCard:transitionType transitionDuration:transitionDuration completion:successCallback];
    };

    context[@"__app_goToFirstCard"] = ^(NSString *transitionType, NSNumber *transitionDuration, JSValue *successCallback) {
        [self goToFirstCard:transitionType transitionDuration:transitionDuration completion:successCallback];
    };

    context[@"__app_goToLastCard"] = ^(NSString *transitionType, NSNumber *transitionDuration, JSValue *successCallback) {
        [self goToLastCard:transitionType transitionDuration:transitionDuration completion:successCallback];
    };

    context[@"__app_goToCard"] = ^(NSString *cardUUID, NSString *transitionType, NSNumber *transitionDuration, JSValue *successCallback) {
        [self goToCard:cardUUID transitionType:transitionType transitionDuration:transitionDuration completion:successCallback];
    };
    
    context[@"__app_goToCardAtIndex"] = ^(NSNumber *cardIndex, NSString *transitionType, NSNumber *transitionDuration, JSValue *successCallback) {
        [self goToCardAtIndex:cardIndex transitionType:transitionType transitionDuration:transitionDuration completion:successCallback];
    };

    context[@"__app_currentCard"] = ^SKNode *(){
        return [self currentCard];
    };

    context[@"__app_nodeWithUUID"] = ^SKNode *(NSString *uuid){
        return [self nodeWithUUID:uuid];
    };

    context[@"__app_nodeNamed"] = ^SKNode *(NSString *name){
        return [self nodeWithName:name];
    };

    context[@"__app_openExternalLink"] = ^void (NSString *link){
        [self openExternalLink:link];
    };

    context[@"__app_playTimelineWithName"] = ^(NSString *timelineName, JSValue *completionCallback) {
        [self playTimelineWithName:timelineName completionCallback:completionCallback];
    };

    context[@"__app_stopTimelineWithName"] = ^(NSString *timelineName) {
        [self stopTimelineWithName:timelineName];
    };

    context[@"__app_addObjectToCard"] = ^(SKNode *object) {
        [self addObjectToCard:object];
    };
    
    context[@"__app_postNativeNotification"] = ^(NSString *customEventName, NSDictionary *userInfo) {
        //Add the custom event name to the user info dictionary
        NSMutableDictionary *updatedUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        updatedUserInfo[PCEventNotificationCustomEventName] = customEventName;
        
        [self postNativeNotification:PCEventNotification userInfo:updatedUserInfo];
    };

    //
    // REPL
    //

    context[@"__app_getEnableDefaultREPLGesture"] = ^NSNumber *() {
        return @([PCAppViewController lastCreatedInstance].enableDefaultREPLGesture);
    };

    context[@"__app_setEnableDefaultREPLGesture"] = ^(NSNumber *enabled) {
        [PCAppViewController lastCreatedInstance].enableDefaultREPLGesture = [enabled boolValue];
    };

    context[@"__app_showREPL"] = ^ {
        [[PCAppViewController lastCreatedInstance] showREPL];
    };

    context[@"__app_hideREPL"] = ^ {
        [[PCAppViewController lastCreatedInstance] hideREPL];
    };

    //
    // SKView debugging
    //

    context[@"__app_getShowFPS"] = ^NSNumber *() {
        return @([PCAppViewController lastCreatedInstance].spriteKitView.showsFPS);
    };

    context[@"__app_setShowFPS"] = ^(NSNumber *enabled) {
        [PCAppViewController lastCreatedInstance].spriteKitView.showsFPS = [enabled boolValue];
    };

    context[@"__app_getShowNodeCount"] = ^NSNumber *() {
        return @([PCAppViewController lastCreatedInstance].spriteKitView.showsNodeCount);
    };

    context[@"__app_setShowNodeCount"] = ^(NSNumber *enabled) {
        [PCAppViewController lastCreatedInstance].spriteKitView.showsNodeCount = [enabled boolValue];
    };

    context[@"__app_getShowQuadCount"] = ^NSNumber *() {
        return @([PCAppViewController lastCreatedInstance].spriteKitView.showsQuadCount);
    };

    context[@"__app_setShowQuadCount"] = ^(NSNumber *enabled) {
        [PCAppViewController lastCreatedInstance].spriteKitView.showsQuadCount = [enabled boolValue];
    };

    context[@"__app_getShowDrawCount"] = ^NSNumber *() {
        return @([PCAppViewController lastCreatedInstance].spriteKitView.showsDrawCount);
    };

    context[@"__app_setShowDrawCount"] = ^(NSNumber *enabled) {
        [PCAppViewController lastCreatedInstance].spriteKitView.showsDrawCount = [enabled boolValue];
    };

    context[@"__app_getShowPhysicsBorders"] = ^NSNumber *() {
        return @([PCAppViewController lastCreatedInstance].spriteKitView.showsPhysics);
    };

    context[@"__app_setShowPhysicsBorders"] = ^(NSNumber *enabled) {
        [PCAppViewController lastCreatedInstance].spriteKitView.showsPhysics = [enabled boolValue];
    };

    context[@"__app_getShowPhysicsFields"] = ^NSNumber *() {
        return @([PCAppViewController lastCreatedInstance].spriteKitView.showsFields);
    };

    context[@"__app_setShowPhysicsFields"] = ^(NSNumber *enabled) {
        [PCAppViewController lastCreatedInstance].spriteKitView.showsFields = [enabled boolValue];
    };
}

@end
