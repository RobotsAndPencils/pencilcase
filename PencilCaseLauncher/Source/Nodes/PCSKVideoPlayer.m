//
//  PCSKVideoPlayer.m
//  Pods
//
//  Created by Cody Rayment on 2015-04-15.
//
//

#import "PCSKVideoPlayer.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+CocosCompatibility.h"
#import <AVFoundation/AVFoundation.h>

@interface PCSKVideoPlayer ()

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) SKVideoNode *videoNode;
@property (strong, nonatomic) SKSpriteNode *posterNode;
@property (strong, nonatomic) id boundaryObserver;
@property (assign, nonatomic) BOOL stoppedByTrim;

@end

@implementation PCSKVideoPlayer

@synthesize videoPlayingDelegate = _videoPlayingDelegate;
@synthesize videoFilePath = _videoFilePath;
@synthesize videoPosterPath = _videoPosterPath;
@synthesize timelineTrimTimes = _timelineTrimTimes;
@synthesize timelineRepeat = _timelineRepeat;
@synthesize autoplay = _autoplay;
@synthesize playbackRate = _playbackRate;

- (void)pc_didEnterScene {
    [self setupUI];
    [super pc_didEnterScene];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pc_presentationCompleted {
    [super pc_presentationCompleted];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.autoplay) [self play];
    });
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    self.player.rate = 0;
}

#pragma mark - Private

- (void)setupUI {
    NSURL *videoURL;
    if (!PCIsEmpty(self.videoFilePath) && [[NSFileManager defaultManager] fileExistsAtPath:self.videoFilePath]) {
        videoURL = [NSURL fileURLWithPath:self.videoFilePath isDirectory:NO];
    }
    self.player = [AVPlayer playerWithURL:videoURL];
    self.videoNode = [SKVideoNode videoNodeWithAVPlayer:self.player];
    [self addChild:self.videoNode];

    SKTexture *posterTexture;
    if (!PCIsEmpty(self.videoPosterPath) && [[NSFileManager defaultManager] fileExistsAtPath:self.videoPosterPath]) {
        posterTexture = [SKTexture textureWithImage:[UIImage imageWithContentsOfFile:self.videoPosterPath]];
        self.posterNode = [SKSpriteNode spriteNodeWithTexture:posterTexture];
    }
    else {
        self.posterNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:self.videoNode.size];
    }
    [self addChild:self.posterNode];

    [self layout];

    [self setupNotifications];
    [self updateFromTrim];
}

- (void)layout {
    self.videoNode.size = self.contentSize;
    [self.videoNode pc_centerInParent];

    self.posterNode.contentSize = self.posterNode.texture.size;
    self.posterNode.xScale = self.contentSize.width / self.posterNode.contentSize.width;
    self.posterNode.yScale = self.contentSize.height / self.posterNode.contentSize.height;
    [self.posterNode pc_centerInParent];
}

- (void)updateFromTrim {
    if (self.boundaryObserver) [self.player removeTimeObserver:self.boundaryObserver];

    __weak typeof(self) weakSelf = self;
    [self.player addBoundaryTimeObserverForTimes:@[ [NSValue valueWithCMTime:[self endTime]] ] queue:nil usingBlock:^{
        if (weakSelf.timelineRepeat == PCTimelineRepeatRepeat) {
            [weakSelf.player seekToTime:[weakSelf startTime]];
        }
        else {
            weakSelf.stoppedByTrim = YES;
            [weakSelf stop];
        }
    }];

    // If not yet playing, set the playhead to the start position since it starts at 0 even with a different initialPlaybackTime
    if (![self isPlaying]) {
        [self.player seekToTime:[self startTime]];
    }
}

- (CMTime)startTime {
    NSTimeInterval start = [[self.timelineTrimTimes firstObject] doubleValue];
    CMTime startTime = CMTimeMake(start, 1);
    return startTime;
}

- (CMTime)endTime {
    NSTimeInterval end = [[self.timelineTrimTimes lastObject] doubleValue];
    CMTime endTime = CMTimeMake(end, 1);
    return endTime;
}

- (BOOL)isPlaying {
    return self.player.rate > 0;
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPlaying:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:nil];
}

- (void)dispatchVideoControlsChangedHandlersWithType:(EventInspectorVideoControlChangedState)videoState {
    [self.videoPlayingDelegate videoControlStateChanged:videoState];
}

- (void)finishedPlaying:(NSNotification *)notification {
    if (notification.object != self.player.currentItem) return;
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlVideoFinished];
}

#pragma mark - PCVideoPlaying

- (void)play {
    self.posterNode.hidden = YES;
    if (self.playbackTime == self.duration || self.stoppedByTrim) {
        [self.player seekToTime:[self startTime]];
    }
    [self.videoNode play];
    self.player.rate = self.playbackRate;
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlPlayVideo];
    self.stoppedByTrim = NO;
}

- (void)pause {
    [self.videoNode pause];
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlPauseVideo];
}

- (void)stop {
    [self.videoNode pause];
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlVideoFinished];
}

- (void)setPlaybackTime:(CGFloat)playbackTime {
    [self.player seekToTime:CMTimeMakeWithSeconds(playbackTime, 1)];
}

- (CGFloat)playbackTime {
    return self.player.currentTime.value / self.player.currentTime.timescale;
}

- (void)setPlaybackRate:(CGFloat)playbackRate {
    _playbackRate = playbackRate;
    self.player.rate = playbackRate;
}

- (CGFloat)duration {
    return self.player.currentItem.asset.duration.value / self.player.currentItem.asset.duration.timescale;
}

@end
