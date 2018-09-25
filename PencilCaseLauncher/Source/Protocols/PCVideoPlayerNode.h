//
//  PCVideoPlaying.h
//  Pods
//
//  Created by Cody Rayment on 2015-04-15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCTimelineRepeat) {
    PCTimelineRepeatNone = 0,
    PCTimelineRepeatRepeat,
    PCTimelineRepeatCount
};

typedef NS_ENUM(NSInteger, EventInspectorVideoControlChangedState) {
    EventInspectorVideoControlPlayVideo = 0,
    EventInspectorVideoControlPauseVideo,
    EventInspectorVideoControlVideoFinished,
    EventInspectorVideoControlWillEnterFullScreen,
    EventInspectorVideoControlDidEnterFullScreen,
    EventInspectorVideoControlWillExitFullScreen,
    EventInspectorVideoControlDidExitFullScreen,
    EventInspectorVideoControlEnteredAirPlay,
    EventInspectorVideoControlExitedAirPlay
};

@protocol PCVideoPlayerDelegate <NSObject>

@property (copy, nonatomic) NSString *fileUUID;

- (void)videoControlStateChanged:(EventInspectorVideoControlChangedState)newState;

@end

@protocol PCVideoPlayerNode <NSObject>

@property (weak, nonatomic) id<PCVideoPlayerDelegate> videoPlayingDelegate;
@property (strong, nonatomic) NSString *videoFilePath;
@property (strong, nonatomic) NSString *videoPosterPath;
@property (nonatomic, strong) NSArray *timelineTrimTimes;
@property (nonatomic, assign) PCTimelineRepeat timelineRepeat;
@property (nonatomic, assign) BOOL autoplay;
@property (assign, nonatomic) CGFloat playbackTime;
@property (assign, nonatomic) CGFloat playbackRate;
@property (assign, nonatomic, readonly) CGFloat duration;

- (void)play;
- (void)pause;

@end
