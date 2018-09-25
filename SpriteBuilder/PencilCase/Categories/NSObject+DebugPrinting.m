//
//  NSObject+DebugPrinting.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-18.
//
//

#import "NSObject+DebugPrinting.h"

@implementation NSObject (DebugPrinting)

#pragma mark - Public

+ (NSString *)pc_debugDifferentDescriptionBetween:(id)obj and:(id)obj1 {
    NSMutableString *result = [NSMutableString stringWithFormat:@"\n---------------------\n"];
    [self pc_debugDifferentDescriptionBetween:obj and:obj1 result:result level:@""];
    [result appendString:@"---------------------\n"];
    return result;
}

#pragma mark - Private

/**
 *  Recursively compare between obj and obj1 and return a string of the differences between the two.
 *
 *  @param obj    First object to compare
 *  @param obj1   Second object to compare
 *  @param result Current result string to append to
 *  @param level  Current level in form of string we have recursively evaluating
 *
 *  @return The difference between to the two object
 */
+ (NSString *)pc_debugDifferentDescriptionBetween:(id)obj and:(id)obj1 result:(NSMutableString *)result level:(NSString *)level {
    if ([obj isKindOfClass:[NSDictionary class]] && [obj1 isKindOfClass:[NSDictionary class]]){
        NSDictionary *dictionary = obj;
        NSDictionary *dictionary1 = obj1;

        NSMutableSet *allKeys = [NSMutableSet set];
        [allKeys addObjectsFromArray:[dictionary allKeys]];
        [allKeys addObjectsFromArray:[dictionary1 allKeys]];

        // for dictionary, use the combined set of keys and parse through each object from both dictionary and compare
        for (NSObject *dictionaryKey in allKeys){
            id dictionaryValue = [dictionary objectForKey:dictionaryKey];
            id dictionaryValue1 = [dictionary1 objectForKey:dictionaryKey];

            NSString *levelKey = [NSString stringWithFormat:@"%@->%@",level, dictionaryKey];
            [self pc_debugDifferentDescriptionBetween:dictionaryValue and:dictionaryValue1 result:result level:levelKey];
        }
    }
    else if ([obj isKindOfClass:[NSArray class]] && [obj1 isKindOfClass:[NSArray class]]){
        NSArray *array = obj;
        NSArray *array1 = obj1;

        if ([array count] > [array1 count]){
            // parse through the second array first
            for (int i = 0; i < [array1 count]; i++){
                id value = [array objectAtIndex:i];
                id value1 = [array1 objectAtIndex:i];
                NSString *levelKey = [NSString stringWithFormat:@"%@->%d",level, i];
                [self pc_debugDifferentDescriptionBetween:value and:value1 result:result level:levelKey];
            }
            // since first array is bigger, evaluate extra values to nils
            for (int i = [array1 count]; i < [array count]; i++){
                id value = [array objectAtIndex:i];
                NSString *levelKey = [NSString stringWithFormat:@"%@->%d",level, i];
                [self pc_debugDifferentDescriptionBetween:value and:nil result:result level:levelKey];
            }
        }
        else if ([array1 count] > [array count]){
            // parse through the first array first
            for (int i = 0; i < [array count]; i++){
                id value = [array objectAtIndex:i];
                id value1 = [array1 objectAtIndex:i];
                NSString *levelKey = [NSString stringWithFormat:@"%@->%d",level, i];
                [self pc_debugDifferentDescriptionBetween:value and:value1 result:result level:levelKey];
            }
            // since second array is bigger, evaluate extra values to nils
            for (int i = [array count]; i < [array1 count]; i++){
                id value = [array1 objectAtIndex:i];
                NSString *levelKey = [NSString stringWithFormat:@"%@->%d",level, i];
                [self pc_debugDifferentDescriptionBetween:nil and:value result:result level:levelKey];
            }
        }
        else {
            // evaluate each values in both array according to their index
            for (int i = 0; i < [array count]; i++){
                id value = [array objectAtIndex:i];
                id value1 = [array1 objectAtIndex:i];
                NSString *levelKey = [NSString stringWithFormat:@"%@->%d",level, i];
                [self pc_debugDifferentDescriptionBetween:value and:value1 result:result level:levelKey];
            }
        }
    }
    else {
        // check if the objects are equal
        if (![obj isEqual:obj1]){
            [result appendString:[NSString stringWithFormat:@"%@-> %@ != %@\n", level, obj, obj1]];
        }
    }

    return result;
}

@end
