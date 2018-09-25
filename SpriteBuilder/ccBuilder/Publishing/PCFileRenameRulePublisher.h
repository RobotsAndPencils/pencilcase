//
//  PCFileRenameRulePublisher.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-07.
//
//

#import <Foundation/Foundation.h>

@protocol PCFileRenameRulePublisher <NSObject>

- (nonnull NSString *)publishedFilePathFromFilePath:(nonnull NSString *)filePath publisher:(nonnull CCBPublisher *)publisher;

@end
