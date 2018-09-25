//
//  PCAppViewController 
//  PCPlayer
//
//  Created by brandon on 2014-03-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCAppViewController.h"
#import "PCREPLViewController.h"
#import "PCJSContext.h"
#import "SKNode+LifeCycle.h"
#import "SKTransition+FromString.h"
#import "PCSlideNode.h"
#import "OALSimpleAudio.h"
#import "PCDeviceResolutionSettings.h"
#import "PCOverlayView.h"
#import "UIView+Snapshot.h"
#import "UIView+FirstResponder.h"
#import "PCSpriteKitPresenter.h"
#import "PCSKView.h"

// JS
#import "PCContextCreation.h"

// Backing store
#import "PCYapDatabaseBackingStore.h"
#import "PCKeyValueStore.h"

// App Loading/Running
#import "PCApp.h"
#import "PCCard.h"
#import "PCReader.h"
#import "PCReaderManager.h"

// iBeacon
#import "PCBeaconManager.h"

// 3rd party
#import <PSAlertView/PSPDFAlertView.h>

// KeyPressedEvents
#import "NSString+KeyCodes.h"

#import "PCCameraCaptureNode.h"
#import "PCAppTransitionController.h"
#import <CoreText/CoreText.h>

// Myo
#import <MyoKit/MyoKit.h>

@interface PCAppViewController () <PCREPLDelegate, PCSpriteKitPresenter>

@property (strong, nonatomic, readwrite) IBOutlet PCSKView *spriteKitView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *spriteKitViewAspectRatioConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardAvoidingBottomConstraint;

@property (strong, nonatomic, readwrite) PCApp *runningApp;

// iBeacon
@property (strong, nonatomic, readwrite) PCBeaconManager *beaconManager;

// REPL
@property (strong, nonatomic) PCREPLViewController *replViewController;
@property (assign, nonatomic) BOOL replShowing;

// KeyPressedEventKeys
@property (nonatomic, assign) BOOL clearKeyEvents;
@property (nonatomic, strong) NSMutableDictionary *keyPressedCounts;

@property (nonatomic, strong) UISwipeGestureRecognizer *replLeftSwipeRecognizer;

@property (nonatomic, strong) PCAppTransitionController *transitionController;

//Keyboard avoiding
@property (assign, nonatomic) CGRect keyboardFrame;
@property (assign, nonatomic) BOOL keyboardIsShown;
@property (weak, nonatomic) SKNode<PCOverlayNode> *editingNode;

@end

@implementation PCAppViewController

__weak static PCAppViewController *_lastCreatedInstance = nil;
+ (instancetype)lastCreatedInstance {
    return _lastCreatedInstance;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }

    _replShowing = NO;
    _lastCreatedInstance = self;
    _keyPressedCounts = [[NSMutableDictionary alloc] init];

    return self;
}

- (instancetype)initWithApp:(PCApp *)app startSlideIndex:(NSInteger)index {
    return [self initWithApp:app startSlideIndex:index options:nil];
}

- (instancetype)initWithApp:(PCApp *)app startSlideIndex:(NSInteger)index options:(NSDictionary *)launchOptions {
    self = [self initWithNibName:@"PCAppView" bundle:nil];
    if (!self) {
        return nil;
    }

    _runningApp = app;
    _transitionController = [[PCAppTransitionController alloc] initWithApp:app cardIndex:index];
    _transitionController.presenter = self;

    [self loadUserFonts];
    [app setupKeyValueStore];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // When deallocated while running there is no method called to trigger the lifecycle events.
    SKScene *scene = self.spriteKitView.scene;
    [scene pc_dismissTransitionWillStart];
    [[self spriteKitView] presentScene:nil];
    [scene removeAllChildren];

    [self.runningApp tearDownKeyValueStore];
    [[PCReaderManager sharedManager] setCurrentReader:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self subscribeToNotifications];

    // Apply debugging settings
    self.spriteKitView.showsFPS = self.runningApp.showFPS;
    self.spriteKitView.showsNodeCount = self.runningApp.showNodeCount;
    self.spriteKitView.showsDrawCount = self.runningApp.showDrawCount;
    self.spriteKitView.showsQuadCount = self.runningApp.showQuadCount;
    self.spriteKitView.showsFields = self.runningApp.showPhysicsFields;
    self.spriteKitView.showsPhysics = self.runningApp.showPhysicsBorders;
    self.enableDefaultREPLGesture = self.runningApp.enableDefaultREPLGesture;

    // Configure CCFileUtils
    [PCReader configureCCFileUtilsWithURL:self.runningApp.url];

    if ([self.runningApp.iBeacons count] > 0) {
        self.beaconManager = [[PCBeaconManager alloc] init];
        [self.beaconManager startWithBeaconInfoDictionaries:self.runningApp.iBeacons];
    }

    [self.transitionController goToCurrentSlide];

    self.clearKeyEvents = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoseChange:) name:TLMMyoDidReceivePoseChangedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![self.view findFirstResponderInViewTree]) {
        [self becomeFirstResponder];
    }
}

- (BOOL)canBecomeFirstResponder {
    self.clearKeyEvents = NO;
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.beaconManager stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[OALSimpleAudio sharedInstance] stopAllEffects];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutForScene:self.spriteKitView.scene];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Public

- (void)nodeDidBeginEditingText:(SKNode<PCOverlayNode> *)textNode {
    if (textNode.scene != self.spriteKitView.scene) return;
    if (textNode == self.editingNode) return;
    self.editingNode = textNode;

    if (self.keyboardIsShown) {
        [self focusTextNodeWithDuration:0.1f curve:7];
    }
}

- (void)nodeDidFinishEditingText:(SKNode<PCOverlayNode >*)textNode {
    if (textNode != self.editingNode) return;
    self.editingNode = nil;
}

#pragma mark - PCSpriteKitPresenter

- (BOOL)isPresentingAScene {
    return self.spriteKitView.scene != nil;
}

- (void)presentScene:(SKScene *)scene withTransition:(SKTransition *)transition duration:(CGFloat)duration completion:(void (^)())completion {
    SKScene *oldScene = self.spriteKitView.scene;

    oldScene.physicsWorld.speed = 0;
    scene.physicsWorld.speed = 0;

    [[OALSimpleAudio sharedInstance] stopAllEffects];

    if (transition) {
        [self insertOverlaySnaphsotIntoScene:oldScene];

        // Small delay prevents flash - gives SK a chance to draw before we hide the overlay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [[PCOverlayView overlayView] sceneTransitionWillStart];
            [[self spriteKitView].scene pc_dismissTransitionWillStart];

            [[self spriteKitView] presentScene:scene transition:transition];
            [self layoutForScene:scene];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [scene pc_presentationDidStart];
                SKSpriteNode *newSceneOverlaySnapshot = [self insertOverlaySnaphsotIntoScene:scene];

                // Use weak reference to scene in case the app gets closed during a transition
                __weak typeof(newSceneOverlaySnapshot) weakNewSceneOverlaySnapshot = newSceneOverlaySnapshot;
                __weak typeof(scene) weakScene = scene;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakNewSceneOverlaySnapshot removeFromParent];
                    [[PCOverlayView overlayView] sceneTransitionCompleted];
                    [oldScene removeAllChildren];
                    if (completion) completion();
                    [weakScene pc_presentationCompleted];
                    weakScene.physicsWorld.speed = 1;
                });
            });
        });
    }
    else {
        [[self spriteKitView].scene pc_dismissTransitionWillStart];
        [[PCOverlayView overlayView] sceneTransitionWillStart];
        [[self spriteKitView] presentScene:scene];
        [self layoutForScene:scene];

        [scene pc_presentationDidStart];

        // Runloop delay required. Do not remove. JS Reasons.
        __weak typeof(scene) weakScene = scene;
        dispatch_after(dispatch_time(0, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [oldScene removeAllChildren];
            [[PCOverlayView overlayView] sceneTransitionCompleted];
            if (completion) completion();
            [weakScene pc_presentationCompleted];
            weakScene.physicsWorld.speed = 1;
        });
    }
    [self.keyPressedCounts removeAllObjects];
}

- (void)setupWithJSContext:(JSContext *)context {
    [self setupREPLViewControllerForContext:context];
}

- (void)layoutForScene:(SKScene *)scene {
    if (!scene || scene.size.width == 0 || scene.size.height == 0) return;
    
    [self.spriteKitView removeConstraint:self.spriteKitViewAspectRatioConstraint];
    self.spriteKitViewAspectRatioConstraint = [NSLayoutConstraint
                                                constraintWithItem:self.spriteKitView
                                                attribute:NSLayoutAttributeWidth
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:self.spriteKitView
                                                attribute:NSLayoutAttributeHeight
                                                multiplier:scene.size.width / scene.size.height
                                                constant:0];
    [self.spriteKitView addConstraint:self.spriteKitViewAspectRatioConstraint];

    [self updateOverlayScaleFactor];
}

#pragma mark - Private

- (SKSpriteNode *)insertOverlaySnaphsotIntoScene:(SKScene *)scene {
    UIImage *snapshot = [[PCOverlayView overlayView] pc_snapshotAfterScreenUpdates:NO];
    SKSpriteNode *overlaySnapshotNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:snapshot] size:scene.size];
    overlaySnapshotNode.anchorPoint = CGPointMake(0, 0);
    [scene addChild:overlaySnapshotNode];
    return overlaySnapshotNode;
}

- (PCSlideNode *)slideNode {
    PCSKView *view = self.spriteKitView;
    return [[view.pc_scene children] firstObject];
}

#pragma mark - KeyPressed Events

- (NSArray *)keyCommands {
    static NSMutableArray *keyCommands;

    keyCommands = [[NSMutableArray alloc] init];
    if (!self.clearKeyEvents) {
        NSString *cardUUID = [self.cardAtCurrentIndex.cardFilePath stringByDeletingPathExtension];
        NSArray *keyPressInfoForCard = self.runningApp.keyPressedCardLookup[cardUUID];
        for (NSArray *keyInfo in keyPressInfoForCard) {
            if (keyInfo.count < 1) continue;
            NSString *keyString = [NSString pc_stringForKeyCode:[keyInfo[0] integerValue]];
            NSInteger keyModifier = [keyInfo[1] integerValue];
            UIKeyCommand *command = [UIKeyCommand keyCommandWithInput:keyString modifierFlags:keyModifier action:@selector(keyHasBeenPressed:)];
            [keyCommands addObject:command];
        }
    }
    return keyCommands;
}

- (void)keyHasBeenPressed:(UIKeyCommand *)command {
    if ([self isFirstResponder]) {
        NSString *pressedCountKey = [NSString stringWithFormat:@"%ld|%ld", (long)[NSString pc_keyCodeForString:command.input], (long)command.modifierFlags];
        if (self.keyPressedCounts[pressedCountKey]) {
            self.keyPressedCounts[pressedCountKey] = @([self.keyPressedCounts[pressedCountKey] integerValue] + 1);
        } else {
            self.keyPressedCounts[pressedCountKey] = @(1);
        }
        NSNumber *count = self.keyPressedCounts[pressedCountKey];

        NSString *keyCode = [NSString stringWithFormat:@"%ld", (long)[NSString pc_keyCodeForString:command.input]];
        NSString *modifierFlags = [NSString stringWithFormat:@"%ld", (long)command.modifierFlags];
        NSDictionary *userInfo = @{
            PCJSContextEventNotificationEventNameKey: @"keyPress",
            PCJSContextEventNotificationArgumentsKey: @[ keyCode, modifierFlags, count ]
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:userInfo];
    }
}

#pragma mark - Myo Pose Events

- (void)didReceivePoseChange:(NSNotification*)notification {
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    TLMPoseType poseType = pose.type;
    NSString *poseString = [self stringForMyoPoseType:poseType];
    NSDictionary *userInfo = @{
                               PCJSContextEventNotificationEventNameKey: @"myoPoseChanged",
                               PCJSContextEventNotificationArgumentsKey: @[ poseString ],
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:nil userInfo:userInfo];
}

- (NSString *)stringForMyoPoseType:(TLMPoseType)poseType {
    switch (poseType) {
        case TLMPoseTypeRest:
            return @"rest";
        case TLMPoseTypeFist:
            return @"fist";
        case TLMPoseTypeWaveIn:
            return @"waveIn";
        case TLMPoseTypeWaveOut:
            return @"waveOut";
        case TLMPoseTypeFingersSpread:
            return @"fingersSpread";
    }
    return @"";
}

#pragma mark - PCREPLDelegate

- (void)replDidResignFirstResponder {
    [self hideREPL];
}

- (void)replShouldDismiss {
    [self hideREPL];
}

#pragma mark Notifications

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentPhotoPicker:) name:PCPresentPhotoLibraryViewController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPhotoPicker:) name:PCDismissPhotoLibraryViewController object:nil];
}

#pragma mark - Photo Picker

- (void)presentPhotoPicker:(NSNotification *)note {
    UIImagePickerController *picker = note.userInfo[@"viewController"];
    if (!picker) return;

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)dismissPhotoPicker:(NSNotification *)note {
    UIImagePickerController *picker = note.userInfo[@"viewController"];
    if (!picker) return;

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Properties

- (PCCard *)cardAtCurrentIndex {
    return [self.transitionController cardAtCurrentIndex];
}

- (void)updateOverlayScaleFactor {
    PCApp *app = [PCAppViewController lastCreatedInstance].runningApp;
    CGSize designSize = [PCDeviceResolutionSettings resolutionForDeviceTarget:app.deviceSettings.deviceTarget withOrientation:app.deviceSettings.deviceOrientation];

    CGFloat xScaleFactor = self.spriteKitView.bounds.size.width / designSize.width;
    CGFloat yScaleFactor = self.spriteKitView.bounds.size.height / designSize.height;
    [PCOverlayView overlayView].scaleFactor = CGPointMake(xScaleFactor, yScaleFactor);
}

#pragma mark - REPL

- (void)setEnableDefaultREPLGesture:(BOOL)enableDefaultREPLGesture {
    if (_enableDefaultREPLGesture == enableDefaultREPLGesture) {
        return;
    }
    
    _enableDefaultREPLGesture = enableDefaultREPLGesture;
    
    if (enableDefaultREPLGesture) {
        self.replLeftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleREPL:)];
        self.replLeftSwipeRecognizer.numberOfTouchesRequired = 2;
        self.replLeftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:self.replLeftSwipeRecognizer];
    }
    else {
        [self.view removeGestureRecognizer:self.replLeftSwipeRecognizer];
    }
}

- (void)setupREPLViewControllerForContext:(PCJSContext *)context {
    if (!self.replViewController) {
        self.replViewController = [[PCREPLViewController alloc] init];
        self.replViewController.delegate = self;
    }

    // Setup REPL with this slide's context
    __weak typeof (self) weakSelf = self;
    self.replViewController.textInputHandler = ^JSValue *(NSString *text) {
        [weakSelf.replViewController printLine:[NSString stringWithFormat:@"> %@", text]];
        return [context evaluateScript:text];
    };
    context.customExceptionHandler = ^(JSContext *ctx, JSValue *exception) {
        NSLog(@"[%@:%@:%@] %@\n%@", exception[@"sourceURL"], exception[@"line"], exception[@"column"], exception, [exception[@"stack"] toObject]);
        [weakSelf.replViewController printLine:[NSString stringWithFormat:@"Exception: %@", [exception toString]]];
    };
    context.logHandler = ^(NSString *message) {
        NSLog(@"JS: %@", message);
        [weakSelf.replViewController printLine:[NSString stringWithFormat:@"%@", message]];
    };
}

- (void)toggleREPL:(UISwipeGestureRecognizer *)recognizer {
    UISwipeGestureRecognizerDirection direction = recognizer.direction;
    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        [self showREPL];
    }
    else if (direction == UISwipeGestureRecognizerDirectionRight) {
        [self hideREPL];
    }
}

- (void)showREPL {
    if (self.replShowing || !self.replViewController) return;
    
    self.replViewController.view.frame = CGRectMake(CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self.view addSubview:self.replViewController.view];
    [self addChildViewController:self.replViewController];

    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.replViewController.view.frame = ({
            CGRect frame = self.replViewController.view.frame;
            frame.origin.x = 0;
            frame;
        });
    } completion:^(BOOL finished) {
        [self.replViewController didMoveToParentViewController:self];
        [self.replViewController.textField becomeFirstResponder];
    }];

    self.replShowing = YES;
}

- (void)hideREPL {
    if (!self.replShowing) return;
    [self.replViewController willMoveToParentViewController:nil];

    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.replViewController.view.frame = ({
            CGRect frame = self.replViewController.view.frame;
            frame.origin.x = CGRectGetWidth(self.view.frame);
            frame;
        });
    } completion:^(BOOL finished) {
        [self.replViewController.textField resignFirstResponder];
        [self.replViewController.view removeFromSuperview];
        [self.replViewController removeFromParentViewController];
    }];

    self.replShowing = NO;
}

#pragma mark Set Supported Orientations

- (NSUInteger)supportedInterfaceOrientations {
    switch (self.runningApp.deviceSettings.deviceOrientation) {
        case PCDeviceTargetOrientationPortrait:
            return UIInterfaceOrientationMaskPortrait;

        case PCDeviceTargetOrientationLandscape:
        default:
            return UIInterfaceOrientationMaskLandscape;
    }
}

#pragma mark - User Fonts

- (void)loadUserFonts {
    for (NSURL *fontURL in [self.runningApp fontFileURLs]) {
        // skip the font names plist
        if ([[[fontURL absoluteString] pathExtension] isEqualToString:@"plist"]) {
            continue;
        }

        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontURL);
        CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
        CGDataProviderRelease(fontDataProvider);
        CFErrorRef error;
        BOOL success = CTFontManagerRegisterGraphicsFont(newFont, &error);
        if (!success) {
            PCLog(@"Error registering custom font: %@", error);
        }
        CGFontRelease(newFont);
    }
}


#pragma mark - Keyboard Control

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect endKeyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.keyboardFrame = [self.view.window convertRect:endKeyboardRect toView:self.view];
    self.keyboardIsShown = YES;

    if (!self.editingNode) return;

    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self focusTextNodeWithDuration:duration curve:animationCurve];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    self.keyboardIsShown = NO;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self endFocusingOnTextNodeWithDuration:duration];
}

- (void)focusTextNodeWithDuration:(CGFloat)duration curve:(UIViewAnimationCurve)animationCurve {
    const CGFloat PCMinKeyboardDistance = 20;
    CGRect uiFrame = [[PCOverlayView overlayView] convertRect:self.editingNode.frame toOverlayViewFromNode:self.editingNode willAdjustAnchorPointOfView:NO];
    CGFloat minTextY = CGRectGetMinY(uiFrame);
    CGFloat bottomOverlap = MAX(0, CGRectGetHeight(self.keyboardFrame) - minTextY + MIN(PCMinKeyboardDistance, minTextY));
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [UIView setAnimationCurve:animationCurve];
        self.keyboardAvoidingBottomConstraint.constant = bottomOverlap;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)endFocusingOnTextNodeWithDuration:(CGFloat)duration {
    [UIView animateWithDuration:duration animations:^{
        self.keyboardAvoidingBottomConstraint.constant = 0;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

@end
