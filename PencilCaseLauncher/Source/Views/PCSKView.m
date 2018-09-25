//
//  PCSKView.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-08-19.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCSKView.h"

@interface PCSKView ()

@property (strong, nonatomic) SKScene *pc_scene;

@end

@implementation PCSKView

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    self.showsPhysics = YES;
//    self.showsFPS = YES;
//    self.showsNodeCount = YES;
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self endEditing:YES];
}

- (CGSize)intrinsicContentSize {
    return self.scene.size;
}

- (void)presentScene:(SKScene *)scene {
    [super presentScene:scene];
    self.pc_scene = scene;
}

- (void)presentScene:(SKScene *)scene transition:(SKTransition *)transition {
    [super presentScene:scene transition:transition];
    self.pc_scene = scene;
}

@end
 