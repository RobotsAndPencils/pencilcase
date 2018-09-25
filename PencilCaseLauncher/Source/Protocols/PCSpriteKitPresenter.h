//
// Created by Brandon Evans on 15-06-02.
//

@import JavaScriptCore;

@protocol PCSpriteKitPresenter

@property (nonatomic, assign, readonly) BOOL isPresentingAScene;

- (void)presentScene:(SKScene *)scene withTransition:(SKTransition *)transition duration:(CGFloat)duration completion:(void (^)())completion;
- (void)setupWithJSContext:(JSContext *)context;

@end
