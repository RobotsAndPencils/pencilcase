//
//  NSString+ComputerModel.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (SystemInformation)

+ (NSString *)pc_computerModel;
+ (NSString *)pc_systemName;
+ (NSString *)pc_systemVersion;

@end
