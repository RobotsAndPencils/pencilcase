//
//  SKNode+GeneralHelpers.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@class PCScene;
@class PCSlideNode;

@interface SKNode (GeneralHelpers)

@property (assign, nonatomic, readonly) BOOL anyParentNotVisible;
@property (assign, nonatomic, readonly) PCScene *pc_PCScene;

- (SKNode *)nodeWithUUID:(NSString *)uuid;
- (SKNode *)nodeWithClass:(Class)class;
- (SKNode *)nodeNamed:(NSString *)name;
- (SKTexture *)__pc_createTexture;
- (PCSlideNode *)slideNode;

@end
