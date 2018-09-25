//
//  PCUpdateNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-22.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@protocol PCUpdateNode <NSObject>

- (void)update:(NSTimeInterval)timeInterval;

@optional
- (void)physicsDidSimulate;

@end
