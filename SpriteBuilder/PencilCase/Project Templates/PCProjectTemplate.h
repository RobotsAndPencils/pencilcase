//
//  ProjectTemplate.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-14.
//
//

#import <Foundation/Foundation.h>
#import "PCProjectTemplatePlatformData.h"
#import "PCDeviceResolutionSettings.h"

@interface PCProjectTemplate : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) PCProjectTemplatePlatformData *iPhoneData;
@property (strong, nonatomic) PCProjectTemplatePlatformData *iPadData;

/**
 Given an NSDictionary containing a serialized project template, loads a project template.
 @param dictionary an `NSDictionary` containing a serialized project template.
 @returns a `PCProjectTemplate` if the dictionary is valid, nil if it is not.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Convenience method that loads a PCProjectTemplate from a serialized dictionary stored in a file
 @param filePath the path to the dictionary on the file system
 @returns a `PCProjectTemplate` if the dictionary is valid, nil if it is not.
 */
- (instancetype)initWithFile:(NSString *)filePath;


#pragma mark - Device level property accessors

/* Stephen's notes
   For accessors that are stored within iPhoneData or iPadData, we call them through these methods, where we provide the appropriate type. This does a translation into the correct internal data object. I think there is a possibility, later down the road, that we will want to have a 'common' data object as well for values that the iPhone and iPad share, so by calling into this, we can update our internal API should that ever be the case without having to modify our external calls.
 */

/**
 @param The device type that we want to the resources for.
 @returns The resources for the specified device
 */
- (NSArray *)resourcesForDevice:(PCDeviceTargetType)deviceType;

@end
