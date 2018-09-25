//
//  PCNewProjectViewController.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-14.
//
//

#import <Cocoa/Cocoa.h>
#import "PCProjectSettings.h"

@class PCSplashNavigationViewController;

@interface PCNewProjectViewController : NSViewController

@property (assign, nonatomic) PCDeviceTargetType deviceTarget;
@property (assign, nonatomic) PCDeviceTargetOrientation deviceOrientation;

@end
