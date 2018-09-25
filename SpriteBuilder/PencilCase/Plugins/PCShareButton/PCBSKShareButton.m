//
//  PCBSKShareButton.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-29.
//
//

#import "PCBSKShareButton.h"
#import "SKNode+CocosCompatibility.h"

@implementation PCBSKShareButton

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

@end
