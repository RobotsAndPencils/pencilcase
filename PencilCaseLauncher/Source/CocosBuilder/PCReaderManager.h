//
//  PCReaderManager.h
//  PCPlayer
//
//  Created by Orest Nazarewycz on 3/3/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCBReader.h"

@interface PCReaderManager : NSObject
@property (strong, nonatomic) CCBReader *currentReader;

+ (id)sharedManager;

@end
