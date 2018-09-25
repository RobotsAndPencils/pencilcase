//
//  PCMailComposeController+JSExport.m
//  Pods
//
//  Created by Cody Rayment on 2015-05-12.
//
//

#import "PCMailComposeController+JSExport.h"

@implementation PCMailComposeController (JSExport)

- (void)js_show:(JSValue *)completion {
    [self show:^(MFMailComposeResult result, NSError *error) {
        [completion callWithArguments:@[ @(result), error ?: [NSNull null]]];
    }];
}

- (void)js_attachImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality fileName:(NSString *)fileName {
    NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
    [self addAttachmentData:data mimeType:@"image/jpeg" fileName:fileName];
}

@end
