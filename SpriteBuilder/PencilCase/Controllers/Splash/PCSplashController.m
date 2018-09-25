//
//  PCSplashController.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-05-22.
//

#import <TransitionKit/TransitionKit.h>
#import "PCSplashController.h"
#import "PCSplashWindowController.h"
#import "PCDeviceResolutionSettings.h"

static NSString *const PCSplashEventNameShowRecents = @"Show Recents";
static NSString *const PCSplashEventNameShowNewProject = @"Show New Project";
static NSString *const PCSplashEventNameCloseWindow = @"Close Window";
static NSString *const PCSplashEventNameCancelNewProject = @"Cancel New Project";
static NSString *const PCSplashEventNameSaveNewProject = @"Save New Project";
static NSString *const PCSplashEventNameOpenOtherProject = @"Open Other Project";
static NSString *const PCSplashEventNameOpenRecentProject = @"Open Recent Project";

@interface PCSplashController ()

@property (nonatomic, strong) TKStateMachine *stateMachine;
@property (nonatomic, strong) PCSplashWindowController *windowController;
@property (nonatomic, copy) void (^saveNewProjectBlock)(PCDeviceTargetType, PCDeviceTargetOrientation);
@property (nonatomic, copy) void (^openRecentProjectBlock)(NSURL *);
@property (nonatomic, copy) void (^openOtherProjectBlock)();
@end

@implementation PCSplashController

- (instancetype)initWithSaveNewProjectBlock:(void (^)(PCDeviceTargetType, PCDeviceTargetOrientation))saveNewProjectBlock openRecentProjectBlock:(void (^)(NSURL *))openRecentProjectBlock openOtherProjectBlock:(void (^)())openOtherProjectBlock {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.windowController = [[PCSplashWindowController alloc] initWithWindowNibName:@"PCRecentsWindow"];
    self.saveNewProjectBlock = saveNewProjectBlock;
    self.openRecentProjectBlock = openRecentProjectBlock;
    self.openOtherProjectBlock = openOtherProjectBlock;

    self.stateMachine = [TKStateMachine new];
    [self setupStateMachine:self.stateMachine];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOpenFilePanelFromNotification:) name:PCShowOpenFilePanelNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openProjectFromNotification:) name:PCOpenProjectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNewProjectFromNotification:) name:PCCreateNewProjectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveNewProjectFromNotification:) name:PCSaveNewProjectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCreatingNewProjectFromNotification:) name:PCCancelCreatingNewProjectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeWindowFromNotification:) name:PCCloseSplashWindowNotification object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Transitions

- (void)showRecents {
    [self fireEventNamed:PCSplashEventNameShowRecents];
}

- (void)showNewProject {
    [self fireEventNamed:PCSplashEventNameShowNewProject];
}

- (void)closeWindow {
    [self fireEventNamed:PCSplashEventNameCloseWindow];
}

- (void)cancelCreatingNewProject {
    [self fireEventNamed:PCSplashEventNameCancelNewProject];
}

- (void)saveNewProjectWithDeviceType:(PCDeviceTargetType)deviceType orientation:(PCDeviceTargetOrientation)deviceOrientation {
    [self fireEventNamed:PCSplashEventNameSaveNewProject userInfo:@{ PCProjectDeviceTargetTypeKey: @(deviceType), PCProjectDeviceTargetOrientationKey: @(deviceOrientation) }];
}

- (void)openOtherProject {
    [self fireEventNamed:PCSplashEventNameOpenOtherProject];
}

- (void)openRecentProject:(NSURL *)projectURL {
    [self fireEventNamed:PCSplashEventNameOpenRecentProject userInfo:@{ PCOpenProjectURLKey: projectURL }];
}

#pragma mark - Notification Handlers

- (void)showOpenFilePanelFromNotification:(NSNotification *)notification {
    [self openOtherProject];
}

- (void)openProjectFromNotification:(NSNotification *)notification {
    NSURL *url = notification.userInfo[PCOpenProjectURLKey];
    [self openRecentProject:url];
}

- (void)createNewProjectFromNotification:(NSNotification *)notification {
    [self showNewProject];
}

- (void)saveNewProjectFromNotification:(NSNotification *)notification {
    PCDeviceTargetType deviceType = (PCDeviceTargetType)[notification.userInfo[PCProjectDeviceTargetTypeKey] integerValue];
    PCDeviceTargetOrientation deviceOrientation = (PCDeviceTargetOrientation)[notification.userInfo[PCProjectDeviceTargetOrientationKey] integerValue];
    [self saveNewProjectWithDeviceType:deviceType orientation:deviceOrientation];
}

- (void)cancelCreatingNewProjectFromNotification:(NSNotification *)notification {
    [self cancelCreatingNewProject];
}

- (void)closeWindowFromNotification:(NSNotification *)notification {
    [self closeWindow];
}

#pragma mark - Private

- (void)fireEventNamed:(NSString *)eventName {
    [self fireEventNamed:eventName userInfo:nil];
}

- (void)fireEventNamed:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    if (![self.stateMachine canFireEvent:eventName]) {
        return;
    }

    NSError *eventError;
    BOOL success = [self.stateMachine fireEvent:eventName userInfo:userInfo error:&eventError];
    if (!success) {
        PCLog(@"Error firing splash state machine event %@: %@", eventName, eventError);
    }
}

- (void)setupStateMachine:(TKStateMachine *)stateMachine {
    TKState *closed = [TKState stateWithName:@"Closed"];
    closed.didEnterStateBlock = ^(TKState *state, TKTransition *transition) {
        [self.windowController.window close];
    };

    TKState *viewingRecents = [TKState stateWithName:@"Viewing Recents"];
    viewingRecents.didEnterStateBlock = ^(TKState *state, TKTransition *transition){
        [self.windowController showRecentsView];
    };
    
    TKState *creatingNewProject = [TKState stateWithName:@"Creating New Project"];
    creatingNewProject.didEnterStateBlock = ^(TKState *state, TKTransition *transition) {
        [self.windowController showNewProjectView];
    };
    
    [stateMachine addStates:@[ closed, viewingRecents, creatingNewProject ]];
    stateMachine.initialState = closed;

    TKEvent *showRecents = [TKEvent eventWithName:PCSplashEventNameShowRecents transitioningFromStates:@[ closed ] toState:viewingRecents];
    TKEvent *showNewProject = [TKEvent eventWithName:PCSplashEventNameShowNewProject transitioningFromStates:@[ closed, viewingRecents ] toState:creatingNewProject];
    TKEvent *closeWindow = [TKEvent eventWithName:PCSplashEventNameCloseWindow transitioningFromStates:@[ viewingRecents, creatingNewProject ] toState:closed];
    TKEvent *cancelNewProject = [TKEvent eventWithName:PCSplashEventNameCancelNewProject transitioningFromStates:@[ creatingNewProject ] toState:viewingRecents];
    TKEvent *saveNewProject = [TKEvent eventWithName:PCSplashEventNameSaveNewProject transitioningFromStates:@[ creatingNewProject ] toState:closed];
    saveNewProject.didFireEventBlock = ^(TKEvent *event, TKTransition *transition){
        PCDeviceTargetType deviceType = (PCDeviceTargetType)[transition.userInfo[PCProjectDeviceTargetTypeKey] integerValue];
        PCDeviceTargetOrientation deviceOrientation = (PCDeviceTargetOrientation)[transition.userInfo[PCProjectDeviceTargetOrientationKey] integerValue];
        if (self.saveNewProjectBlock) self.saveNewProjectBlock(deviceType, deviceOrientation);
    };
    TKEvent *openOtherProject = [TKEvent eventWithName:PCSplashEventNameOpenOtherProject transitioningFromStates:@[ viewingRecents, closed ] toState:closed];
    openOtherProject.didFireEventBlock = ^(TKEvent *event, TKTransition *transition) {
        if (self.openOtherProjectBlock) self.openOtherProjectBlock();
    };
    TKEvent *openRecentProject = [TKEvent eventWithName:PCSplashEventNameOpenRecentProject transitioningFromStates:@[ viewingRecents ] toState:closed];
    openRecentProject.didFireEventBlock = ^(TKEvent *event, TKTransition *transition) {
        NSURL *url = transition.userInfo[PCOpenProjectURLKey];
        if (self.openRecentProjectBlock) self.openRecentProjectBlock(url);
    };

    [stateMachine addEvents:@[ showRecents, showNewProject, closeWindow, cancelNewProject, saveNewProject, openOtherProject, openRecentProject ]];

    [stateMachine activate];
}

@end
