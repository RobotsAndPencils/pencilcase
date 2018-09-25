//
//  PCVideoPlayer.h
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2/24/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCVideoPlayerNode.h"

@interface PCVideoPlayer : SKSpriteNode

@property (copy, nonatomic) NSString *fileUUID;
@property (nonatomic, strong) NSArray *timelineTrimTimes;
@property (nonatomic, assign) CGFloat posterFrameTime;
@property (nonatomic, assign) PCTimelineRepeat timelineRepeat;
@property (nonatomic, assign) BOOL autoplay;
@property (nonatomic, assign) BOOL showUserControls;

- (void)addVideoControlChangedHandlerForState:(NSNumber *)state handler:(JSValue *)handler;

@end
