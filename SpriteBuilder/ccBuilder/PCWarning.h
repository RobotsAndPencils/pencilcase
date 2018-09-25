//
//  PCWarning.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-20.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface PCWarning : NSObject

@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *relatedFile;
@property (copy, nonatomic) NSString *resolution;
@property (copy, readonly, nonatomic) NSString *description;

@property (assign, nonatomic) PCPublisherTargetType targetType;
@property (assign, nonatomic) BOOL fatal;

@end