//
//  AVAsset+Metadata.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-05-30.
//
//

#import "AVAsset+Metadata.h"

@implementation AVAsset (Metadata)

- (void)fetchMetadataWithCompletion:(void (^)(CGSize, NSTimeInterval))completion {
    NSAssert(completion, @"A completion block must be provided in order to release the CGImageRef");
    
    [self loadValuesAsynchronouslyForKeys:@[ @"commonMetadata" ] completionHandler:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSArray *mediaTracks = [self tracksWithMediaType:AVMediaTypeVideo];
            if ([mediaTracks count] == 0) {
                completion(CGSizeZero, 0.0);
                return;
            }
            
            AVAssetTrack *firstMediaTrack = [mediaTracks objectAtIndex:0];
            
            CGSize naturalSize = firstMediaTrack.naturalSize;
            
            CMTime duration = self.duration;
            CGFloat durationInSeconds = (CGFloat)duration.value / (CGFloat)duration.timescale;
            
            completion(naturalSize, durationInSeconds);
        });
    }];
}

- (void)fetchPosterFrameWithDuration:(NSTimeInterval)duration timeOffset:(NSTimeInterval)timeOffset completion:(void(^)(CGImageRef poster))completion {
    CMTime posterTime;
    
    // Ensure it's possible to grab a poster frame at the desired time
    if (duration > timeOffset) {
        posterTime = CMTimeMakeWithSeconds(timeOffset, 1);
    } else {
        posterTime = CMTimeMakeWithSeconds(0, 1);
    }
    
    NSError *error;
    CGImageRef imageRef = [self posterFrameAtTime:posterTime error:&error];
    if (error) {
        completion(NULL);
        return;
    }
    
    completion(imageRef);
}

- (CGImageRef)posterFrameAtTime:(CMTime)time error:(NSError * __autoreleasing *)error {
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self];
    NSError *internalError;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&internalError];
    if (!imageRef && error) {
        *error = internalError;
    }
    return imageRef;
}

@end
