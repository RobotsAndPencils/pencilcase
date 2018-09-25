//
//  NSDictionary+Utility.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-07.
//
//

#import "NSDictionary+Utility.h"

@implementation NSDictionary (Utility)

- (NSSet *)keysThatDoNotExistInDictionary:(NSDictionary *)compareDictionary {
    NSMutableSet *existingKeys = [NSMutableSet setWithArray:self.allKeys];
    for (id key in compareDictionary.allKeys) {
        [existingKeys removeObject:key];
    }
    return [existingKeys copy];
}

@end
