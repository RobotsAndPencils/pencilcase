//
//  NSError+PencilCaseErrors.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PCErrorCode) {
    PCErrorCodeUnsupportedProjectType = 50,
    PCErrorCodeUnsupportedProjectVersion,
    PCErrorCodeDirectoryNameCollision,
    PCErrorCodeInvalidProjectFile = 101,
    PCErrorCodeDiskIO,
    // API errors
    PCErrorCodeInvalidResponse,
    PCErrorCodeInvalidLogin,
    PCErrorCodeUnauthorized,
    PCErrorCodePaymentRequired,
    PCErrorCodeRateLimitExceeded,
    PCErrorCodeAccountSuspended,
    PCErrorCodeClientTooOld,
    PCErrorCodeGenericNetworkError,
    PCErrorCodeResourceChecksum
};

/**
 Category that exposes access to pencilcase error convenience methods
 */
@interface NSError (PencilCaseErrors)

+ (NSError *)pc_createDirectoryNameCollisionError;
+ (NSError *)pc_unsupportedProjectTypeError;
+ (NSError *)pc_unsupportedProjectVersionError;
+ (NSError *)pc_invalidProjectError;

// Not to be presented to the user
+ (NSError *)pc_resourceChecksumErrorWithDescription:(NSString *)description;

@end
