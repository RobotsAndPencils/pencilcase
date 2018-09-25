//
//  PCMailComposeController.h
//  Pods
//
//  Created by Cody Rayment on 2015-05-12.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface PCMailComposeController : NSObject

@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSArray *toRecipients;
@property (strong, nonatomic) NSArray *ccRecipients;
@property (strong, nonatomic) NSArray *bccRecipients;

+ (BOOL)canSendMail;

- (void)setMessageBody:(NSString *)body isHTML:(BOOL)isHTML;
- (void)addAttachmentData:(NSData *)attachment mimeType:(NSString *)mimeType fileName:(NSString *)filename;
- (void)show:(void (^)(MFMailComposeResult result, NSError *error))completion;

@end
