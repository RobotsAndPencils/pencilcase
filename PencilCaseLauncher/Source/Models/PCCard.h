//
//  PCCard.h
//  
//
//  Created by Brandon Evans on 2014-09-05.
//
//

@class PCJSContext;
@class CCBAnimationManager;

@interface PCCard : NSObject

@property (nonatomic, strong, readonly) NSString *cardFilePath;
@property (nonatomic, strong, readonly) NSString *jsFilePath;
@property (nonatomic, strong, readonly) PCJSContext *context;
@property (nonatomic, copy, readonly) NSUUID *uuid;

// Whether a transition away from this card is allowed to occur
// This is defined as: you can only transition once per card appearance
// Subsequent transitions should no-op
@property (nonatomic, assign, readonly) BOOL canTransition;

@property (nonatomic, strong, readonly) CCBAnimationManager *animationManager; // a.k.a. timeline manager

+ (instancetype)cardWithPath:(NSString *)path;

/**
 *  Should be called before presenting the associated scene.
 */
- (void)cardWillAppear;

/**
 *  Should be called when the presentation of the associated scene is complete
 */
- (void)cardDidAppear;
/**
 *  Should be called after the build out has completed for a scene.
 */
- (void)cardDidDisappear;

@end
