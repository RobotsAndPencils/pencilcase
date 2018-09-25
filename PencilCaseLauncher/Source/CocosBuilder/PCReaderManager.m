//
//  PCReaderManager.m
//  PCPlayer
//
//  Created by Orest Nazarewycz on 3/3/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCReaderManager.h"

@implementation PCReaderManager

+ (id)sharedManager {
    static PCReaderManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

@end




