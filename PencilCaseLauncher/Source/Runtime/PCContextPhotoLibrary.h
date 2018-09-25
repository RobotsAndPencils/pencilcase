//
//  PCContextPhotoLibrary.h
//  Pods
//
//  Created by Stephen Gazzard on 2015-02-24.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

// Card Transitions
#import "RPJSCoreModule.h"


@interface PCContextPhotoLibrary : NSObject <RPJSCoreModule>

/**
 Requests access to the users photo library if it is not already granted, then grabs the last image if permission is given.
 */
+ (void)loadLastImageFromPhotoLibrary;


@end
