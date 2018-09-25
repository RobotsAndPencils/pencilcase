//
//  PCVideoPlayer+JSExport.h
//  PCPlayer
//
//  Created by Quinn Thomson on 2014-07-08.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCVideoPlayer.h"
#import "NSObject+JSDataBinding.h"

@protocol PCVideoPlayerExport <JSExport, NSObjectJSDataBindingExport>

@property (nonatomic, assign) PCTimelineRepeat timelineRepeat;
@property (nonatomic, assign) CGFloat posterFrameTime;

@property (nonatomic, assign) CGFloat playbackTime;
@property (nonatomic, assign) CGFloat playbackRate;
@property (nonatomic, readonly) CGFloat duration;
@property (nonatomic, readonly) BOOL autoplay;

JSExportAs(addVideoControlChangedHandler,
- (void)addVideoControlChangedHandlerForState:(NSNumber *)state handler:(JSValue *)handler
);

- (void)play;
- (void)pause;

@end

@interface PCVideoPlayer (JSExport) <PCVideoPlayerExport>

@end
