//
//  PCRecentsNavigationViewController.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-14.
//
//

#import "PCSplashNavigationViewController.h"

@interface PCSplashNavigationViewController ()

@property (strong, nonatomic) PCRecentsViewController *recentsViewController;
@property (strong, nonatomic) PCNewProjectViewController *createNewProjectViewController;

@end

@implementation PCSplashNavigationViewController

- (void)loadView {
    [super loadView];

    self.recentsViewController = [[PCRecentsViewController alloc] initWithNibName:@"PCRecentsViewController" bundle:nil];

    [self.recentsViewController loadView];
    [self addChildViewController:self.recentsViewController];
    [self.view addSubview:self.recentsViewController.view];

    self.createNewProjectViewController = [[PCNewProjectViewController alloc] initWithNibName:@"PCNewProjectViewController" bundle:nil];
    [self addChildViewController:self.createNewProjectViewController];
}

- (void)transitionToRecentsView {
    [self.recentsViewController reload];

    // No-op if the recents view is already visible
    if (self.recentsViewController.view.superview) {
        return;
    }

    [self transitionFromViewController:self.createNewProjectViewController toViewController:self.recentsViewController options:NSViewControllerTransitionNone completionHandler:nil];
}

- (void)transitionToNewProjectView {
    if (self.recentsViewController.view.superview) {
        [self transitionFromViewController:self.recentsViewController toViewController:self.createNewProjectViewController options:NSViewControllerTransitionNone completionHandler:nil];
    }
    else {
        [self.view addSubview:self.createNewProjectViewController.view];
    }
}

@end
