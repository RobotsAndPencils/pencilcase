//
//  PCVideoPlayer.m
//  PCPlayer
//
//  Created by Orest Nazarewycz on 2/24/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCVideoPlayer.h"
#import "SKNode+JavaScript.h"
#import "SKNode+LifeCycle.h"
#import "CCFileUtils.h"
#import "PCResourceManager.h"
#import "PCSKVideoPlayer.h"
#import "PCUIVideoPlayer.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+CocosCompatibility.h"

NSString * const PCVideoPlayerPosterSuffix = @"-PencilCasePosterFrame";

@interface PCVideoPlayer () <PCVideoPlayerDelegate>

@property (strong, nonatomic) NSMutableArray *jsVideoControlChangedHandlers;
@property (strong, nonatomic) SKSpriteNode<PCVideoPlayerNode> *currentVideoPlayerNode;

@property (assign, nonatomic) CGFloat playbackTime;
@property (assign, nonatomic) CGFloat playbackRate;

@end


@implementation PCVideoPlayer

@synthesize playbackRate = _playbackRate;

- (instancetype)init {
    self = [super init];
    if (self) {
        _showUserControls = YES;
        _playbackRate = 1;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)pc_didMoveToParent {
    [super pc_didMoveToParent];
    if (self.parent) {
        [self setupUI];
    }
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
}

- (void)setAutoplay:(BOOL)autoplay {
    _autoplay = autoplay;
    self.currentVideoPlayerNode.autoplay = autoplay;
}

#pragma mark - Public

- (void)addVideoControlChangedHandlerForState:(NSNumber *)state handler:(JSValue *)handler {
    if (!self.jsVideoControlChangedHandlers) {
        self.jsVideoControlChangedHandlers = [NSMutableArray array];
    }
    JSManagedValue *managedHandler = [JSManagedValue managedValueWithValue:handler andOwner:self];
    [self.jsVideoControlChangedHandlers addObject:@{ @"state": state, @"handler": managedHandler }];
}

#pragma mark - Public to JS

- (void)play {
    [self.currentVideoPlayerNode play];
}

- (void)pause {
    [self.currentVideoPlayerNode pause];
}

- (void)setPlaybackTime:(CGFloat)playbackTime {
    self.currentVideoPlayerNode.playbackTime = playbackTime;
}

- (CGFloat)playbackTime {
    return self.currentVideoPlayerNode.playbackTime;
}

- (void)setPlaybackRate:(CGFloat)playbackRate {
    _playbackRate = playbackRate;
    self.currentVideoPlayerNode.playbackRate = playbackRate;
}

- (CGFloat)playbackRate {
    if (self.currentVideoPlayerNode) return self.currentVideoPlayerNode.playbackRate;
    return _playbackRate;
}

- (CGFloat)duration {
    return self.currentVideoPlayerNode.duration;
}

#pragma mark - Private

- (void)setupUI {
    self.currentVideoPlayerNode = [self createVideoPlayingNode];
    [self addChild:self.currentVideoPlayerNode];

    [self layout];
}

- (SKSpriteNode<PCVideoPlayerNode> *)createVideoPlayingNode {
    SKSpriteNode<PCVideoPlayerNode> *node = self.showUserControls ? [[PCUIVideoPlayer alloc] init] : [[PCSKVideoPlayer alloc] init];
    node.videoPlayingDelegate = self;
    node.videoFilePath = [self absoluteFilePath];
    node.videoPosterPath = [self absolutePosterPath];
    node.timelineTrimTimes = self.timelineTrimTimes;
    node.timelineRepeat = self.timelineRepeat;
    node.autoplay = self.autoplay;
    node.playbackRate = self.playbackRate;
    node.userInteractionEnabled = self.userInteractionEnabled;
    return node;
}

- (void)layout {
    self.currentVideoPlayerNode.size = self.contentSize;
    [self.currentVideoPlayerNode pc_centerInParent];
}

- (void)dispatchVideoControlsChangedHandlersWithType:(EventInspectorVideoControlChangedState)videoState {
    for (JSManagedValue *managedHandler in [self handlersForState:videoState]) {
        [managedHandler.value callWithArguments:@[self]];
    }
}

- (NSArray *)handlersForState:(EventInspectorVideoControlChangedState)desiredState {
    NSArray *handlers = [NSArray array];
    for (NSDictionary *handlerDictionary in self.jsVideoControlChangedHandlers) {
        EventInspectorVideoControlChangedState state = (EventInspectorVideoControlChangedState)[handlerDictionary[@"state"] integerValue];
        if (state == desiredState) {
            handlers = [handlers arrayByAddingObject:handlerDictionary[@"handler"]];
        }
    }
    return handlers;
}

#pragma mark - Properties

- (void)setFileUUID:(NSString *)fileUUID {
    if (![fileUUID isEqualToString:_fileUUID]) {
        _fileUUID = fileUUID;
        self.currentVideoPlayerNode.videoFilePath = [self absoluteFilePath];
        self.currentVideoPlayerNode.videoPosterPath = [self absolutePosterPath];
    }
}

- (void)setTimelineRepeat:(PCTimelineRepeat)timelineRepeat {
    _timelineRepeat = timelineRepeat;
    self.currentVideoPlayerNode.timelineRepeat = timelineRepeat;
}

- (void)setTimelineTrimTimes:(NSArray *)timelineTrimTimes {
    if (!timelineTrimTimes || [timelineTrimTimes count] != 2) return;
    _timelineTrimTimes = timelineTrimTimes;
    self.currentVideoPlayerNode.timelineTrimTimes = timelineTrimTimes;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.currentVideoPlayerNode.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - Paths

- (NSString *)filePath {
    return [PCResourceManager sharedInstance].resources[self.fileUUID];
}

- (NSString *)posterPath {
    NSString *suffix = [NSString stringWithFormat:@"-%@%@", self.uuid, PCVideoPlayerPosterSuffix];
    NSString *posterPath = [[[[self filePath] stringByDeletingPathExtension] stringByAppendingString:suffix] stringByAppendingPathExtension:@"png"];
    return posterPath;
}

- (NSString *)absolutePosterPath {
    NSString *absolutePosterPath = [[CCFileUtils sharedFileUtils] fullPathForFilename:[self posterPath]];
    return absolutePosterPath;
}

- (NSString *)absoluteFilePath {
    return [[CCFileUtils sharedFileUtils] fullPathForFilename:[self filePath]];
}

#pragma mark - PCVideoPlayingDelegate

- (void)videoControlStateChanged:(EventInspectorVideoControlChangedState)newState {
    [self dispatchVideoControlsChangedHandlersWithType:newState];
}

@end
