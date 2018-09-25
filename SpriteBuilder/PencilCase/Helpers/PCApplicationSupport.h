//
//  PCApplicationSupport.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-20.
//
//

#import <Foundation/Foundation.h>

@interface PCApplicationSupport : NSObject

+ (NSString *)deviceIdentifierApplicationSupportFilePath;
+ (NSString *)defaultProjectPath;
+ (NSString *)pencilCaseApplicationSupportDirectoryPath;

@end
