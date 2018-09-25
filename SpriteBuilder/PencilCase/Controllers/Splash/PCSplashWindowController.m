//
//  PCRecentsViewController.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-03-19.
//
//

#import "PCSplashWindowController.h"
#import "PCProjectSettings.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#import "PCNewProjectViewController.h"

@interface PCSplashWindowController () <NSTableViewDataSource>

@property (weak, nonatomic) IBOutlet NSView *recentsContentView;
@property (strong, nonatomic) PCSplashNavigationViewController *navigationController;

@end

@implementation PCSplashWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.navigationController = [[PCSplashNavigationViewController alloc] initWithNibName:@"PCSplashNavigationViewController" bundle:nil];
    [self.recentsContentView addSubview:self.navigationController.view];
}

#pragma mark - Actions

- (void)showRecentsView {
    [self transitionToRecentsView];
    [self showWindow:self];
}

- (void)showNewProjectView {
    [self transitionToNewProjectView];
    [self showWindow:self];
}

- (void)transitionToRecentsView {
    [self.navigationController transitionToRecentsView];
}

- (void)transitionToNewProjectView {
    [self.navigationController transitionToNewProjectView];
}

@end
