//
//  PC3DAnimation.h
//  SpriteBuilder
//
//  Created by Reuben Lee on 2015-04-02.
//
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface PC3DAnimation : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CAAnimation *animation;
@property (strong, nonatomic) NSString *skeletonName;
@property (assign, nonatomic) NSUInteger repeatCount;
@property (assign, nonatomic) CGFloat fadeInDuration;
@property (assign, nonatomic) CGFloat fadeOutDuration;
@property (assign, nonatomic) BOOL repeatForever;
@property (readonly, assign, nonatomic) CGFloat duration;

- (void)refresh; 

@end
