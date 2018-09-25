//
//  PCSKVideoPlayer.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-03.
//
//

// Header
#import "PCSKVideoPlayer.h"

// System frameworks
#import <AVFoundation/AVFoundation.h>

// Project
#import "AVAsset+Metadata.h"
#import "SKNode+NodeInfo.h"
#import "PCOverlayView.h"
#import "PositionPropertySetter.h"
#import "PCResourceManager.h"
#import "InspectorTimelineTrim.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+LifeCycle.h"
#import "ResourceManagerUtil.h"
#import "AppDelegate.h"
#import "NodeInfo.h"

// Categories
#import "SKNode+CoordinateConversion.h"

CMTimeValue const PCPosterFrameTime = 0.0;
CGFloat const PCPosterFrameTimeNone = -1.0;


@interface PCSKVideoPlayer ()

@property (nonatomic, strong) SKSpriteNode *posterSprite;
@property (nonatomic, strong) SKSpriteNode *playButton;
@property (nonatomic, strong, readwrite) PCResource *resource;
@property (nonatomic, assign) BOOL autoplay;
@property (nonatomic, assign) CGFloat playbackRate;
@property (nonatomic, assign) CGFloat playbackTime;
@property (nonatomic, assign) BOOL resourceSizeNeedsUpdate;

@end


@implementation PCSKVideoPlayer

#pragma mark CCNode

- (id)init {
    self = [super initWithColor:[NSColor blackColor] size:CGSizeZero];
    if (self) {
        // Default timelineTrimTime value is set in CCBProperties
        
        // Just keeping track of when this get's initially set so we can decide whether to get a new poster frame or not
        // i.e. we don't want to get a new poster frame if one exists and we're setting this property because we opened a file
        _posterFrameTime = PCPosterFrameTimeNone;

        _resourceSizeNeedsUpdate = NO;
        
        self.playButton = [SKSpriteNode spriteNodeWithImageNamed:@"PCPlayerPlay.png"];
        self.playButton.userObject = [[NodeInfo alloc] init];
        [self addChild:self.playButton];
        [self.playButton setScale:0.5];
        
        [self addObserver:self forKeyPath:@"resource.naturalSize" options:NSKeyValueObservingOptionInitial context:NULL];
        // Don't want the initial value for this keypath because resource will always start as nil
        [self addObserver:self forKeyPath:@"resource.duration" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)pc_firstTimeSetup {
    [super pc_firstTimeSetup];

    if (CGSizeEqualToSize(self.resource.naturalSize, CGSizeZero)) {
        self.resourceSizeNeedsUpdate = YES;
    }
    else {
        [self updateSizeFromResource];
        [self updateDurationFromResource];
    }
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"resource.duration"];
    [self removeObserver:self forKeyPath:@"resource.naturalSize"];
}

- (void)removeFromParent {
    [self removePosterFrameResource];
    [super removeFromParent];
}

- (BOOL)canParticipateInPhysics {
    return NO;
}

- (void)layoutPlayButton {
    CGFloat maxPlayXScale = MIN(1, self.contentSize.width / 2 / self.playButton.contentSize.width);
    CGFloat maxPlayYScale = MIN(1, self.contentSize.height / 2 / self.playButton.contentSize.height);
    CGFloat scale = MIN(maxPlayXScale, maxPlayYScale);
    if (scale != 0 && !isnan(scale)) {
        self.playButton.scale = MIN(maxPlayXScale, maxPlayYScale);
    }
    [self.playButton pc_centerInParent];
}

- (void)layoutPoster {
    if (self.posterSprite) {
        self.posterSprite.contentSize = self.posterSprite.texture.size;
        self.posterSprite.xScale = self.contentSize.width / self.posterSprite.contentSize.width;
        self.posterSprite.yScale = self.contentSize.height / self.posterSprite.contentSize.height;
        [self.posterSprite pc_centerInParent];
    }
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self layout];
}

- (void)layout {
    [self layoutPlayButton];
    [self layoutPoster];
}

- (void)updateSizeFromResource {
    if (!self.resource) return;

    NSSize newSize = NSMakeSize(self.resource.naturalSize.width / 2, self.resource.naturalSize.height / 2);
    if (!CGSizeEqualToSize(self.contentSize, newSize)) {
        self.contentSize = newSize;
        [self layout];
    }
}

- (void)updateDurationFromResource {
    if (!self.resource) return;
    
    self.timelineTrimTimes = @[ [self.timelineTrimTimes firstObject], @(self.resource.duration) ];
    [[AppDelegate appDelegate] refreshProperty:@"timelineTrimTimes"];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"resource.naturalSize"] && self.resourceSizeNeedsUpdate) {
        [self updateSizeFromResource];
        self.resourceSizeNeedsUpdate = NO;
    }
    // The UI doesn't let the endpoint become 0, so we can treat this as an initial value
    // If it's 0 we know we can set it to the duration instead
    else if ([keyPath isEqualToString:@"resource.duration"] && [[self.timelineTrimTimes lastObject] doubleValue] == TimelineTrimInitialEndpoint && [change[NSKeyValueChangeNewKey] doubleValue] != 0) {
        if (!change[NSKeyValueChangeNewKey]) return;
        [self updateDurationFromResource];
    }
}

#pragma mark Poster Frame

- (void)fetchPosterImage {
    if (!self.resource) return;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self absoluteFilePath]]) return;
    NSURL *url = [NSURL fileURLWithPath:[self absoluteFilePath]];
    AVAsset *asset = [AVAsset assetWithURL:url];
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] == 0) return;
    [asset fetchPosterFrameWithDuration:self.resource.duration timeOffset:self.posterFrameTime completion:^(CGImageRef poster) {
        if (!poster) return;
        
        NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:poster];
        NSData *imageData = [imageRep representationUsingType:NSPNGFileType properties:@{}];
        // We're in charge of releasing it from when it was created in the function call
        // It's also retained when the imageRep is created, but it will be released when the imageRep is autoreleased
        CGImageRelease(poster);

        [self removePosterFrameResource];

        NSString *posterPath = [self absolutePosterPath];
        NSError *error;
        if (![imageData writeToFile:posterPath options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error saving new poster frame: %@", error);
        } else {
            [[PCResourceManager sharedManager] addResourceWithAbsoluteFilePath:posterPath];
            [self updatePosterSprite];
        }
    }];
}

- (void)removePosterFrameResource {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *posterPath = [self absolutePosterPath];

    PCResource *resource = [[PCResourceManager sharedManager] resourceForPath:posterPath];
    if (resource) {
        [[PCResourceManager sharedManager] removeResource:resource];
    }

    // The poster frame might not have been associated with a resource.
    if ([fileManager fileExistsAtPath:posterPath]) {
        NSError *deleteError;
        if (![fileManager removeItemAtPath:posterPath error:&deleteError]) {
            NSLog(@"Error deleting existing poster frame: %@", deleteError);
        }
    }
}

- (void)updatePosterSprite {
    self.color = [NSColor blackColor];
    [self.posterSprite removeFromParent];
    self.posterSprite = nil;
    SKTexture *texture = [SKTexture textureWithImage:[[NSImage alloc] initWithContentsOfFile:[self absolutePosterPath]]];

    SKSpriteNode *posterSprite = [SKSpriteNode spriteNodeWithTexture:texture];
    posterSprite.userObject = [[NodeInfo alloc] init];
    [self addChild:posterSprite];
    self.posterSprite = posterSprite;

    [self.playButton removeFromParent];
    [self addChild:self.playButton];

    [self layout];
}

#pragma mark - Properties

- (void)setFileUUID:(NSString *)fileUUID {
    if ([fileUUID isEqualToString:_fileUUID]) return;

    if (_fileUUID) { // Changed to new resource
        self.resourceSizeNeedsUpdate = YES;
    }

    _fileUUID = fileUUID;

    [self setExtraProp:fileUUID forKey:@"fileUUID"];
    self.resource = [[PCResourceManager sharedManager] resourceWithUUID:fileUUID];
    if (!self.resource) {
        return;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:[self absolutePosterPath]]) {
        [self updatePosterSprite];
    } else {
        self.posterFrameTime = 0.0;
        [self fetchPosterImage];
    }
}

- (void)setPosterFrameTime:(CGFloat)posterFrameTime {
    BOOL posterFrameTimeIsNone = _posterFrameTime == PCPosterFrameTimeNone;
    _posterFrameTime = posterFrameTime;
    [self setExtraProp:@(posterFrameTime) forKey:@"posterFrameTime"];
    
    // Make sure there's a backing resource
    // We don't need to get a new image if we're loading this node from a file and we already have a poster image
    BOOL posterFrameImageExists = [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePosterPath]];
    if (self.resource && !(posterFrameTimeIsNone && posterFrameImageExists)) {
        [self fetchPosterImage];
    }
}

- (void)setTimelineTrimTimes:(NSArray *)timelineTrimTimes {
    _timelineTrimTimes = timelineTrimTimes;
    [self setExtraProp:timelineTrimTimes forKey:@"timelineTrimTimes"];
}

#pragma mark - Paths

- (NSString *)absolutePosterPath {
    NSString *suffix = [NSString stringWithFormat:@"-%@%@", self.uuid, PCVideoPlayerPosterSuffix];
    return [[[self.resource.filePath stringByDeletingPathExtension] stringByAppendingString:suffix] stringByAppendingPathExtension:@"png"];}

- (NSString *)absoluteFilePath {
    if (!self.resource) return nil;
    return [[PCResourceManager sharedManager] toAbsolutePath:self.resource.relativePath];
}

@end
