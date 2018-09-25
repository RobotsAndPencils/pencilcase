//
//  CCBPSKNodeColor.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-18.
//
//

#import "CCBPSKNodeColor.h"
#import "SKNode+CocosCompatibility.h"
#import "AppDelegate.h"

@implementation CCBPSKNodeColor

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.userInteractionEnabled = NO;
    
    return self;
}

@end
