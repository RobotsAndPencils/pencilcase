//
//  PCRecentsViewController.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-03-19.
//
//

#import <Cocoa/Cocoa.h>
#import "PCSplashNavigationViewController.h"

@interface PCSplashWindowController : NSWindowController

/**
 * Shows the splash window and navigates to the recents view if necessary
 */
- (void)showRecentsView;

/**
 * Shows the splash window and navigates to the new project view if necessary
 */
- (void)showNewProjectView;

- (void)transitionToRecentsView;
- (void)transitionToNewProjectView;

@end
