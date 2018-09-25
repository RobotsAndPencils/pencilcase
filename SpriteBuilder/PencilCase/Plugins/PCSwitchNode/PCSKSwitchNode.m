//
//  PCSKSwitchNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-21.
//
//

#import "PCSKSwitchNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+NodeInfo.h"
#import "PlugInNode.h"
#import "PCDoubleClickableNode.h"
#import "AppDelegate.h"

@interface PCSKSwitchNode () <PCDoubleClickableNode>

@property (assign, nonatomic) BOOL isOn;

@end

@implementation PCSKSwitchNode

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self setup];
}

#pragma mark - Private

- (void)setup {
    if (!self.texture) {
        self.anchorPoint = NSMakePoint(0.5, 0);
        [self updateImageFromState];
    }
}

- (void)updateImageFromState {
    NSString *imagePath = [[self.plugIn bundle] pathForImageResource:self.isOn ? @"Switch_on" : @"Switch_off"];
    self.texture = [SKTexture textureWithImageNamed:imagePath];
    self.contentSize = self.texture.size;
}

#pragma mark - Properties

- (void)setIsOn:(BOOL)isOn {
    _isOn = isOn;
    [self updateImageFromState];
    [[AppDelegate appDelegate] refreshProperty:@"isOn"];
}

#pragma mark - PCDoubleClickableNode implementation

- (void)nodeReceivedDoubleClick {
    self.isOn = !self.isOn;
}


@end
