//
//  AVAsset+Metadata.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-05-30.
//
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (Metadata)

/**
 *  Fetches the poster frame, video frame size and duration of a video
 *
 *  @param posterFrameTime The time offset at which to grab a poster frame
 *  @param completion      Block called with the poster frame, video frame size and duration. This is a required argument (don't pass nil, it'll throw an exception) since you must release the poster frame CGImageRef.
 */
- (void)fetchMetadataWithCompletion:(void (^)(CGSize, NSTimeInterval))completion;

/**
 *  Fetches the poster frame
 *
 *  @param duration   The asset duration in seconds
 *  @param timeOffset The time offset at which to grab a poster frame
 *  @param completion Block called with the poster frame, video frame size and duration. This is a required argument (don't pass nil, it'll throw an exception) since you must release the poster frame CGImageRef.
 */
- (void)fetchPosterFrameWithDuration:(NSTimeInterval)duration timeOffset:(NSTimeInterval)timeOffset completion:(void(^)(CGImageRef poster))completion;

@end
