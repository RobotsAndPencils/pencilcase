//
//  PCMailComposeController+JSExport.h
//  Pods
//
//  Created by Cody Rayment on 2015-05-12.
//
//

#import "PCMailComposeController.h"
@import JavaScriptCore;

@protocol PCMailComposeControllerExport <JSExport>

@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSArray *toRecipients;
@property (strong, nonatomic) NSArray *ccRecipients;
@property (strong, nonatomic) NSArray *bccRecipients;

+ (BOOL)canSendMail;

- (instancetype)init;

JSExportAs(setMessageBody,
- (void)setMessageBody:(NSString *)body isHTML:(BOOL)isHTML
);

JSExportAs(show,
- (void)js_show:(JSValue *)completion
);

JSExportAs(attachData,
- (void)addAttachmentData:(NSData *)attachment mimeType:(NSString *)mimeType fileName:(NSString *)filename
);

JSExportAs(attachImage,
- (void)js_attachImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality fileName:(NSString *)fileName
);

@end


@interface PCMailComposeController (JSExport) <PCMailComposeControllerExport>

@end
