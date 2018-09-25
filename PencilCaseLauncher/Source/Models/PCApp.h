//
//  PCApp 
//  PCPlayer
//
//  Created by brandon on 2/13/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//
#import "PCDeviceResolutionSettings.h"

@class PCKeyValueStore;

@interface PCApp : NSObject

@property (strong, nonatomic) PCDeviceResolutionSettings *deviceSettings;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *uuid;
@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) UIImage *splashScreenImage;
@property (strong, nonatomic) UIColor *primaryColor;
@property (strong, nonatomic) UIColor *secondaryColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) NSMutableDictionary *keyPressedCardLookup;
@property (strong, nonatomic) NSArray *iBeacons;
@property (strong, nonatomic) NSArray *tableCellTypes;
@property (strong, nonatomic) NSNumber *fileFormatVersion;
@property (strong, nonatomic) PCKeyValueStore *keyValueStore;
@property (assign, nonatomic) BOOL enableDefaultREPLGesture;
@property (assign, nonatomic) BOOL showFPS;
@property (assign, nonatomic) BOOL showNodeCount;
@property (assign, nonatomic) BOOL showQuadCount;
@property (assign, nonatomic) BOOL showDrawCount;
@property (assign, nonatomic) BOOL showPhysicsBorders;
@property (assign, nonatomic) BOOL showPhysicsFields;

+ (instancetype)createWithURL:(NSURL *)url;
+ (NSArray *)readApps;
+ (PCApp *)appWithUUID:(NSString *)uuid;
+ (BOOL)deleteApp:(PCApp *)app;
+ (void)autoInstall;

- (void)setupKeyValueStore;
- (void)tearDownKeyValueStore;

- (void)findResourcesWithURL:(NSURL *)url;
- (BOOL)resourcesSameAsApp:(PCApp *)app;
- (NSURL *)resourcesURL;
- (NSDictionary *)templateDictionaryWithName:(NSString *)name forClassName:(NSString *)className;

- (NSArray *)fontFileURLs;
- (NSDictionary *)fontNamesDictionary;

- (NSInteger)cardIndexForUUID:(NSUUID *)uuid;

@end
