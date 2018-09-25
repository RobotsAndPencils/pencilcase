//
//  NSUUID+JSExport.m
//  PCPlayer
//
//  Created by Brandon on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "NSUUID+JSExport.h"

@implementation NSUUID (JSExport)

+ (NSString *)uuid {
    return [[self UUID] UUIDString];
}

@end
