//
//  PCResourceDirectory.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-08-18.
//
//

#import "PCProjectSettings.h"
#import "AppDelegate.h"
#import "ResourceManagerOutlineHandler.h"
#import "ResourceManagerUtil.h"
#import "PCResourceDirectory.h"

@implementation PCResourceDirectory

- (id) init
{
    self = [super init];
    if (!self) return nil;

    _resources = [[NSMutableArray alloc] init];
    _any = [[NSMutableArray alloc] init];

    return self;
}

#pragma mark - Properties

- (NSString *)directoryPath {
    return [self.directoryReferenceURL path];
}

- (void)setDirectoryReferenceURL:(NSURL *)directoryReferenceURL {
    if ([directoryReferenceURL isEqual:_directoryReferenceURL]) {
        return;
    }

    _directoryReferenceURL = directoryReferenceURL;
}

#pragma mark - Class methods

+ (BOOL)isStoredResourceType:(PCResourceType)type {
    switch (type) {
        case PCResourceTypeImage:
        case PCResourceTypeBMFont:
        case PCResourceTypeTTF:
        case PCResourceTypeCCBFile:
        case PCResourceTypeDirectory:
        case PCResourceTypeJS:
        case PCResourceTypeJSON:
        case PCResourceTypeAudio:
        case PCResourceTypeVideo:
        case PCResourceType3DModel:
            return YES;
        default:
            return NO;
    }
}

#pragma mark - NSCoding

static NSString *const PCResourceDirectoryResourcesKey = @"PCResourceDirectoryResourcesKey";
static NSString *const PCResourceDirectoryAnyKey = @"PCResourceDirectoryAnyKey";
static NSString *const PCResourceDirectoryCountKey = @"count"; //backwards compatible
static NSString *const PCResourceDirectoryDirectoryPathKey = @"dirPath"; //backwards compatible

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSString *directoryPath = [ResourceManagerUtil projectPathFromRelativePath:[coder decodeObjectForKey:PCResourceDirectoryDirectoryPathKey]];
        if (!directoryPath) {
            _loadedWithNilPath = YES;
            return self;
        }
        
        _directoryReferenceURL = [[NSURL fileURLWithPath:directoryPath isDirectory:YES] fileReferenceURL];
        // We only care about the values (resources) of the dictionary. The relative path keys are just legacy stuff.
        _resources = [[[ResourceManagerUtil convertDictionaryKeysFromRelativePathToProjectPath:[coder decodeObjectForKey:PCResourceDirectoryResourcesKey]] allValues] mutableCopy];
        _any = [coder decodeObjectForKey:PCResourceDirectoryAnyKey];
        for (PCResource *resource in [_any copy]) {
            if (resource.loadedWithNilPath) {
                [_any removeObject:resource];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:[ResourceManagerUtil relativePathFromPathInProject:self.directoryPath] forKey:PCResourceDirectoryDirectoryPathKey];

    // Reconstruct the legacy dictionary format of { absoluteResourcePath: resource } that will then be converted to have relative keys as before
    NSDictionary *legacyDictionaryResourcesRepresentation = Underscore.reduce(self.resources, [NSMutableDictionary dictionary], ^NSMutableDictionary *(NSMutableDictionary *memo, PCResource *resource){
        // Don't try to serialize resources that don't exist anymore. This shouldn't normally occur, but let's avoid the exception that would occur below.
        if (PCIsEmpty(resource.absoluteFilePath)) {
            return memo;
        }
        memo[resource.absoluteFilePath] = resource;
        return memo;
    });
    [coder encodeObject:[ResourceManagerUtil convertDictionaryKeysFromProjectPathToRelativePath:legacyDictionaryResourcesRepresentation] forKey:PCResourceDirectoryResourcesKey];

    [coder encodeObject:self.any forKey:PCResourceDirectoryAnyKey];
}


#pragma mark - Implementation

- (NSComparisonResult)compare:(PCResourceDirectory *)dir {
    return [self.directoryPath compare:dir.directoryPath];
}

- (void)addResource:(PCResource *)resource {
    if ([PCResourceDirectory isStoredResourceType:resource.type]) {
        [self.any addObject:resource];
    }

    if (resource.filePath) {
        [self.resources addObject:resource];
    } else {
        NSLog(@"Tried to add resource with invalid file path");
    }
}

- (void)removeResource:(PCResource *)resource {
    [self.any removeObject:resource];
    [self.resources removeObject:resource];
}

@end
