//
//  PCSKVideoPlayer.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-03.
//
//

#import <SpriteKit/SpriteKit.h>

@class PCResource;


typedef NS_ENUM(NSInteger, PCTimelineRepeat) {
    PCTimelineRepeatNone = 0,
    PCTimelineRepeatRepeat,
    PCTimelineRepeatCount
};


@interface PCSKVideoPlayer : SKSpriteNode

@property (nonatomic, copy) NSString *posterFilePath;
@property (nonatomic, strong) NSArray *timelineTrimTimes;
@property (nonatomic, assign) CGFloat posterFrameTime;
@property (nonatomic, strong, readonly) PCResource *resource;
@property (nonatomic, assign) PCTimelineRepeat timelineRepeat;
@property (nonatomic, copy) NSString *fileUUID;
@property (nonatomic, assign) BOOL showUserControls;

@end
