//
//  JSValue+CGVector.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-09-03.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "JSValue+CGVector.h"

@implementation JSValue (CGVector)

+ (JSValue *)valueWithVector:(CGVector)vector inContext:(JSContext *)context {
    JSValue *value = [[JSValue alloc] init];
    [value setValue:@(vector.dx) forProperty:@"dx"];
    [value setValue:@(vector.dy) forProperty:@"dy"];
    return value;
}

- (CGVector)toVector {
    if (!([self hasProperty:@"dx"] && [self hasProperty:@"dy"])) return CGVectorMake(0, 0);
    return CGVectorMake([[self valueForProperty:@"dx"] toDouble], [[self valueForProperty:@"dy"] toDouble]);
}

@end
