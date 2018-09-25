//
//  NSError+PencilCaseErrors.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-16.
//
//

#import "NSError+PencilCaseErrors.h"
#import "PCUnsupportedVersionErrorHandler.h"

NSString *const PCErrorDomain = @"com.robotsandpencils.PencilCase";

@implementation NSError (PencilCaseErrors)

#pragma mark - Internal

+ (NSError *)pc_errorWithCode:(PCErrorCode)code localizedMessageKey:(NSString *)messageKey {
    return [self pc_errorWithCode:code localizedMessageKey:messageKey originalError:nil userInfo:nil];
}

+ (NSError *)pc_errorWithCode:(PCErrorCode)code localizedMessageKey:(NSString *)messageKey originalError:(NSError *)originalError {
    return [self pc_errorWithCode:code localizedMessageKey:messageKey originalError:originalError userInfo:nil];
}

+ (NSError *)pc_errorWithCode:(PCErrorCode)code localizedMessageKey:(NSString *)messageKey originalError:(NSError *)originalError userInfo:(NSDictionary *)userInfo {
    NSString *errorMessage = NSLocalizedString(messageKey, nil);
    NSLog(@"%@", errorMessage);
    NSMutableDictionary *info = [@{
                                   NSLocalizedDescriptionKey: errorMessage,
                                   } mutableCopy];
    NSString *recoveryKey = [messageKey stringByAppendingString:@"Recovery"];
    NSString *recoverySuggestion = NSLocalizedString(recoveryKey, nil);
    if (!PCIsEmpty(recoverySuggestion) && ![recoverySuggestion isEqual:recoveryKey]) {
        info[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion;
    }
    if (originalError) {
        info[NSUnderlyingErrorKey] = originalError;
    }
    if (userInfo) {
        [info addEntriesFromDictionary:userInfo];
    }
    return [NSError errorWithDomain:PCErrorDomain code:code userInfo:info];
}

#pragma mark - Public factory methods

+ (NSError *)pc_createDirectoryNameCollisionError {
    return [NSError pc_errorWithCode:PCErrorCodeDirectoryNameCollision localizedMessageKey:@"CreateDirectoryNameCollisionError"];
}

+ (NSError *)pc_unsupportedProjectTypeError {
    return [NSError pc_errorWithCode:PCErrorCodeUnsupportedProjectType localizedMessageKey:@"LoadProjectUnsupportedTypeLocalizedErrorDescriptionFormat"];
}

+ (NSError *)pc_unsupportedProjectVersionError {
    return [NSError pc_errorWithCode:PCErrorCodeUnsupportedProjectVersion localizedMessageKey:@"LoadProjectUnsupportedVersionLocalizedErrorDescriptionFormat"];
}
+ (NSError *)pc_invalidProjectError {
    return [NSError pc_errorWithCode:PCErrorCodeInvalidProjectFile localizedMessageKey:@"InvalidProjectError"];
}

+ (NSError *)pc_resourceChecksumErrorWithDescription:(NSString *)description {
    return [NSError errorWithDomain:PCErrorDomain code:PCErrorCodeResourceChecksum userInfo:@{
        NSLocalizedDescriptionKey: description ?: @""
    }];
}

@end
