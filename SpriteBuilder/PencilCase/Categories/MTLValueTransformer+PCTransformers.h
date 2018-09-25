//
//  MTLValueTransformer+PCTransformers.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2015-01-05.
//
//

#import "MTLValueTransformer.h"

@interface MTLValueTransformer (PCTransformers)

/**
 * @discussion Transformer for converting a string to UUID (forward) and the reverse.
 */
+ (NSValueTransformer *)pc_stringToUUIDReversibleTransformer;

/**
 * @discussion Transformer for converting NSImage to base 64 encoded string and reverse
 */
+ (NSValueTransformer *)pc_imageToBase64EncodedPNGDataTransformer;

/**
 * @discussion Transformer for converting NSData to base 64 encoded string and reverse
 */
+ (NSValueTransformer *)pc_base64DataTransformer;

@end
