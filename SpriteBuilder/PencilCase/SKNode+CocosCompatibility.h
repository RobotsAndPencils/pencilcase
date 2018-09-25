//
//  SKNode(CocosCompatibility) 
//  SpriteBuilder
//
//  Created by Brandon Evans on 14-06-12.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, PCEditorResizeBehaviour) {
    PCEditorResizeBehaviourScale,
    PCEditorResizeBehaviourContentSize
};

@class PlugInNode;
@class SequencerNodeProperty;
@class SequencerKeyframe;

@interface SKNode (CocosCompatibility)

@property (nonatomic, strong) id userObject;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) CGFloat scaleX;
@property (nonatomic, assign) CGFloat scaleY;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat skewX;
@property (nonatomic, assign) CGFloat skewY;
@property (nonatomic, assign, readonly) BOOL flipX;
@property (nonatomic, assign, readonly) BOOL flipY;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGSize size;

@end
