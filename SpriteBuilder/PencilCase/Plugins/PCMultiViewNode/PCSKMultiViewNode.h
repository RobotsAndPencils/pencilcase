//
//  PCSKMultiViewNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-09.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCFocusableNode.h"
#import "PCOverlayView.h"
#import "PCNodeChildrenManagement.h"

@interface PCSKMultiViewNode : SKSpriteNode <PCFocusableNode, PCOverlayNode, PCNodeChildInsertion>

@property (strong, nonatomic, readonly) NSArray *cells;
@property (assign, nonatomic) BOOL showPageIndicator;
@property (strong, nonatomic) NSColor *currentPageIndicatorColor;
@property (strong, nonatomic) NSColor *pageIndicatorColor;

@end
