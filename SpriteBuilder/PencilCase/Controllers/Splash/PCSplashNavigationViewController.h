//
//  PCRecentsNavigationViewController.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-14.
//
//

#import <Cocoa/Cocoa.h>
#import "PCNewProjectViewController.h"
#import "PCRecentsViewController.h"

@interface PCSplashNavigationViewController : NSViewController

- (void)transitionToRecentsView;
- (void)transitionToNewProjectView;

@end
