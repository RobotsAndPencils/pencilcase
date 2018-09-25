//
//  PCMPMovieCoordinator.h
//  Pods
//
//  Created by Stephen Gazzard on 2015-06-18.
//
//

#import <Foundation/Foundation.h>

@class PCUIVideoPlayer;

@interface PCUIVideoPlayerCoordinator : NSObject

+ (PCUIVideoPlayerCoordinator *)sharedCoordinator;

- (void)setActiveVideoPlayer:(PCUIVideoPlayer *)activeVideoPlayer;
- (void)videoPlayerFinished:(PCUIVideoPlayer *)videoPlayer;

@end
