//
//  NSError+DataErrors.m
//  Pods
//
//  Created by Stephen Gazzard on 2015-05-04.
//
//

#import "NSError+DataErrors.h"

NSString *const PCDataErrorDomain = @"com.robotsandpencils.PencilCase";


@implementation NSError (DataErrors)

+ (NSError *)pc_invalidDataPathError {
    return [NSError errorWithDomain:PCDataErrorDomain code:PCDataErrorCodeInvalidPath userInfo:@{ NSLocalizedDescriptionKey : @"Invalid data path provided"} ];
}

@end
