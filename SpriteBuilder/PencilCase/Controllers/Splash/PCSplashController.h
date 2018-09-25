//
//  PCSplashController.h
//  PencilCase
//
//  Created by Brandon Evans on 15-05-22.
//
//  A controller to coordinate UI for the splash window.
//
//  This interface only exposes the transitions between UI states. This class listens for notifications from child view
//  controllers and handles them itself and only exposes blocks to delegate logic to the app delegate where appropriate.
//
//  This class doesn't handle any business logic for projects (creating, opening, saving, etc.).
//

#import "PCDeviceResolutionSettings.h"

@class PCSplashWindowController;


@interface PCSplashController : NSObject

- (instancetype)initWithSaveNewProjectBlock:(void (^)(PCDeviceTargetType, PCDeviceTargetOrientation))saveNewProjectBlock openRecentProjectBlock:(void (^)(NSURL *))openRecentProjectBlock openOtherProjectBlock:(void (^)())openOtherProjectBlock;

#pragma mark - Transitions

- (void)closeWindow;
- (void)showRecents;
- (void)showNewProject;
- (void)cancelCreatingNewProject;
- (void)openOtherProject;

@end
