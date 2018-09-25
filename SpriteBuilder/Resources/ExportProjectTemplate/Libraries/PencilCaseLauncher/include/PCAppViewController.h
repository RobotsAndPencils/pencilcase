//
//  PCAppViewController 
//  PCPlayer
//
//  Created by brandon on 2014-03-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PCREPLViewController;
@class PCApp;
@class PCBeaconManager;
@class PCCard;
@class PCKeyValueStore;

@protocol PCOverlayNode;

@interface PCAppViewController : UIViewController

@property (strong, nonatomic, readonly) SKView *spriteKitView;
@property (strong, nonatomic, readonly) PCApp *runningApp;
@property (strong, nonatomic, readonly) PCBeaconManager *beaconManager;
@property (strong, nonatomic, readonly) PCCard *cardAtCurrentIndex;
@property (nonatomic) BOOL enableDefaultREPLGesture;

- (instancetype)initWithApp:(PCApp *)app startSlideIndex:(NSInteger)index;
- (instancetype)initWithApp:(PCApp *)app startSlideIndex:(NSInteger)index options:(NSDictionary *)launchOptions;
+ (instancetype)lastCreatedInstance;

- (void)showREPL;
- (void)hideREPL;

- (void)nodeDidBeginEditingText:(SKNode<PCOverlayNode> *)textNode;
- (void)nodeDidFinishEditingText:(SKNode<PCOverlayNode >*)textNode;

@end
