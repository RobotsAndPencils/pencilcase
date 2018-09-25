//
//  PCResourceManager.m
//  PCLauncher
//
//  Created by Stephen Gazzard on 10/23/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCResourceManager.h"

@implementation PCResourceManager

+ (instancetype)sharedInstance {
    static PCResourceManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end
