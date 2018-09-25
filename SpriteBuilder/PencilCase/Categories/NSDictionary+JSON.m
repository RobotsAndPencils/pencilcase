//
//  NSDictionary+JSON.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-04-17.
//
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

+ (instancetype)dictionaryFromJSONFile:(NSString *)path error:(NSError **)error {
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSError *jsonDeserializationError;
    NSDictionary *definition = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonDeserializationError];
    if (jsonDeserializationError) {
        *error = jsonDeserializationError;
        return nil;
    }
    return definition;
}

@end
