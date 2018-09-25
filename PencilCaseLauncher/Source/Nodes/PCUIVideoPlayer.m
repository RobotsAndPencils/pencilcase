//
//  PCUIVideoPlayer.m
//  Pods
//
//  Created by Cody Rayment on 2015-04-15.
//
//

#import "PCUIVideoPlayer.h"
#import "SKNode+JavaScript.h"
#import "PCOverlayView.h"
#import "SKNode+LifeCycle.h"
#import "CCFileUtils.h"
#import "PCResourceManager.h"
#import "PCUIVideoPlayerCoordinator.h"

static const CGFloat PCLastPlayTimeNone = -1;

@interface PCUIVideoPlayer ()

@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIImageView *thumbnailImageView;
@property (strong, nonatomic) UIImageView *playImageView;

@property (assign, nonatomic) CGFloat lastPlayTime;

@end

@implementation PCUIVideoPlayer

@synthesize videoPlayingDelegate = _videoPlayingDelegate;
@synthesize videoFilePath = _videoFilePath;
@synthesize videoPosterPath = _videoPosterPath;
@synthesize timelineTrimTimes = _timelineTrimTimes;
@synthesize timelineRepeat = _timelineRepeat;
@synthesize autoplay = _autoplay;
@synthesize playbackRate = _playbackRate;

- (instancetype)init {
    self = [super init];
    if (self) {
        _playbackRate = 1;
        _lastPlayTime = PCLastPlayTimeNone;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Life Cycle

- (void)pc_didEnterScene {
    [self setupUI];
    [self setupNotifications];
    [super pc_didEnterScene];
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_presentationCompleted {
    [super pc_presentationCompleted];
    if (self.autoplay) {
        [self play];
    }
    else {
        [self.moviePlayer prepareToPlay];
    }
}

- (void)pc_dismissTransitionWillStart {
    [self.moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Private

- (void)setupUI {
    if (self.container) {
        [self.container removeFromSuperview];
    }

    self.container = [[UIView alloc] init];
    self.container.backgroundColor = [UIColor blackColor];

    UIImage *thumbnail = [UIImage imageWithContentsOfFile:self.videoPosterPath];
    self.thumbnailImageView = [[UIImageView alloc] initWithImage:thumbnail];
    [self.container addSubview:self.thumbnailImageView];

    UIImage *playImage = [UIImage imageNamed:@"PCPlayerPlay"];
    self.playImageView = [[UIImageView alloc] initWithImage:playImage];
    [self.container addSubview:self.playImageView];

    [self updateFromTrim];

    if (self.autoplay) {
        self.thumbnailImageView.hidden = YES;
        self.playImageView.hidden = YES;
        [self play];
    }

    [self layout];
}

- (void)teardownVideo {
    if (!self.moviePlayer) return;
    self.lastPlayTime = self.moviePlayer.currentPlaybackTime;
    [self removeVideoPlayerFromView];
}

- (void)removeVideoPlayerFromView {
    if (!self.moviePlayer) return;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;

    self.thumbnailImageView.hidden = NO;
    self.playImageView.hidden = NO;
}

- (void)loadVideo {
    NSURL *movieURL;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!PCIsEmpty(self.videoFilePath) && [fileManager fileExistsAtPath:self.videoFilePath]) {
        movieURL = [NSURL fileURLWithPath:self.videoFilePath];
    }
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    [self.moviePlayer setShouldAutoplay:self.autoplay];
    [self.container insertSubview:self.moviePlayer.view atIndex:0];
    [self updateFromTrim];
    [self layout];
    [self setupNotifications];
}

- (void)reset {
    self.thumbnailImageView.hidden = NO;
    self.playImageView.hidden = NO;

    // Teardown and setup a new player.
    // It doesn't respect trim times
    // http://stackoverflow.com/questions/15539033/mpmovieplayercontroller-restarting-instead-of-resuming
    [self removeVideoPlayerFromView];

    if (self.timelineRepeat == PCTimelineRepeatRepeat) {
        [self loadVideo];
        [self play];
    } else {
        [[PCUIVideoPlayerCoordinator sharedCoordinator] videoPlayerFinished:self];
    }
}

- (void)layout {
    self.moviePlayer.view.frame = CGRectMake(0, 0, self.container.bounds.size.width, self.container.bounds.size.height);
    self.thumbnailImageView.frame = CGRectMake(0, 0, self.container.bounds.size.width, self.container.bounds.size.height);
    self.playImageView.center = CGPointMake(CGRectGetMidX(self.container.bounds), CGRectGetMidY(self.container.bounds));
}

- (void)updateFromTrim {
    NSTimeInterval start = [[self.timelineTrimTimes firstObject] doubleValue];
    NSTimeInterval end = [[self.timelineTrimTimes lastObject] doubleValue];

    self.moviePlayer.initialPlaybackTime = start;
    self.moviePlayer.endPlaybackTime = end;
}

- (void)loadLastPlayTime {
    if (self.lastPlayTime == PCLastPlayTimeNone) return;
    self.moviePlayer.currentPlaybackTime = self.lastPlayTime;
    self.lastPlayTime = PCLastPlayTimeNone;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] == 1 && self.playImageView && !self.playImageView.hidden) {
        [self play];
    }
}

- (void)dispatchVideoControlsChangedHandlersWithType:(EventInspectorVideoControlChangedState)videoState {
    [self.videoPlayingDelegate videoControlStateChanged:videoState];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayStateDidChange:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidEnterFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidExitFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airPlayVideoActiveDidChange:) name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:self.moviePlayer];
}

#pragma mark - Observers

- (void)displayStateDidChange:(NSNotification *)notification {
    if (self.moviePlayer.readyForDisplay) {
        [self loadLastPlayTime];
    }
}

- (void)playbackStateDidChange:(NSNotification *)notification {
    float endBuffer = 0.01; // buffer to test end of playback
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlPlayVideo];
    } else if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused && (self.moviePlayer.currentPlaybackTime + endBuffer < self.moviePlayer.endPlaybackTime)) {
        [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlPauseVideo];
    }
}

- (void)playbackDidFinish:(NSNotification *)notification {
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlVideoFinished];
    [self reset];
}

- (void)playerWillEnterFullscreen:(NSNotification *)notification {
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlWillEnterFullScreen];
}

- (void)playerDidEnterFullscreen:(NSNotification *)notification {
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlDidEnterFullScreen];
}

- (void)playerWillExitFullscreen:(NSNotification *)notification {
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlWillExitFullScreen];
}

- (void)playerDidExitFullscreen:(NSNotification *)notification {
    [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlDidExitFullScreen];
}

- (void)airPlayVideoActiveDidChange:(NSNotification *)notification {
    if (self.moviePlayer.airPlayVideoActive) {
        [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlEnteredAirPlay];
    } else {
        [self dispatchVideoControlsChangedHandlersWithType:EventInspectorVideoControlExitedAirPlay];
    }
}

#pragma mark - Properties

- (void)setTimelineRepeat:(PCTimelineRepeat)timelineRepeat {
    _timelineRepeat = timelineRepeat;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.moviePlayer.view.userInteractionEnabled = userInteractionEnabled;
}

- (void)setTimelineTrimTimes:(NSArray *)timelineTrimTimes {
    if (!timelineTrimTimes || [timelineTrimTimes count] != 2) return;
    _timelineTrimTimes = timelineTrimTimes;
    [self updateFromTrim];
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.container;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (frameChanged) {
        [self layout];
    }
}

#pragma mark - PCVideoPlaying

- (void)play {
    [[PCUIVideoPlayerCoordinator sharedCoordinator] setActiveVideoPlayer:self];

    if (!self.moviePlayer.isPreparedToPlay) {
        [self.moviePlayer prepareToPlay];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self play];
        });
        return;
    }
    self.thumbnailImageView.hidden = YES;
    self.playImageView.hidden = YES;
    [self.moviePlayer play];
    self.moviePlayer.currentPlaybackRate = self.playbackRate;
}

- (void)pause {
    [self.moviePlayer pause];
}

- (void)setPlaybackTime:(CGFloat)playbackTime {
    self.moviePlayer.currentPlaybackTime = playbackTime;
}

- (CGFloat)playbackTime {
    return self.moviePlayer.currentPlaybackTime;
}

- (void)setPlaybackRate:(CGFloat)playbackRate {
    _playbackRate = playbackRate;
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        self.moviePlayer.currentPlaybackRate = playbackRate;
    }
}

- (CGFloat)duration {
    return self.moviePlayer.duration;
}

@end
