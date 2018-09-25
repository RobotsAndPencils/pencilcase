//
//  CCBPSKButton.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-28.
//
//

#import "CCBPSKButton.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"
#import "PCResourceManager.h"

@interface CCBPSKButton ()
@property (nonatomic) BOOL wasHiddenBeforePreview;
@end

@implementation CCBPSKButton

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourScale;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (BOOL)shouldHideForPreview {
    NSString *uuid =[self extraPropForKey:@"backgroundSpriteFrame|Normal"];
    return uuid.length == 0;
}

- (void)showMissingResourceImageIfResourceMissing {
    NSString *uuid = [self extraPropForKey:@"backgroundSpriteFrame|Normal"];
    if (![[PCResourceManager sharedManager] resourceWithUUID:uuid]) {
        [self showMissingResourceImageWithKey:@"backgroundSpriteFrame|Normal"];
    }
}

#pragma mark - PCCustomPreviewNode

- (void)previewWillBegin {
    self.wasHiddenBeforePreview = self.hidden;
    if ([self shouldHideForPreview]) {
        self.hidden = YES;
    }
}

- (void)previewDidFinish {
    self.hidden = self.wasHiddenBeforePreview;
}

@end
