//
//  PCResourceManager.h
//  PCLauncher
//
//  Created by Stephen Gazzard on 10/23/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  PCResourceManager on the player side is just a singleton access point to the dictionary associating
  UUIDs with file paths
 */
@interface PCResourceManager : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) NSDictionary *resources;

@end
