//
//  PCResourceManager+ProjectTemplate.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-15.
//
//

#import "PCResourceManager.h"

@class PCProjectTemplate;

@interface PCResourceManager (ProjectTemplate)

/**
 Loads the resources from a project template by unzipping them into the resources folder, then creating the matching PCResource objects to track them
 @param projectTemplate the project template to load the resources from
 @param device The device type that we should be loading our resources for
 */
- (void)loadResourcesFromProjectTemplate:(PCProjectTemplate *)projectTemplate forDeviceType:(PCDeviceTargetType)device;

@end
