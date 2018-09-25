//
//  NSDictionary+JSON.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-04-17.
//
//

@interface NSDictionary (JSON)

+ (instancetype)dictionaryFromJSONFile:(NSString *)path error:(NSError **)error;

@end
