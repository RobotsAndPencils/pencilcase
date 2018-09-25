//
//  PCUserProjectDocument.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-16.
//
//

#import <Foundation/Foundation.h>
#import "PCDeviceResolutionSettings.h"

@interface PCUserProjectDocument : NSObject <NSCoding>

@property (strong, nonatomic) NSURL *userProjectReferenceUrl;
@property (assign, nonatomic) BOOL isFavorite;

@property (copy, nonatomic) NSString *projectName;
@property (copy, nonatomic) NSDate *modificationDate;
@property (assign, nonatomic) PCDeviceTargetType deviceTarget;
@property (strong, nonatomic) NSImage *projectAppIcon;

- (id)initWithProjectURL:(NSURL *)projectUrl isFavorite:(BOOL)isfavorite;

@end
