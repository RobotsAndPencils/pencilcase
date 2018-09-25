/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "PCProjectSettings.h"
#import "NSString+RelativePath.h"
#import "HashValue.h"
#import "PlugInManager.h"
#import "PlugInExport.h"
#import "PCResourceManager.h"
#import "AppDelegate.h"
#import "ResourceManagerOutlineHandler.h"
#import "NSImage+PNGRepresentation.h"
#import "PCIBeacon.h"
#import "PCTableCellInfo.h"
#import "NSError+PencilCaseErrors.h"
#import "PCBehavioursDataSource.h"

static void *CCBDocumentUndoContext = &CCBDocumentUndoContext;

@interface PCProjectSettings ()

@property (nonatomic, assign, getter=isWatchingDirtyingProperties) BOOL watchingDirtyingProperties;

@end

@implementation PCProjectSettings

@synthesize resourcePaths;
@synthesize publishDirectory;
@synthesize publishEnablediPhone;
@synthesize publishEnabledAndroid;
@synthesize publishEnabledHTML5;
@synthesize publishResolution_ios_phone;
@synthesize publishResolution_ios_phonehd;
@synthesize publishResolution_ios_tablet;
@synthesize publishResolution_ios_tablethd;
@synthesize publishResolution_android_phone;
@synthesize publishResolution_android_phonehd;
@synthesize publishResolution_android_tablet;
@synthesize publishResolution_android_tablethd;
@synthesize publishResolutionHTML5_width;
@synthesize publishResolutionHTML5_height;
@synthesize publishResolutionHTML5_scale;
@synthesize publishAudioQuality_ios;
@synthesize publishAudioQuality_android;
@synthesize isSafariExist;
@synthesize isChromeExist;
@synthesize isFirefoxExist;
@synthesize flattenPaths;
@synthesize publishToZipFile;
@synthesize javascriptBased;
@synthesize javascriptMainCCB;
@synthesize exporter;
@synthesize availableExporters;
@synthesize deviceOrientationPortrait;
@synthesize deviceOrientationUpsideDown;
@synthesize deviceOrientationLandscapeLeft;
@synthesize deviceOrientationLandscapeRight;
@synthesize resourceAutoScaleFactor;
@synthesize lastWarnings;

@dynamic absoluteResourcePaths;
@dynamic projectFilePathHashed;
@dynamic displayCacheDirectory;
@dynamic projectDirectory;

- (id)init
{
    self = [super init];
    if (!self) return NULL;
    
    resourcePaths = [[NSMutableArray alloc] init];
    self.slideList = [[NSMutableArray alloc] init];
    self.iBeaconList = [NSArray array];
    
    [resourcePaths addObject:[NSMutableDictionary dictionaryWithObject:@"Resources" forKey:@"path"]];
    self.flattenPaths = NO;
    self.javascriptBased = YES;
    self.publishToZipFile = NO;
    self.javascriptMainCCB = @"MainScene";
    self.deviceOrientationLandscapeLeft = YES;
    self.deviceOrientationLandscapeRight = YES;
    self.resourceAutoScaleFactor = 4;
    
    self.publishEnablediPhone = YES;
    self.publishEnabledAndroid = YES;
    self.publishEnabledHTML5 = NO;
    
    self.publishResolution_ios_phone = YES;
    self.publishResolution_ios_phonehd = YES;
    self.publishResolution_ios_tablet = YES;
    self.publishResolution_ios_tablethd = YES;
    self.publishResolution_android_phone = YES;
    self.publishResolution_android_phonehd = YES;
    self.publishResolution_android_tablet = YES;
    self.publishResolution_android_tablethd = YES;
    
    self.publishResolutionHTML5_width = 480;
    self.publishResolutionHTML5_height = 320;
    self.publishResolutionHTML5_scale = 1;
    
    self.publishAudioQuality_ios = 4;
    self.publishAudioQuality_android = 4;
    
    self.tabletPositionScaleFactor = 2.0f;

    self.nodeClassCounts = [NSMutableDictionary dictionary];

    // View menu item settings
    self.showGuides = YES;
    self.snapToGuides = YES;
    self.snapToObjects = YES;

    // App settings
    self.appName = @"";
    self.previousAuthorVersion = 0;
    self.createdAuthorVersion = 0;
    self.authorVersion = 0;

    // Debug settings
    self.enableDefaultREPLGesture = YES;
    self.showFPS = NO;
    self.showNodeCount = NO;
    self.showQuadCount = NO;
    self.showDrawCount = NO;
    self.showPhysicsBorders = NO;
    self.showPhysicsFields = NO;

    resourceProperties = [NSMutableDictionary dictionary];
    
    // Load available exporters
    self.availableExporters = [NSMutableArray array];
    for (PlugInExport* plugIn in [[PlugInManager sharedManager] plugInsExporters])
    {
        [availableExporters addObject: plugIn.extension];
    }

    _nodeManagerUUID = [NSUUID UUID];
    
    [self detectBrowserPresence];
    self.stageBorderType = PCStageBorderTypeDefault;

    self.keyConfigStore = [[PCKeyValueStoreKeyConfigStore alloc] init];
    
    return self;
}


/**
 *  This method takes in a validated project dictionary and returns the ProjectSettings
 *
 *  @param dict              the project dictionary, assuming that it has already been validated
 *  @param projectPackageURL URL of the project package
 *
 *  @return returns the initialized PCProjectSettings object
 */
- (id)initWithValidSerialization:(id)dict fromPackageURL:(NSURL *)projectPackageURL {
    self = [self init];
    if (!self) return nil;
    
    [self initalizeProjectFileVersionInfoWithProjectSerialization:dict];
    
    // Read settings
    self.projectFileReferenceURL = [NSURL URLByResolvingBookmarkData:dict[NSStringFromSelector(@selector(projectFileReferenceURL))] options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:projectPackageURL bookmarkDataIsStale:NULL error:NULL];
    self.resourcePaths = [dict objectForKey:@"resourcePaths"];
    // This is currently disabled because the resource manager, which requires the project settings to exist in order to
    // work properly, is required to deserialize slides (because of this: slides > behaviours > tokens > resources).
    // For now the slide list is instead being initialized in the app delegate after the resource manager is set up.
    // See the comments there for more info.
    // self.slideList = [self deserializeSlideListInDictionary:dict key:@"slideList"];
    self.iBeaconList = [self deserializeIBeaconUUIDListInDictionary:dict key:@"ibeaconList"];
    self.subcontentDocuments = [self deserializeDocumentsInDictionary:dict key:@"subcontentDocuments"];
    
    self.publishEnablediPhone = [[dict objectForKey:@"publishEnablediPhone"] boolValue];
    self.publishEnabledAndroid = [[dict objectForKey:@"publishEnabledAndroid"] boolValue];
    self.publishEnabledHTML5 = [[dict objectForKey:@"publishEnabledHTML5"] boolValue];
    
    self.publishResolution_ios_phone = [[dict objectForKey:@"publishResolution_ios_phone"] boolValue];
    self.publishResolution_ios_phonehd = [[dict objectForKey:@"publishResolution_ios_phonehd"] boolValue];
    self.publishResolution_ios_tablet = [[dict objectForKey:@"publishResolution_ios_tablet"] boolValue];
    self.publishResolution_ios_tablethd = [[dict objectForKey:@"publishResolution_ios_tablethd"] boolValue];
    self.publishResolution_android_phone = [[dict objectForKey:@"publishResolution_android_phone"] boolValue];
    self.publishResolution_android_phonehd = [[dict objectForKey:@"publishResolution_android_phonehd"] boolValue];
    self.publishResolution_android_tablet = [[dict objectForKey:@"publishResolution_android_tablet"] boolValue];
    self.publishResolution_android_tablethd = [[dict objectForKey:@"publishResolution_android_tablethd"] boolValue];
    
    self.publishResolutionHTML5_width = [[dict objectForKey:@"publishResolutionHTML5_width"]intValue];
    self.publishResolutionHTML5_height = [[dict objectForKey:@"publishResolutionHTML5_height"]intValue];
    self.publishResolutionHTML5_scale = [[dict objectForKey:@"publishResolutionHTML5_scale"]intValue];
    if (!publishResolutionHTML5_width) publishResolutionHTML5_width = 960;
    if (!publishResolutionHTML5_height) publishResolutionHTML5_height = 640;
    if (!publishResolutionHTML5_scale) publishResolutionHTML5_scale = 2;
    
    self.publishAudioQuality_ios = [[dict objectForKey:@"publishAudioQuality_ios"]intValue];
    if (!self.publishAudioQuality_ios) self.publishAudioQuality_ios = 1;
    self.publishAudioQuality_android = [[dict objectForKey:@"publishAudioQuality_android"]intValue];
    if (!self.publishAudioQuality_android) self.publishAudioQuality_android = 1;
    
    self.flattenPaths = [[dict objectForKey:@"flattenPaths"] boolValue];
    self.publishToZipFile = [[dict objectForKey:@"publishToZipFile"] boolValue];
    self.javascriptBased = [[dict objectForKey:@"javascriptBased"] boolValue];
    self.exporter = [dict objectForKey:@"exporter"];
    self.deviceOrientationPortrait = [[dict objectForKey:@"deviceOrientationPortrait"] boolValue];
    self.deviceOrientationUpsideDown = [[dict objectForKey:@"deviceOrientationUpsideDown"] boolValue];
    self.deviceOrientationLandscapeLeft = [[dict objectForKey:@"deviceOrientationLandscapeLeft"] boolValue];
    self.deviceOrientationLandscapeRight = [[dict objectForKey:@"deviceOrientationLandscapeRight"] boolValue];
    
    self.deviceResolutionSettings = [[PCDeviceResolutionSettings alloc] init];
    self.deviceResolutionSettings.deviceScaling = [[dict objectForKey:@"deviceScaling"] intValue];
    
    if ([dict objectForKey:@"defaultOrientation"]) {
        self.deviceResolutionSettings.deviceOrientation = [[dict objectForKey:@"defaultOrientation"] intValue];
    } else {
        self.deviceResolutionSettings.deviceOrientation = PCDeviceTargetOrientationLandscape;
    }
    
    if ([dict objectForKey:@"deviceTarget"]) {
        self.deviceResolutionSettings.deviceTarget = [[dict objectForKey:@"deviceTarget"] intValue];
    } else {
        self.deviceResolutionSettings.deviceTarget = PCDeviceTargetTypeTablet;
    }
    
    if ([dict objectForKey:@"designTarget"]) {
        self.deviceResolutionSettings.designTarget = [[dict objectForKey:@"designTarget"] intValue];
    } else {
        self.deviceResolutionSettings.designTarget = PCDesignTargetFlexible;
    }

    self.resourceAutoScaleFactor = [self resourceAutoScaleFactorForTargetDevice:self.deviceResolutionSettings.deviceTarget];
    self.tabletPositionScaleFactor = 2.0f;

    self.nodeClassCounts = dict[@"nodeClassCounts"];
    if (!self.nodeClassCounts) {
        self.nodeClassCounts = [NSMutableDictionary dictionary];
    }

    // View menu item settings
    self.showGuides = [dict[@"showGuides"] boolValue];
    self.snapToGuides = [dict[@"snapToGuides"] boolValue];
    self.snapToObjects = [dict[@"snapToObjects"] boolValue];
    self.stageBorderType = PCIsEmpty(dict[@"stageBorderType"]) ? PCStageBorderTypeDefault : [dict[@"stageBorderType"] intValue];

    // Debugging settings
    self.showFPS = [dict[@"showFPS"] boolValue];
    self.showNodeCount = [dict[@"showNodeCount"] boolValue];
    self.showQuadCount = [dict[@"showQuadCount"] boolValue];
    self.showDrawCount = [dict[@"showDrawCount"] boolValue];
    self.showPhysicsBorders = [dict[@"showPhysicsBorders"] boolValue];
    self.showPhysicsFields = [dict[@"showPhysicsFields"] boolValue];

    if (dict[@"enableDefaultREPLGesture"]) {
        self.enableDefaultREPLGesture = [dict[@"enableDefaultREPLGesture"] boolValue];
    }
    else {
        self.enableDefaultREPLGesture = YES;
    }

    // App settings
    self.appName = dict[@"appName"] ?: @"";
    NSInteger pencilCaseVersion = [[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue];
    [self loadFileVersionsFromFile:dict currentFileVersion:pencilCaseVersion];

    NSData *appIconImage = dict[@"appIconImage"];
    if (appIconImage) {
        self.appIconImage = [[NSImage alloc] initWithData:appIconImage];
    }
    NSData *appIconRetinaImage = dict[@"appIconRetinaImage"];
    if (appIconRetinaImage) {
        self.appIconRetinaImage = [[NSImage alloc] initWithData:appIconRetinaImage];
    }

    NSString* mainCCB = [dict objectForKey:@"javascriptMainCCB"];
    if (!mainCCB) mainCCB = @"";
    self.javascriptMainCCB = mainCCB;
    
    // Load resource properties
    resourceProperties = [[dict objectForKey:@"resourceProperties"] mutableCopy];
    
    [self detectBrowserPresence];

    self.uuid = dict[@"uuid"];
    if ([self.uuid length] == 0) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }

    self.publishDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:self.uuid];
    
    self.nodeManagerUUID = [NSKeyedUnarchiver unarchiveObjectWithData:dict[@"nodeManagerUUID"]];
    if (!self.nodeManagerUUID) {
        self.nodeManagerUUID = [NSUUID UUID];
    }

    self.xcodeProjectExportPath = dict[@"xcodeProjectExportPath"];

    // The project has been duplicated on the file system if the loaded file reference
    // doesn't match the location of the project
    if (![[self.projectFileReferenceURL URLByDeletingLastPathComponent].path isEqualToString:projectPackageURL.path]) {
        self.uuid = [[NSUUID UUID] UUIDString];
    }

    self.keyConfigStore = [NSKeyedUnarchiver unarchiveObjectWithData:dict[@"keyConfigStore"]];
    if (!self.keyConfigStore) {
        self.keyConfigStore = [[PCKeyValueStoreKeyConfigStore alloc] init];
    }

    return self;
}

- (void)loadFileVersionsFromFile:(NSDictionary *)fileContents currentFileVersion:(NSInteger)pencilCaseVersion {
    if (self.authorVersion < pencilCaseVersion) {
        self.previousAuthorVersion = self.authorVersion;
        self.authorVersion = pencilCaseVersion;
    } else {
        self.previousAuthorVersion = [fileContents[@"previousAuthorVersion"] integerValue] ?: pencilCaseVersion;
    }
    self.createdAuthorVersion = [fileContents[@"createdAuthorVersion"] integerValue] ?: self.previousAuthorVersion;
}

- (NSInteger)resourceAutoScaleFactorForTargetDevice:(PCDeviceTargetType)device {
    switch (device) {
        case PCDeviceTargetTypePhone:
            return 3;

        case PCDeviceTargetTypeTablet:
        default:
            return 2;
    }
}

- (void)newProjectSetupWithDeviceTarget:(PCDeviceTargetType)target withOrientation:(PCDeviceTargetOrientation)orientation {
    self.appName = [[self.projectFilePath lastPathComponent] stringByDeletingPathExtension];

    // Be defensive here so we don't have to be paranoid about letting these slip into the template.
    self.nodeClassCounts = [NSMutableDictionary dictionary];
    self.uuid = [[NSUUID UUID] UUIDString];
    self.publishDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:self.uuid];
    self.deviceResolutionSettings.deviceTarget = target;
    self.deviceResolutionSettings.deviceOrientation = orientation;
    self.resourceAutoScaleFactor = [self resourceAutoScaleFactorForTargetDevice:target];
    self.stageBorderType = PCStageBorderTypeDefault;
    
    NSInteger pencilCaseVersion = [[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] integerValue];
    self.createdAuthorVersion = pencilCaseVersion;
    self.previousAuthorVersion = pencilCaseVersion;
    self.authorVersion = pencilCaseVersion;

    [self store];
}

- (void)dealloc {
    if (!self.isWatchingDirtyingProperties) return;

    for (NSString *keyPath in [self dirtyingProperties]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSString*) exporter
{
    if (exporter) return exporter;
    return kCCBDefaultExportPlugIn;
}

- (id) serialize
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

    NSError *projectFileBookmarkDataCreationError;
    NSURL *projectPackageURL = [self.projectFileReferenceURL URLByDeletingLastPathComponent];
    NSData *projectFileBookmarkData = [self.projectFileReferenceURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:projectPackageURL error:&projectFileBookmarkDataCreationError];
    if (!projectFileBookmarkData) {
        NSLog(@"Error creating project file bookmark data: %@", projectFileBookmarkDataCreationError);
    }
    else {
        dict[NSStringFromSelector(@selector(projectFileReferenceURL))] = projectFileBookmarkData;
    }
    [dict setObject:PCProjectFileType forKey:@"fileType"];
    [dict setObject:resourcePaths forKey:@"resourcePaths"];
    [self serializeSlides:self.slideList intoDictionary:dict forKey:@"slideList"];
    [self serializeIBeacons:self.iBeaconList intoDictionary:dict forKey:@"ibeaconList"];
    [self serializeDocuments:self.subcontentDocuments intoDictionary:dict forKey:@"subcontentDocuments"];
    [dict setObject:[PCTableCellInfo cellTypeDictionaries] forKey:@"tableCellTypes"];
    
    [dict setObject:[NSNumber numberWithBool:publishEnablediPhone] forKey:@"publishEnablediPhone"];
    [dict setObject:[NSNumber numberWithBool:publishEnabledAndroid] forKey:@"publishEnabledAndroid"];
    [dict setObject:[NSNumber numberWithBool:publishEnabledHTML5] forKey:@"publishEnabledHTML5"];
    
    [dict setObject:[NSNumber numberWithBool:publishResolution_ios_phone] forKey:@"publishResolution_ios_phone"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_ios_phonehd] forKey:@"publishResolution_ios_phonehd"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_ios_tablet] forKey:@"publishResolution_ios_tablet"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_ios_tablethd] forKey:@"publishResolution_ios_tablethd"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_android_phone] forKey:@"publishResolution_android_phone"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_android_phonehd] forKey:@"publishResolution_android_phonehd"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_android_tablet] forKey:@"publishResolution_android_tablet"];
    [dict setObject:[NSNumber numberWithBool:publishResolution_android_tablethd] forKey:@"publishResolution_android_tablethd"];
    
    [dict setObject:[NSNumber numberWithInt:publishResolutionHTML5_width] forKey:@"publishResolutionHTML5_width"];
    [dict setObject:[NSNumber numberWithInt:publishResolutionHTML5_height] forKey:@"publishResolutionHTML5_height"];
    [dict setObject:[NSNumber numberWithInt:publishResolutionHTML5_scale] forKey:@"publishResolutionHTML5_scale"];
    
    [dict setObject:[NSNumber numberWithInt:publishAudioQuality_ios] forKey:@"publishAudioQuality_ios"];
    [dict setObject:[NSNumber numberWithInt:publishAudioQuality_android] forKey:@"publishAudioQuality_android"];
    
    [dict setObject:[NSNumber numberWithBool:flattenPaths] forKey:@"flattenPaths"];
    [dict setObject:[NSNumber numberWithBool:publishToZipFile] forKey:@"publishToZipFile"];
    [dict setObject:[NSNumber numberWithBool:javascriptBased] forKey:@"javascriptBased"];
    [dict setObject:self.exporter forKey:@"exporter"];
    
    [dict setObject:[NSNumber numberWithBool:deviceOrientationPortrait] forKey:@"deviceOrientationPortrait"];
    [dict setObject:[NSNumber numberWithBool:deviceOrientationUpsideDown] forKey:@"deviceOrientationUpsideDown"];
    [dict setObject:[NSNumber numberWithBool:deviceOrientationLandscapeLeft] forKey:@"deviceOrientationLandscapeLeft"];
    [dict setObject:[NSNumber numberWithBool:deviceOrientationLandscapeRight] forKey:@"deviceOrientationLandscapeRight"];
    [dict setObject:[NSNumber numberWithInt:resourceAutoScaleFactor] forKey:@"resourceAutoScaleFactor"];

    dict[@"deviceTarget"] = @(self.deviceResolutionSettings.deviceTarget);
    dict[@"designTarget"] = @(self.deviceResolutionSettings.designTarget);
    dict[@"defaultOrientation"] = @(self.deviceResolutionSettings.deviceOrientation);
    dict[@"deviceScaling"] = @(self.deviceResolutionSettings.deviceScaling);

    if (self.nodeClassCounts) {
        dict[@"nodeClassCounts"] = self.nodeClassCounts;
    }

    // View menu item settings
    dict[@"showGuides"] = @(self.showGuides);
    dict[@"snapToGuides"] = @(self.snapToGuides);
    dict[@"snapToObjects"] = @(self.snapToObjects);
    dict[@"stageBorderType"] = @(self.stageBorderType);

    //This value is never read in the maker so can just be serialized with the constant
    dict[@"fileFormatVersion"] = @(PCPublishedFileFormatVersion);
    //This value is read next time this serialization is loaded to know if migration is necessary. But we always save with the most current format.
    dict[@"makerFileFormatVersion"] = @(PCMakerFileFormatVersion);

    if (self.appName) {
        dict[@"appName"] = self.appName;
    }
    if (self.authorVersion) {
        dict[@"authorVersion"] = @(self.authorVersion);
    }
    if (self.previousAuthorVersion) {
        dict[@"previousAuthorVersion"] = @(self.previousAuthorVersion);
    }
    if (self.createdAuthorVersion) {
        dict[@"createdAuthorVersion"] = @(self.createdAuthorVersion);
    }
    if (self.appIconImage) {
        dict[@"appIconImage"] = [self.appIconImage PNGRepresentation];
    }
    if (self.appIconRetinaImage) {
        dict[@"appIconRetinaImage"] = [self.appIconRetinaImage PNGRepresentation];
    }

    // Debugging settings
    dict[@"enableDefaultREPLGesture"] = @(self.enableDefaultREPLGesture);
    dict[@"showFPS"] = @(self.showFPS);
    dict[@"showNodeCount"] = @(self.showNodeCount);
    dict[@"showQuadCount"] = @(self.showQuadCount);
    dict[@"showDrawCount"] = @(self.showDrawCount);
    dict[@"showPhysicsBorders"] = @(self.showPhysicsBorders);
    dict[@"showPhysicsFields"] = @(self.showPhysicsFields);

    if (!javascriptMainCCB) self.javascriptMainCCB = @"";
    if (!javascriptBased) self.javascriptMainCCB = @"";
    [dict setObject:javascriptMainCCB forKey:@"javascriptMainCCB"];
    
    if (resourceProperties)
    {
        [dict setObject:resourceProperties forKey:@"resourceProperties"];
    }
    else
    {
        [dict setObject:[NSDictionary dictionary] forKey:@"resourceProperties"];
    }

    dict[@"uuid"] = self.uuid;
    
    dict[@"nodeManagerUUID"] = [NSKeyedArchiver archivedDataWithRootObject:self.nodeManagerUUID];

    if (self.xcodeProjectExportPath) {
        dict[@"xcodeProjectExportPath"] = self.xcodeProjectExportPath;
    }

    if (self.keyConfigStore) {
        dict[@"keyConfigStore"] = [NSKeyedArchiver archivedDataWithRootObject:self.keyConfigStore];
    }

    return dict;
}

- (void)serializeSlides:(NSArray *)slides intoDictionary:(NSMutableDictionary *)dict forKey:(NSString *)key {
    NSMutableArray *slideListArray = [NSMutableArray array];

    __block NSDictionary *slideInfo;
    for (PCSlide *slide in slides) {
        slideInfo = [slide dictionaryRepresentation];
        [slideListArray addObject:slideInfo];
    }
    [dict setObject:slideListArray forKey:key];
}

- (void)serializeIBeacons:(NSArray *)beacons intoDictionary:(NSMutableDictionary *)dict forKey:(NSString *)key {
    NSMutableArray *beaconListArray = [NSMutableArray array];
    for (PCIBeacon *beacon in beacons) {
        NSDictionary *beaconInfo = [beacon dictionaryRepresentation];
        [beaconListArray addObject:beaconInfo];
    }
    [dict setObject:beaconListArray forKey:key];
}

- (NSMutableArray *)deserializeSlideListInDictionary:(NSDictionary *)dict key:(NSString *)key {
    NSArray *slideDicts = [dict objectForKey:key];
    NSMutableArray *slides = [NSMutableArray array];
    for (NSMutableDictionary *slideDict in slideDicts) {
        PCSlide *slide = [[PCSlide alloc] initWithDictionary:slideDict];
        [slide updateThumbnail];
        [slides addObject:slide];
    }
    return slides;
}

- (NSMutableArray *)deserializeIBeaconUUIDListInDictionary: (NSDictionary *)dict key:(NSString *)key {
    NSArray *beaconDictList = [dict objectForKey:key];
    NSMutableArray *beacons = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *beaconDict in beaconDictList) {
        PCIBeacon *beacon = [[PCIBeacon alloc] initWithDictionary:beaconDict];
        [beacons addObject:beacon];
    }
    return beacons;
}

- (void)serializeDocuments:(NSArray *)documents intoDictionary:(NSMutableDictionary *)dict forKey:(NSString *)key {
    NSMutableArray *documentListArray = [NSMutableArray array];
    for (CCBDocument *document in documents) {
        if (![document.fileName length]) continue;
        [documentListArray addObject:document.fileName];
    }
    [dict setObject:documentListArray forKey:key];
}

- (NSMutableArray *)deserializeDocumentsInDictionary:(NSDictionary *)dict key:(NSString *)key {
    NSArray *filenames = dict[key];
    NSMutableArray *documents = [NSMutableArray array];
    for (NSString *filename in filenames) {
        [documents addObject:[[CCBDocument alloc] initWithFile:[[PCResourceManager sharedManager] toAbsolutePath:filename]]];
    }
    return documents;
}

#pragma mark - dynamic properties

- (NSArray*) absoluteResourcePaths
{
    NSString* projectDirectory = [self.projectFilePath stringByDeletingLastPathComponent];
    
    NSMutableArray* paths = [NSMutableArray array];
    
    for (NSDictionary* dict in resourcePaths)
    {
        NSString* path = [dict objectForKey:@"path"];
        NSString* absPath = [path absolutePathFromBaseDirectoryPath:projectDirectory];
        [paths addObject:absPath];
    }
    
    if ([paths count] == 0)
    {
        [paths addObject:projectDirectory];
    }
    
    return paths;
}

- (NSString *)projectFilePathHashed
{
    if (self.projectFilePath)
    {
        HashValue* hash = [HashValue md5HashWithString:self.projectFilePath];
        return [hash description];
    }
    else
    {
        return NULL;
    }
}

- (NSString*) displayCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[[paths.firstObject stringByAppendingPathComponent:@"com.robotsandpencils.PencilCase"] stringByAppendingPathComponent:@"display"] stringByAppendingPathComponent:self.projectFilePathHashed];
}

- (NSString *)projectFilePath {
    return [self.projectFileReferenceURL path];
}

- (NSString *)projectDirectory {
    return [self.projectFilePath stringByDeletingLastPathComponent];
}

#pragma mark - private

- (void) _storeDelayed
{
    [self store];
    storing = NO;
}

- (BOOL) store
{
    NSString *temporaryProjectFilePath = self.projectFilePath;
    BOOL success = [[self serialize] writeToFile:self.projectFilePath atomically:YES];
    if (!success) {
        NSLog(@"Error saving project settings to file");
    }
    else {
        self.projectFileReferenceURL = [[NSURL fileURLWithPath:temporaryProjectFilePath] fileReferenceURL];
        self.isDirty = NO;
    }

    return success;
}

- (void) storeDelayed
{
    // Store the file after a short delay
    if (!storing)
    {
        storing = YES;
        [self performSelector:@selector(_storeDelayed) withObject:NULL afterDelay:1];
    }
}

#pragma mark - public Resource methods

- (void) setValue:(id) val forResource:(PCResource *) res andKey:(id) key
{
    NSString* relPath = res.relativePath;
    [self setValue:val forRelPath:relPath andKey:key];
}

- (void) setValue:(id)val forRelPath:(NSString *)relPath andKey:(id)key
{
    // Create value if it doesn't exist
    NSMutableDictionary* props = [resourceProperties valueForKey:relPath];
    if (!props)
    {
        props = [NSMutableDictionary dictionary];
        [resourceProperties setValue:props forKey:relPath];
    }
    
    // Compare to old value
    id oldValue = [props objectForKey:key];
    if (!(oldValue && [oldValue isEqual:val]))
    {
        // Set the value if it has changed
        [props setValue:val forKey:key];
        
        // Also mark as dirty
        [props setValue:[NSNumber numberWithBool:YES] forKey:@"isDirty"];
        
        [self storeDelayed];
    }
}

- (id) valueForResource:(PCResource *) res andKey:(id) key
{
    NSString* relPath = res.relativePath;
    return [self valueForRelPath:relPath andKey:key];
}

- (id) valueForRelPath:(NSString*) relPath andKey:(id) key
{
    NSMutableDictionary* props = [resourceProperties valueForKey:relPath];
    return [props valueForKey:key];
}

- (void) removeObjectForResource:(PCResource *) res andKey:(id) key
{
    NSString* relPath = res.relativePath;
    [self removeObjectForRelPath:relPath andKey:key];
    
}

- (void) removeObjectForRelPath:(NSString*) relPath andKey:(id) key
{
    NSMutableDictionary* props = [resourceProperties valueForKey:relPath];
    [props removeObjectForKey:key];
    
    [self storeDelayed];
}

- (NSArray *)dirtyingProperties {
    return @[ @"appName", @"authorVersion", @"previousAuthorVersion", @"appIconImage", @"appIconRetinaImage"];
}

- (void)watchOwnDirtyingProperties {
    if (self.isWatchingDirtyingProperties) return;
    self.watchingDirtyingProperties = YES;

    for (NSString *propertyKey in [self dirtyingProperties]) {
        [self addObserver:self forKeyPath:propertyKey options:0 context:CCBDocumentUndoContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.isDirty = YES;
}

- (BOOL) isDirtyResource:(PCResource *) res
{
    return [self isDirtyRelPath:res.relativePath];
}

- (BOOL) isDirtyRelPath:(NSString*) relPath
{
    return [[self valueForRelPath:relPath andKey:@"isDirty"] boolValue];
}

- (void) markAsDirtyResource:(PCResource *) res
{
    [self markAsDirtyRelPath:res.relativePath];
}

- (void) markAsDirtyRelPath:(NSString*) relPath
{
    [self setValue:[NSNumber numberWithBool:YES] forRelPath:relPath andKey:@"isDirty"];
}

- (void) clearAllDirtyMarkers
{
    for (NSString* relPath in resourceProperties)
    {
        [self removeObjectForRelPath:relPath andKey:@"isDirty"];
    }
    
    [self storeDelayed];
}


- (void) removedResourceAt:(NSString*) relPath
{
    [resourceProperties removeObjectForKey:relPath];
}

- (void) movedResourceFrom:(NSString*) relPathOld to:(NSString*) relPathNew
{
    id props = [resourceProperties objectForKey:relPathOld];
    if (props) [resourceProperties setObject:props forKey:relPathNew];
    [resourceProperties removeObjectForKey:relPathOld];
}

- (NSString *)defaultResourcesSubpath {
    NSString *rootResourcePath = self.absoluteResourcePaths.firstObject;
    if (self.absoluteProjectResourcesPath.length > rootResourcePath.length && [self.absoluteProjectResourcesPath hasPrefix:rootResourcePath]) {
        return [self.absoluteProjectResourcesPath substringFromIndex:rootResourcePath.length + 1]; //extra character for trailing slash in file path
    }
    return nil;
}

#pragma mark - Public

- (void) detectBrowserPresence
{
    isSafariExist = FALSE;
    isChromeExist = FALSE;
    isFirefoxExist = FALSE;
    
    OSStatus result = LSFindApplicationForInfo (kLSUnknownCreator, CFSTR("com.apple.Safari"), NULL, NULL, NULL);
    if (result == noErr)
    {
        isSafariExist = TRUE;
    }
    
    result = LSFindApplicationForInfo (kLSUnknownCreator, CFSTR("com.google.Chrome"), NULL, NULL, NULL);
    if (result == noErr)
    {
        isChromeExist = TRUE;
    }

    result = LSFindApplicationForInfo (kLSUnknownCreator, CFSTR("org.mozilla.firefox"), NULL, NULL, NULL);
    if (result == noErr)
    {
        isFirefoxExist = TRUE;
    }
}

- (NSString* ) getVersion
{
    NSString* versionPath = [[NSBundle mainBundle] pathForResource:@"Version" ofType:@"txt" inDirectory:@"Generated"];
    
    NSString* version = [NSString stringWithContentsOfFile:versionPath encoding:NSUTF8StringEncoding error:NULL];
    return version;
}

- (NSString *)absoluteProjectResourcesPath {
    return [self.absoluteResourcePaths.firstObject stringByAppendingPathComponent:@"resources"];
}

- (NSString *)absoluteProjectFontsPath {
    return [self.absoluteResourcePaths.firstObject stringByAppendingPathComponent:@"Fonts"];
}

- (NSString *)rootPencilCaseResourcesPath {
    return [[self absoluteProjectResourcesPath] stringByDeletingLastPathComponent];
}

- (NSString *)rootProjectResourcesPath {
    return [self.projectFilePath stringByDeletingLastPathComponent];
}

+ (PCSerializationStatus)validateSerialization:(NSDictionary *)serialization error:(NSError **)error {
    NSString *fileType = serialization[@"fileType"];
    
    if (!fileType || (![fileType isEqualToString:PCProjectFileType] && ![fileType isEqualToString:PCOldProjectFileType])) {
        if (error) {
            *error = [NSError pc_unsupportedProjectTypeError];
        }
        return PCSerializationStatusUnsupportedFileType;
    }

    NSInteger fileFormatVersion = [serialization[@"makerFileFormatVersion"] intValue];
    if (fileFormatVersion < PCMakerFileFormatVersionRequiringJSRepublish) {
        return PCSerializationStatusNeedsUpdateAndJSRegeneration;
    }
    if (fileFormatVersion < PCMakerFileFormatVersion) {
        return PCSerializationStatusNeedsUpdate;
    }
    
    if (fileFormatVersion > PCMakerFileFormatVersion) {
        if (error) {
            *error = [NSError pc_unsupportedProjectVersionError];
        }
        return PCSerializationStatusUnsupportedVersion;
    }
    
    if (error) {
        *error = nil;
    }
    return PCSerializationStatusValid;
}

- (void)initalizeProjectFileVersionInfoWithProjectSerialization:(NSDictionary *)serialization {
    self.authorVersion = [serialization[@"authorVersion"] integerValue];
}

#pragma mark - Resolutions

- (NSMutableArray*) updateResolutions:(NSMutableArray*) resolutions forDocDimensionType:(int) type {
    NSMutableArray* updatedResolutions = [NSMutableArray array];

    if (type == kCCBDocDimensionsTypeNode)
    {
        if (self.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
        {
            [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhone]];
            [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPad]];
        }
        else
        {
            [updatedResolutions addObject:[PCDeviceResolutionSettings settingFixed]];
        }
    }
    else if (type == kCCBDocDimensionsTypeLayer)
    {
        PCDeviceResolutionSettings* settingDefault = resolutions.firstObject;

        if (self.deviceResolutionSettings.designTarget == PCDesignTargetFixed)
        {
            settingDefault.name = @"Fixed";
            settingDefault.scale = 2;
            settingDefault.ext = @"tablet phonehd";
            [updatedResolutions addObject:settingDefault];
        }
        else if (self.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
        {
            settingDefault.name = @"Phone";
            settingDefault.scale = 1;
            settingDefault.ext = @"phone";
            [updatedResolutions addObject:settingDefault];

            PCDeviceResolutionSettings* settingTablet = [settingDefault copy];
            settingTablet.name = @"Tablet";
            settingTablet.scale = self.tabletPositionScaleFactor;
            settingTablet.ext = @"tablet phonehd";
            [updatedResolutions addObject:settingTablet];
        }
    }
    else if (type == kCCBDocDimensionsTypeFullScreen)
    {
        if (self.deviceResolutionSettings.deviceOrientation == PCDeviceTargetOrientationLandscape)
        {
            // Full screen landscape
            if (self.deviceResolutionSettings.designTarget == PCDesignTargetFixed)
            {
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingFixedLandscape]];
            }
            else if (self.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
            {
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhone6PlusLandscape]];
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPadLandscape]];
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhoneLandscape]];
            }
        }
        else
        {
            // Full screen portrait
            if (self.deviceResolutionSettings.designTarget == PCDesignTargetFixed)
            {
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingFixedPortrait]];
            }
            else if (self.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
            {
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhone6PlusPortrait]];
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPadPortrait]];
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhonePortrait]];
            }
        }
    }

    return updatedResolutions;
}

#pragma mark - Slide List

- (void)insertObject:(id)object inSlideListAtIndex:(NSUInteger)index {
    [self.slideList insertObject:object atIndex:index];
    [self store];
}

- (void)removeObjectFromSlideListAtIndex:(NSUInteger)index {
    [self.slideList removeObjectAtIndex:index];
    [self store];
}

- (void)insertSubcontentDocument:(id)subcontentDocument {
    if (!self.subcontentDocuments) {
        self.subcontentDocuments = [NSMutableArray array];
    }
    [self.subcontentDocuments addObject:subcontentDocument];
    [self store];
}

- (void)removeObjectFromSubcontentDocumentList:(id)subcontentDocument {
    [self.subcontentDocuments removeObject:subcontentDocument];
    [self store];
}

- (NSArray *)allDocuments {
    return [[self.slideList valueForKey:@"document"] arrayByAddingObjectsFromArray:self.subcontentDocuments];
}

#pragma mark - iBeacons

- (PCIBeacon *)beaconWithUUID:(NSString *)uuid {
	return Underscore.array(self.iBeaconList).find(^BOOL(PCIBeacon *beacon){
		return [beacon.uuid isEqualToString:uuid];
	});
}

@end
