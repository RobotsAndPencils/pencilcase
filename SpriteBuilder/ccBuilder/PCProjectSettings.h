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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "PCDeviceResolutionSettings.h"
#import "PCKeyValueStoreKeyConfigStore.h"

#define kCCBProjectSettingsVersion 1
#define kCCBDefaultExportPlugIn @"ccbi"

@class PCResource;
@class PCWarningGroup;
@class PCIBeacon;

typedef NS_ENUM(NSInteger, PCStageBorderType) {
    PCStageBorderTypeNone = 0,
    PCStageBorderTypeDevice,
    PCStageBorderTypeTransparent,
    PCStageBorderTypeOpaque,
    PCStageBorderTypeDefault = PCStageBorderTypeDevice
};

typedef NS_ENUM(NSInteger, PCSerializationStatus) {
    PCSerializationStatusUnsupportedFileType = 0,
    PCSerializationStatusUnsupportedVersion,
    PCSerializationStatusValid,
    PCSerializationStatusNeedsUpdate,
    PCSerializationStatusNeedsUpdateAndJSRegeneration
};

static NSString *const PCProjectFileType = @"PencilCaseProject";
static NSString *const PCOldProjectFileType = @"CocosBuilderProject";

@interface PCProjectSettings : NSObject
{
    NSMutableArray* resourcePaths;
    NSMutableDictionary* resourceProperties;
    
    NSString* publishDirectory;
    
    BOOL publishEnablediPhone;
    BOOL publishEnabledAndroid;
    BOOL publishEnabledHTML5;
    
    BOOL publishResolution_ios_phone;
    BOOL publishResolution_ios_phonehd;
    BOOL publishResolution_ios_tablet;
    BOOL publishResolution_ios_tablethd;
    BOOL publishResolution_android_phone;
    BOOL publishResolution_android_phonehd;
    BOOL publishResolution_android_tablet;
    BOOL publishResolution_android_tablethd;
    
    int publishResolutionHTML5_width;
    int publishResolutionHTML5_height;
    int publishResolutionHTML5_scale;
    
    int publishAudioQuality_ios;
    int publishAudioQuality_android;
    
    BOOL isSafariExist;
    BOOL isChromeExist;
    BOOL isFirefoxExist;
    
    BOOL flattenPaths;
    BOOL publishToZipFile;
    BOOL javascriptBased;
    NSString* exporter;
    NSMutableArray* availableExporters;
    NSString* javascriptMainCCB;
    BOOL deviceOrientationPortrait;
    BOOL deviceOrientationUpsideDown;
    BOOL deviceOrientationLandscapeLeft;
    BOOL deviceOrientationLandscapeRight;
    int resourceAutoScaleFactor;
    
    PCWarningGroup* lastWarnings;
    
    BOOL storing;
}

// Computed from projectFileReferenceURL
@property (nonatomic, copy, readonly) NSString *projectFilePath;

@property (nonatomic, strong) NSURL *projectFileReferenceURL;
@property (nonatomic, readonly) NSString *projectFilePathHashed;
@property (nonatomic, strong) NSMutableArray *resourcePaths;
@property (nonatomic, strong) NSMutableArray *slideList;
@property (nonatomic, strong) NSArray *iBeaconList; // [PCIBeacon]
@property (nonatomic, strong) NSMutableArray *subcontentDocuments;
@property (nonatomic, readonly) NSArray *allDocuments;

@property (nonatomic,assign) BOOL publishEnablediPhone;
@property (nonatomic,assign) BOOL publishEnabledAndroid;
@property (nonatomic,assign) BOOL publishEnabledHTML5;

@property (nonatomic, copy) NSString *publishDirectory;
@property (nonatomic, copy) NSString *publishDirectoryAndroid;
@property (nonatomic, copy) NSString *publishDirectoryHTML5;

@property (nonatomic,assign) BOOL publishResolution_ios_phone;
@property (nonatomic,assign) BOOL publishResolution_ios_phonehd;
@property (nonatomic,assign) BOOL publishResolution_ios_tablet;
@property (nonatomic,assign) BOOL publishResolution_ios_tablethd;
@property (nonatomic,assign) BOOL publishResolution_android_phone;
@property (nonatomic,assign) BOOL publishResolution_android_phonehd;
@property (nonatomic,assign) BOOL publishResolution_android_tablet;
@property (nonatomic,assign) BOOL publishResolution_android_tablethd;

@property (nonatomic,assign) int publishResolutionHTML5_width;
@property (nonatomic,assign) int publishResolutionHTML5_height;
@property (nonatomic,assign) int publishResolutionHTML5_scale;

@property (nonatomic,assign) int publishAudioQuality_ios;
@property (nonatomic,assign) int publishAudioQuality_android;

@property (nonatomic,assign) BOOL isSafariExist;
@property (nonatomic,assign) BOOL isChromeExist;
@property (nonatomic,assign) BOOL isFirefoxExist;

@property (nonatomic, copy) NSString *javascriptMainCCB;
@property (nonatomic, assign) BOOL flattenPaths;
@property (nonatomic, assign) BOOL publishToZipFile;
@property (nonatomic, assign) BOOL javascriptBased;
@property (nonatomic, readonly) NSArray *absoluteResourcePaths;

// The directory that contains the project file
@property (nonatomic, readonly) NSString *projectDirectory;

@property (nonatomic, copy) NSString *exporter;
@property (nonatomic, strong) NSMutableArray *availableExporters;
@property (nonatomic, readonly) NSString *displayCacheDirectory;
//@property (nonatomic, readonly) NSString* publishCacheDirectory;
@property (nonatomic, assign) BOOL deviceOrientationPortrait;
@property (nonatomic, assign) BOOL deviceOrientationUpsideDown;
@property (nonatomic, assign) BOOL deviceOrientationLandscapeLeft;
@property (nonatomic, assign) BOOL deviceOrientationLandscapeRight;
@property (nonatomic, assign) int resourceAutoScaleFactor;

@property (nonatomic, assign) int designTarget;
@property (nonatomic, assign) int defaultOrientation;
@property (nonatomic, assign) int deviceScaling;

@property (nonatomic, assign) float tabletPositionScaleFactor;
@property (nonatomic, strong) PCDeviceResolutionSettings *deviceResolutionSettings;

@property (nonatomic, strong) PCWarningGroup *lastWarnings;

@property (nonatomic, strong) NSMutableDictionary *nodeClassCounts;

// View menu item settings
@property (nonatomic, assign) BOOL showGuides;
@property (nonatomic, assign) BOOL snapToGuides;
@property (nonatomic, assign) BOOL snapToObjects;
@property (nonatomic, assign) PCStageBorderType stageBorderType;

// App settings
@property (nonatomic, strong) NSString *appName;

@property (nonatomic, strong) NSImage *appIconImage;
@property (nonatomic, strong) NSImage *appIconRetinaImage;

@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, assign) NSInteger authorVersion;
@property (nonatomic, assign) NSInteger previousAuthorVersion;
@property (nonatomic, assign) NSInteger createdAuthorVersion;

// Debugging settings
@property (nonatomic, assign) BOOL enableDefaultREPLGesture;
@property (nonatomic, assign) BOOL showFPS;
@property (nonatomic, assign) BOOL showNodeCount;
@property (nonatomic, assign) BOOL showQuadCount;
@property (nonatomic, assign) BOOL showDrawCount;
@property (nonatomic, assign) BOOL showPhysicsBorders;
@property (nonatomic, assign) BOOL showPhysicsFields;

@property (nonatomic, copy) NSString *xcodeProjectExportPath;

// We need to make sure that the node manager has the same UUID *always*
// If not, then when we deselect all nodes and reselect one (which necessarily creates a new node manager) it will have a newly-generated UUID
// This won't match up with the UUIDs stored in the behaviour manager's behaviours
// This is likely a temporary necessity since eventually the node manager won't be involved in managing behaviours at all
@property (nonatomic, copy) NSUUID *nodeManagerUUID;

// NSDocument
@property (nonatomic) BOOL isDirty;

@property (nonatomic, strong) PCKeyValueStoreKeyConfigStore *keyConfigStore;

@property (nonatomic, readonly) NSString *defaultResourcesSubpath;

/**
 *  Initializes settings from a serialization dictionary
 *
 *  @param dict The project settings serialization
 *  @param error This error will provide more information about the nature of any errors when initializing, or nil if there were none
 *
 *  @return The initialized project settings or nil if there were errors
 */
- (id)initWithValidSerialization:(id)dict fromPackageURL:(NSURL *)projectPackageURL;

/**
 *  Validates the file type and version keys in a document dictionary to make sure the running version of PencilCase supports them.
 *
 *  @param documentDictionary The project settings serialization loaded as a dictionary
 *  @param error More detailed information about the error if the dictionary is not valid, or nil if it is
 *
 *  @return Whether or not the serialization is valid
 */
+ (PCSerializationStatus)validateSerialization:(NSDictionary *)serialization error:(NSError **)error;

// This method is only public for one specific use in AppDelegate, see the comments there explaining why this workaround
// is necessary.
- (NSMutableArray *)deserializeSlideListInDictionary:(NSDictionary *)dict key:(NSString *)key;

- (void)newProjectSetupWithDeviceTarget:(PCDeviceTargetType)target withOrientation:(PCDeviceTargetOrientation)orientation; // Call only when creating a new project. NOT on every open.

- (BOOL) store;
- (id) serialize;

/**
 *  Sets up KVO for project settings properties that should mark the project as "dirty". This observation will be torn down at dealloc, so this should only need to be called when opening or creating new projects.
 */
- (void)watchOwnDirtyingProperties;

// Setting and reading file properties
- (void) setValue:(id)val forResource:(PCResource *) res andKey:(id) key;
- (void) setValue:(id)val forRelPath:(NSString *)relPath andKey:(id)key;
- (id) valueForResource:(PCResource *) res andKey:(id) key;
- (id) valueForRelPath:(NSString*) relPath andKey:(id) key;
- (void) removeObjectForResource:(PCResource *) res andKey:(id) key;
- (void) removeObjectForRelPath:(NSString*) relPath andKey:(id) key;
- (BOOL) isDirtyResource:(PCResource *) res;
- (BOOL) isDirtyRelPath:(NSString*) relPath;
- (void) markAsDirtyResource:(PCResource *) res;
- (void) markAsDirtyRelPath:(NSString*) relPath;
- (void) clearAllDirtyMarkers;

// Handling moved and deleted resources
- (void) removedResourceAt:(NSString*) relPath;
- (void) movedResourceFrom:(NSString*) relPathOld to:(NSString*) relPathNew;

- (NSString* ) getVersion;

/**
 The path of the resources in the project file. Not the published resources.
 */
- (NSString *)absoluteProjectResourcesPath;

/*
 * Path to the fonts directory for custom label font files
 */
- (NSString *)absoluteProjectFontsPath;

/**
 The path of the PencilCase Resources folder
 */
- (NSString *)rootPencilCaseResourcesPath;

- (NSString *)rootProjectResourcesPath;

#pragma mark - Loading

- (NSMutableArray*) updateResolutions:(NSMutableArray*) resolutions forDocDimensionType:(int) type;

#pragma mark - Slide List

- (void)insertObject:(id)object inSlideListAtIndex:(NSUInteger)index1;
- (void)removeObjectFromSlideListAtIndex:(NSUInteger)index1;

- (void)insertSubcontentDocument:(id)subcontentDocument;
- (void)removeObjectFromSubcontentDocumentList:(id)subcontentDocument;

#pragma mark - iBeacons

- (PCIBeacon *)beaconWithUUID:(NSString *)uuid;

@end
