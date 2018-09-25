//
//  PCResourceLibrary.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-06-26.
//
//

#import "PCResourceLibrary.h"
#import "CCBFileUtil.h"
#import "PCResourceManager.h"
#import "AppDelegate.h"
#import "NSString+FileUtilities.h"

@interface PCResourceLibrary()

@property (strong, nonatomic, nonnull) NSCache *imageCache;

@end

@implementation PCResourceLibrary

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageCache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - Public

+ (nonnull PCResourceLibrary *)sharedLibrary {
    static PCResourceLibrary *sharedLibrary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLibrary = [PCResourceLibrary new];
    });
    return sharedLibrary;
}

- (nullable SKTexture *)textureForResource:(nonnull PCResource *)resource {
    NSString *texturePath = [resource absoluteFilePath];
    if (PCIsEmpty(texturePath)) return nil;

    SKTexture *cachedTexture = ([self.imageCache objectForKey:texturePath]);
    if (cachedTexture) return cachedTexture;

    [self deleteIncorrectlyGeneratedImagesIfNecessaryAtPath:texturePath];
    [self createAutoImageIfNecessaryForResource:resource atDestination:texturePath];

    NSImage *image = [[NSImage alloc] initWithContentsOfFile:texturePath];
    if (!image) return nil;
    SKTexture *texture = [SKTexture textureWithImage:image];
    [self.imageCache setObject:texture forKey:texturePath];
    return texture;
}

- (void)clearLibrary {
    [self.imageCache removeAllObjects];
}

#pragma mark - private

- (void)createAutoImageIfNecessaryForResource:(nonnull PCResource *)resource atDestination:(nonnull NSString *)destination {
    if (![self shouldCreateAutoImageFromSource:resource.filePath atDestination:destination]) return;

    [self createAutoImageForResource:resource atDestination:destination];
}

- (void)deleteIncorrectlyGeneratedImagesIfNecessaryAtPath:(NSString *)texturePath {
    NSString *incorrectlyGeneratedImagePath = [texturePath pc_doubleRetinaPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:incorrectlyGeneratedImagePath]) return;

    //If an image with an @2x@2x suffix exists, they got hit by the bug. Delete all of these images so they are regenerated in the next step.
    [[NSFileManager defaultManager] removeItemAtPath:incorrectlyGeneratedImagePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[texturePath pc_retinaFilePath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[texturePath pc_sdFilePath] error:nil];
}

- (BOOL)shouldCreateAutoImageFromSource:(nonnull NSString *)sourceImage atDestination:(nonnull NSString *)destination {
    if (![[NSFileManager defaultManager] fileExistsAtPath:destination]) return YES;

    NSDate *autoFileDate = [CCBFileUtil modificationDateForFile:sourceImage];
    NSDate *cachedFileDate = [CCBFileUtil modificationDateForFile:destination];
    return (![autoFileDate isEqualToDate:cachedFileDate]);
}

- (void)createAutoImageForResource:(nonnull PCResource *)resource atDestination:(nonnull NSString *)destination {
    PCDeviceResolutionSettings *resolutionSettings = [AppDelegate appDelegate].currentDocument.resolutions[[AppDelegate appDelegate].currentDocument.currentResolution];
    [[PCResourceManager sharedManager] createCachedImageFromAuto:resource.filePath saveAs:destination resolution:resolutionSettings.exts.firstObject studioUse:YES];
}

@end
