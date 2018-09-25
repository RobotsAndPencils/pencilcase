//
//  PCDeploymentMenuItemView.h
//  SpriteBuilder
//
//  Created by Brandon on 2014-03-24.
//
//

@interface PCDeploymentMenuItemView : NSView

@property (strong, nonatomic) IBOutlet NSView *view;

@property (weak, nonatomic) IBOutlet NSTextField *titleLabel;
@property (weak, nonatomic) IBOutlet NSTextField *subtitleLabel;
@property (weak, nonatomic) IBOutlet NSImageView *imageView;
@property (assign, nonatomic) BOOL enabled;

@end
