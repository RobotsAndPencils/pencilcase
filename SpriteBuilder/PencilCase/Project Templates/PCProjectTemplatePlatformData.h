//
//  PCProjectTemplatePlatformData.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-14.
//
//

#import <Foundation/Foundation.h>

/*
 @discussion Stores data in a project template specific to a platform, as well as a platform type.
 */
@interface PCProjectTemplatePlatformData : NSObject

@property (strong, nonatomic) NSArray *resources;

/**
 Given a dictionary, attempts to load the template data for a specific platform.
 @param dictionary the dictionary to attempt to load the platform information from
 @returns a `PCProjectTemplatePlatformData` if the loading is a success, nil if it fails
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
