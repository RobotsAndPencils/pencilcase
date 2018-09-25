//
//  MTLValueTransformer+PCTransformers.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2015-01-05.
//
//

#import "MTLValueTransformer+PCTransformers.h"
#import "NSImage+PNGRepresentation.h"

@implementation MTLValueTransformer (PCTransformers)

+ (NSValueTransformer *)pc_stringToUUIDReversibleTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *string) {
        return [[NSUUID alloc] initWithUUIDString:string];
    } reverseBlock:^(NSUUID *UUID) {
        return [UUID UUIDString];
    }];
}

+ (NSValueTransformer *)pc_imageToBase64EncodedPNGDataTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *base64Data) {
        if (!base64Data) return (NSImage *)nil;
        return [[NSImage alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:base64Data options:0]];
    } reverseBlock:^(NSImage *image) {
        return [[image PNGRepresentation] base64EncodedStringWithOptions:0];
    }];
}

+ (NSValueTransformer *)pc_base64DataTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *base64Data) {
        if (!base64Data) return (NSData *)nil;
        return [[NSData alloc] initWithBase64EncodedString:base64Data options:0];
    } reverseBlock:^(NSData *data) {
        return [data base64EncodedStringWithOptions:0];
    }];
}

@end
