//
//  NSError+DataErrors.h
//  Pods
//
//  Created by Stephen Gazzard on 2015-05-04.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PCDataErrorCode) {
    PCDataErrorCodeInvalidPath = 1150
};

@interface NSError (DataErrors)

+ (NSError *)pc_invalidDataPathError;

@end
