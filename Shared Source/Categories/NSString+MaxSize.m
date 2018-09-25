//
//  NSString+MaxSize.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-06-16.
//
//

#import "NSString+MaxSize.h"

@implementation NSString (MaxSize)

- (NSArray *)pc_splitIntoChunksWithMaxWidth:(NSInteger)width attributes:(NSDictionary *)textAttributes {
    if (self.length <= 1) return @[self];

    CGSize size = [self sizeWithAttributes:textAttributes];
    if (size.width <= width) return @[self];

    NSInteger halfwayPoint = self.length / 2;
    NSArray *firstArray = [[self substringToIndex:halfwayPoint] pc_splitIntoChunksWithMaxWidth:width attributes:textAttributes];
    NSArray *secondArray = [[self substringFromIndex:halfwayPoint] pc_splitIntoChunksWithMaxWidth:width attributes:textAttributes];
    return [firstArray arrayByAddingObjectsFromArray:secondArray];
}

@end
