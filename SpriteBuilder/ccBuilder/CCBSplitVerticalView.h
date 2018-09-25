//
//  CCBSplitVerticalView.h
//  SpriteBuilder
//
//  Created by Brandon on 2/20/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface CCBSplitVerticalView : NSSplitView <NSSplitViewDelegate>

@property (weak, nonatomic) IBOutlet NSView *leftView;
@property (weak, nonatomic) IBOutlet NSView *centerView;
@property (weak, nonatomic) IBOutlet NSView *rightView;

- (void)toggleLeftView;
- (void)showLeftView:(BOOL)show;
- (void)toggleRightView;
- (void)showRightView:(BOOL)show;

@end
