//
//  PCMPMovieCoordinator.m
//  Pods
//
//  Created by Stephen Gazzard on 2015-06-18.
//
//

#import "PCUIVideoPlayerCoordinator.h"
#import "PCUIVideoPlayer.h"

@interface PCUIVideoPlayerCoordinator()

@property (weak, nonatomic) PCUIVideoPlayer *activeVideoPlayer;

@end

@implementation PCUIVideoPlayerCoordinator

+ (PCUIVideoPlayerCoordinator *)sharedCoordinator {
    static PCUIVideoPlayerCoordinator *sharedCoordinator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoordinator = [[PCUIVideoPlayerCoordinator alloc] init];
    });
    return sharedCoordinator;
}

- (void)setActiveVideoPlayer:(PCUIVideoPlayer *)videoPlayer {
    if (self.activeVideoPlayer == videoPlayer) return;
    [self.activeVideoPlayer teardownVideo];
    _activeVideoPlayer = videoPlayer;
    [self.activeVideoPlayer loadVideo];
}

- (void)videoPlayerFinished:(PCUIVideoPlayer *)videoPlayer {
    if (self.activeVideoPlayer != videoPlayer) return;
    self.activeVideoPlayer = nil;
}

@end
