//
//  PCBSKFingerPaintView.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-07-18.
//
//

#import "PCBSKFingerPaintView.h"
#import "SKNode+CocosCompatibility.h"
#import "AppDelegate.h"

@implementation PCBSKFingerPaintView

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    self.userInteractionEnabled = NO;
    
    return self;
}

- (BOOL)canParticipateInPhysics {
    return NO;
}

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

@end
