//
//  PCMailComposeController.m
//  Pods
//
//  Created by Cody Rayment on 2015-05-12.
//
//

#import "PCMailComposeController.h"
#import "PCJSContext.h"
#import "PCAppViewController.h"

@interface PCMailComposeController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MFMailComposeViewController *mailComposeController;
@property (copy, nonatomic) void (^completionHandler)(MFMailComposeResult result, NSError *error);
@property (strong, nonatomic) NSString *messageBody;
@property (assign, nonatomic) BOOL messageBodyIsHTML;
@property (strong, nonatomic) NSMutableArray *attachmentInfos;

@end

@implementation PCMailComposeController

- (instancetype)init {
    self = [super init];
    if (self) {
        _attachmentInfos = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public

+ (BOOL)canSendMail {
    return [MFMailComposeViewController canSendMail];
}

- (void)setMessageBody:(NSString *)body isHTML:(BOOL)isHTML {
    self.messageBody = body;
    self.messageBodyIsHTML = isHTML;
}

- (void)addAttachmentData:(NSData *)attachment mimeType:(NSString *)mimeType fileName:(NSString *)filename {
    if (!attachment) return;
    if (!mimeType) return;
    if (!filename) return;

    [self.attachmentInfos addObject:@{
                                      @"attachment": attachment,
                                      @"mimeType": mimeType,
                                      @"filename": filename,
                                      }];
}

- (void)show:(void (^)(MFMailComposeResult result, NSError *error))completion {
    if (self.mailComposeController) return;
    if (![MFMailComposeViewController canSendMail]) {
        if (completion) {
            completion(MFMailComposeResultFailed, nil);
            return;
        }
    };

    self.completionHandler = completion;

    self.mailComposeController = [[MFMailComposeViewController alloc] init];
    self.mailComposeController.mailComposeDelegate = self;

    if (self.subject) [self.mailComposeController setSubject:self.subject];
    if (self.toRecipients) [self.mailComposeController setToRecipients:self.toRecipients];
    if (self.ccRecipients) [self.mailComposeController setCcRecipients:self.ccRecipients];
    if (self.bccRecipients) [self.mailComposeController setBccRecipients:self.bccRecipients];
    if (self.messageBody) {
        [self.mailComposeController setMessageBody:self.messageBody isHTML:self.messageBodyIsHTML];
    }
    for (NSDictionary *attachmentInfo in self.attachmentInfos) {
        NSData *attachment = attachmentInfo[@"attachment"];
        NSString *mimeType = attachmentInfo[@"mimeType"];
        NSString *filename = attachmentInfo[@"filename"];

        [self.mailComposeController addAttachmentData:attachment mimeType:mimeType fileName:filename];
    }

    [[PCAppViewController lastCreatedInstance] presentViewController:self.mailComposeController animated:YES completion:^{}];
}

#pragma mark - Private

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.mailComposeController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        self.mailComposeController = nil;
        if (self.completionHandler) self.completionHandler(result, error);
    }];
}

@end
