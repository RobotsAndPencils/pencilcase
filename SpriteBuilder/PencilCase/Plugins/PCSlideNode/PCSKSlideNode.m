//
//  PCSKSlideNode.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-12.
//
//

#import "PCSKSlideNode.h"
#import "AppDelegate.h"
#import "PCNodeChildrenManagement.h"
#import "PCDeviceResolutionSettings.h"

@interface PCSKSlideNode ()

@property (nonatomic, assign) BOOL followAccelerometer;
@property (assign, nonatomic) BOOL autocreatePhysicsBoundaries;
@property (nonatomic, assign) CGVector gravity;

@end


@implementation PCSKSlideNode

- (BOOL)canParticipateInPhysics {
    return NO;
}

- (CGRect)frame {
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    PCDeviceResolutionSettings *currentResolution = (PCDeviceResolutionSettings *)appDelegate.currentDocument.resolutions[appDelegate.currentDocument.currentResolution];
    return CGRectMake(0, 0, currentResolution.width, currentResolution.height);
}

@end
