//
//  PCResourceDirectory.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-08-18.
//
//


#import "PCResourceManager.h"
#import "PCResource.h"
#import "PCFileSystemResource.h"

@interface PCResourceDirectory : NSResponder <NSCoding, PCFileSystemResource>

@property (nonatomic, strong) NSURL *directoryReferenceURL;

// Computed from directoryReferenceURL
@property (nonatomic, strong, readonly) NSString *directoryPath;

@property (nonatomic, strong, readonly) NSMutableArray *resources;
@property (nonatomic, strong, readonly) NSMutableArray *any;
@property (nonatomic, readwrite) BOOL loadedWithNilPath;


/**
 Adds a resource to the directory, storing it in the appropriate array and the resources dictionary
 @param resource The resource to add.
 */
- (void)addResource:(PCResource *)resource;

/**
 Removes a resource from all relevant places in the directory
 @param resource The resource to remove
 */
- (void)removeResource:(PCResource *)resource;

@end
